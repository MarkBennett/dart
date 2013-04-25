// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "platform/globals.h"
#if defined(TARGET_OS_MACOS)

#include "bin/eventhandler.h"

#include <errno.h>  // NOLINT
#include <pthread.h>  // NOLINT
#include <stdio.h>  // NOLINT
#include <string.h>  // NOLINT
#include <sys/event.h>  // NOLINT
#include <unistd.h>  // NOLINT

#include "bin/dartutils.h"
#include "bin/fdutils.h"
#include "bin/log.h"
#include "bin/utils.h"
#include "platform/hashmap.h"
#include "platform/thread.h"
#include "platform/utils.h"


namespace dart {
namespace bin {

static const int kInterruptMessageSize = sizeof(InterruptMessage);
static const int kInfinityTimeout = -1;
static const int kTimerId = -1;
static const int kShutdownId = -2;


bool SocketData::HasReadEvent() {
  return !IsClosedRead() && ((mask_ & (1 << kInEvent)) != 0);
}


bool SocketData::HasWriteEvent() {
  return !IsClosedWrite() && ((mask_ & (1 << kOutEvent)) != 0);
}


// Unregister the file descriptor for a SocketData structure with kqueue.
static void RemoveFromKqueue(intptr_t kqueue_fd_, SocketData* sd) {
  static const intptr_t kMaxChanges = 2;
  intptr_t changes = 0;
  struct kevent events[kMaxChanges];
  if (sd->read_tracked_by_kqueue()) {
    EV_SET(events + changes, sd->fd(), EVFILT_READ, EV_DELETE, 0, 0, NULL);
    ++changes;
    sd->set_read_tracked_by_kqueue(false);
  }
  if (sd->write_tracked_by_kqueue()) {
    EV_SET(events + changes, sd->fd(), EVFILT_WRITE, EV_DELETE, 0, 0, sd);
    ++changes;
    sd->set_write_tracked_by_kqueue(false);
  }
  if (changes > 0) {
    ASSERT(changes <= kMaxChanges);
    int status =
      TEMP_FAILURE_RETRY(kevent(kqueue_fd_, events, changes, NULL, 0, NULL));
    if (status == -1) {
      FATAL1("Failed deleting events from kqueue: %s\n", strerror(errno));
    }
  }
}


// Update the kqueue registration for SocketData structure to reflect
// the events currently of interest.
static void UpdateKqueue(intptr_t kqueue_fd_, SocketData* sd) {
  static const intptr_t kMaxChanges = 2;
  intptr_t changes = 0;
  struct kevent events[kMaxChanges];
  if (sd->port() != 0) {
    // Register or unregister READ filter if needed.
    if (sd->HasReadEvent()) {
      if (!sd->read_tracked_by_kqueue()) {
        EV_SET(events + changes, sd->fd(), EVFILT_READ, EV_ADD, 0, 0, sd);
        ++changes;
        sd->set_read_tracked_by_kqueue(true);
      }
    } else if (sd->read_tracked_by_kqueue()) {
      EV_SET(events + changes, sd->fd(), EVFILT_READ, EV_DELETE, 0, 0, NULL);
      ++changes;
      sd->set_read_tracked_by_kqueue(false);
    }
    // Register or unregister WRITE filter if needed.
    if (sd->HasWriteEvent()) {
      if (!sd->write_tracked_by_kqueue()) {
        EV_SET(events + changes, sd->fd(), EVFILT_WRITE, EV_ADD, 0, 0, sd);
        ++changes;
        sd->set_write_tracked_by_kqueue(true);
      }
    } else if (sd->write_tracked_by_kqueue()) {
      EV_SET(events + changes, sd->fd(), EVFILT_WRITE, EV_DELETE, 0, 0, NULL);
      ++changes;
      sd->set_write_tracked_by_kqueue(false);
    }
  }
  if (changes > 0) {
    ASSERT(changes <= kMaxChanges);
    int status =
      TEMP_FAILURE_RETRY(kevent(kqueue_fd_, events, changes, NULL, 0, NULL));
    if (status == -1) {
      // kQueue does not accept the file descriptor. It could be due to
      // already closed file descriptor, or unuspported devices, such
      // as /dev/null. In such case, mark the file descriptor as closed,
      // so dart will handle it accordingly.
      sd->set_write_tracked_by_kqueue(false);
      sd->set_read_tracked_by_kqueue(false);
      sd->ShutdownRead();
      sd->ShutdownWrite();
      DartUtils::PostInt32(sd->port(), 1 << kCloseEvent);
    }
  }
}


EventHandlerImplementation::EventHandlerImplementation()
    : socket_map_(&HashMap::SamePointerValue, 16) {
  intptr_t result;
  result = TEMP_FAILURE_RETRY(pipe(interrupt_fds_));
  if (result != 0) {
    FATAL("Pipe creation failed");
  }
  FDUtils::SetNonBlocking(interrupt_fds_[0]);
  FDUtils::SetCloseOnExec(interrupt_fds_[0]);
  FDUtils::SetCloseOnExec(interrupt_fds_[1]);
  timeout_ = kInfinityTimeout;
  timeout_port_ = 0;
  shutdown_ = false;

  kqueue_fd_ = TEMP_FAILURE_RETRY(kqueue());
  if (kqueue_fd_ == -1) {
    FATAL("Failed creating kqueue");
  }
  FDUtils::SetCloseOnExec(kqueue_fd_);
  // Register the interrupt_fd with the kqueue.
  struct kevent event;
  EV_SET(&event, interrupt_fds_[0], EVFILT_READ, EV_ADD, 0, 0, NULL);
  int status = TEMP_FAILURE_RETRY(kevent(kqueue_fd_, &event, 1, NULL, 0, NULL));
  if (status == -1) {
    FATAL1("Failed adding interrupt fd to kqueue: %s\n", strerror(errno));
  }
}


EventHandlerImplementation::~EventHandlerImplementation() {
  VOID_TEMP_FAILURE_RETRY(close(kqueue_fd_));
  VOID_TEMP_FAILURE_RETRY(close(interrupt_fds_[0]));
  VOID_TEMP_FAILURE_RETRY(close(interrupt_fds_[1]));
}


SocketData* EventHandlerImplementation::GetSocketData(intptr_t fd) {
  ASSERT(fd >= 0);
  HashMap::Entry* entry = socket_map_.Lookup(
      GetHashmapKeyFromFd(fd), GetHashmapHashFromFd(fd), true);
  ASSERT(entry != NULL);
  SocketData* sd = reinterpret_cast<SocketData*>(entry->value);
  if (sd == NULL) {
    // If there is no data in the hash map for this file descriptor a
    // new SocketData for the file descriptor is inserted.
    sd = new SocketData(fd);
    entry->value = sd;
  }
  ASSERT(fd == sd->fd());
  return sd;
}


void EventHandlerImplementation::WakeupHandler(intptr_t id,
                                               Dart_Port dart_port,
                                               int64_t data) {
  InterruptMessage msg;
  msg.id = id;
  msg.dart_port = dart_port;
  msg.data = data;
  intptr_t result =
      FDUtils::WriteToBlocking(interrupt_fds_[1], &msg, kInterruptMessageSize);
  if (result != kInterruptMessageSize) {
    if (result == -1) {
      perror("Interrupt message failure:");
    }
    FATAL1("Interrupt message failure. Wrote %"Pd" bytes.", result);
  }
}


bool EventHandlerImplementation::GetInterruptMessage(InterruptMessage* msg) {
  char* dst = reinterpret_cast<char*>(msg);
  int total_read = 0;
  int bytes_read =
      TEMP_FAILURE_RETRY(read(interrupt_fds_[0], dst, kInterruptMessageSize));
  if (bytes_read < 0) {
    return false;
  }
  total_read = bytes_read;
  while (total_read < kInterruptMessageSize) {
    bytes_read = TEMP_FAILURE_RETRY(read(interrupt_fds_[0],
                                         dst + total_read,
                                         kInterruptMessageSize - total_read));
    if (bytes_read > 0) {
      total_read = total_read + bytes_read;
    }
  }
  return (total_read == kInterruptMessageSize) ? true : false;
}

void EventHandlerImplementation::HandleInterruptFd() {
  InterruptMessage msg;
  while (GetInterruptMessage(&msg)) {
    if (msg.id == kTimerId) {
      timeout_ = msg.data;
      timeout_port_ = msg.dart_port;
    } else if (msg.id == kShutdownId) {
      shutdown_ = true;
    } else {
      SocketData* sd = GetSocketData(msg.id);
      if ((msg.data & (1 << kShutdownReadCommand)) != 0) {
        ASSERT(msg.data == (1 << kShutdownReadCommand));
        // Close the socket for reading.
        sd->ShutdownRead();
        UpdateKqueue(kqueue_fd_, sd);
      } else if ((msg.data & (1 << kShutdownWriteCommand)) != 0) {
        ASSERT(msg.data == (1 << kShutdownWriteCommand));
        // Close the socket for writing.
        sd->ShutdownWrite();
        UpdateKqueue(kqueue_fd_, sd);
      } else if ((msg.data & (1 << kCloseCommand)) != 0) {
        ASSERT(msg.data == (1 << kCloseCommand));
        // Close the socket and free system resources.
        RemoveFromKqueue(kqueue_fd_, sd);
        intptr_t fd = sd->fd();
        sd->Close();
        socket_map_.Remove(GetHashmapKeyFromFd(fd), GetHashmapHashFromFd(fd));
        delete sd;
      } else {
        if ((msg.data & (1 << kInEvent)) != 0 && sd->IsClosedRead()) {
          DartUtils::PostInt32(msg.dart_port, 1 << kCloseEvent);
        } else {
          // Setup events to wait for.
          sd->SetPortAndMask(msg.dart_port, msg.data);
          UpdateKqueue(kqueue_fd_, sd);
        }
      }
    }
  }
}

#ifdef DEBUG_KQUEUE
static void PrintEventMask(intptr_t fd, struct kevent* event) {
  Log::Print("%d ", static_cast<int>(fd));
  if (event->filter == EVFILT_READ) Log::Print("EVFILT_READ ");
  if (event->filter == EVFILT_WRITE) Log::Print("EVFILT_WRITE ");
  Log::Print("flags: %x: ", event->flags);
  if ((event->flags & EV_EOF) != 0) Log::Print("EV_EOF ");
  if ((event->flags & EV_ERROR) != 0) Log::Print("EV_ERROR ");
  Log::Print("- fflags: %d ", event->fflags);
  Log::Print("(available %d) ",
      static_cast<int>(FDUtils::AvailableBytes(fd)));
  Log::Print("\n");
}
#endif


intptr_t EventHandlerImplementation::GetEvents(struct kevent* event,
                                               SocketData* sd) {
#ifdef DEBUG_KQUEUE
  PrintEventMask(sd->fd(), event);
#endif
  intptr_t event_mask = 0;
  if (sd->IsListeningSocket()) {
    // On a listening socket the READ event means that there are
    // connections ready to be accepted.
    if (event->filter == EVFILT_READ) {
      if ((event->flags & EV_EOF) != 0) {
        if (event->fflags != 0) {
          event_mask |= (1 << kErrorEvent);
        } else {
          event_mask |= (1 << kCloseEvent);
        }
      }
      if (event_mask == 0) event_mask |= (1 << kInEvent);
    } else {
      UNREACHABLE();
    }
  } else {
    // Prioritize data events over close and error events.
    if (event->filter == EVFILT_READ) {
      if (FDUtils::AvailableBytes(sd->fd()) != 0) {
         event_mask = (1 << kInEvent);
      } else if ((event->flags & EV_EOF) != 0) {
        if (event->fflags != 0) {
          event_mask |= (1 << kErrorEvent);
        } else {
          event_mask |= (1 << kCloseEvent);
        }
        sd->MarkClosedRead();
      }
    } else if (event->filter == EVFILT_WRITE) {
      if ((event->flags & EV_EOF) != 0) {
        if (event->fflags != 0) {
          event_mask |= (1 << kErrorEvent);
        } else {
          event_mask |= (1 << kCloseEvent);
        }
        // If the receiver closed for reading, close for writing,
        // update the registration with kqueue, and do not report a
        // write event.
        sd->MarkClosedWrite();
        UpdateKqueue(kqueue_fd_, sd);
      } else {
        event_mask |= (1 << kOutEvent);
      }
    } else {
      UNREACHABLE();
    }
  }

  return event_mask;
}


void EventHandlerImplementation::HandleEvents(struct kevent* events,
                                              int size) {
  for (int i = 0; i < size; i++) {
    // If flag EV_ERROR is set it indicates an error in kevent processing.
    if ((events[i].flags & EV_ERROR) != 0) {
      FATAL1("kevent failed %s\n", strerror(events[i].data));
    }
    if (events[i].udata != NULL) {
      SocketData* sd = reinterpret_cast<SocketData*>(events[i].udata);
      intptr_t event_mask = GetEvents(events + i, sd);
      if (event_mask != 0) {
        // Unregister events for the file descriptor. Events will be
        // registered again when the current event has been handled in
        // Dart code.
        RemoveFromKqueue(kqueue_fd_, sd);
        Dart_Port port = sd->port();
        ASSERT(port != 0);
        DartUtils::PostInt32(port, event_mask);
      }
    }
  }
  HandleInterruptFd();
}


intptr_t EventHandlerImplementation::GetTimeout() {
  if (timeout_ == kInfinityTimeout) {
    return kInfinityTimeout;
  }
  intptr_t millis = timeout_ - TimerUtils::GetCurrentTimeMilliseconds();
  return (millis < 0) ? 0 : millis;
}


void EventHandlerImplementation::HandleTimeout() {
  if (timeout_ != kInfinityTimeout) {
    intptr_t millis = timeout_ - TimerUtils::GetCurrentTimeMilliseconds();
    if (millis <= 0) {
      DartUtils::PostNull(timeout_port_);
      timeout_ = kInfinityTimeout;
      timeout_port_ = 0;
    }
  }
}


void EventHandlerImplementation::EventHandlerEntry(uword args) {
  static const intptr_t kMaxEvents = 16;
  struct kevent events[kMaxEvents];
  EventHandler* handler = reinterpret_cast<EventHandler*>(args);
  EventHandlerImplementation* handler_impl = &handler->delegate_;
  ASSERT(handler_impl != NULL);
  while (!handler_impl->shutdown_) {
    intptr_t millis = handler_impl->GetTimeout();
    // NULL pointer timespec for infinite timeout.
    ASSERT(kInfinityTimeout < 0);
    struct timespec* timeout = NULL;
    struct timespec ts;
    if (millis >= 0) {
      ts.tv_sec = millis / 1000;
      ts.tv_nsec = (millis - (ts.tv_sec * 1000)) * 1000000;
      timeout = &ts;
    }
    intptr_t result = TEMP_FAILURE_RETRY(kevent(handler_impl->kqueue_fd_,
                                                NULL,
                                                0,
                                                events,
                                                kMaxEvents,
                                                timeout));
    if (result == -1) {
      FATAL1("kevent failed %s\n", strerror(errno));
    } else {
      handler_impl->HandleTimeout();
      handler_impl->HandleEvents(events, result);
    }
  }
  delete handler;
}


void EventHandlerImplementation::Start(EventHandler* handler) {
  int result =
      dart::Thread::Start(&EventHandlerImplementation::EventHandlerEntry,
                          reinterpret_cast<uword>(handler));
  if (result != 0) {
    FATAL1("Failed to start event handler thread %d", result);
  }
}


void EventHandlerImplementation::Shutdown() {
  SendData(kShutdownId, 0, 0);
}


void EventHandlerImplementation::SendData(intptr_t id,
                                          Dart_Port dart_port,
                                          int64_t data) {
  WakeupHandler(id, dart_port, data);
}


void* EventHandlerImplementation::GetHashmapKeyFromFd(intptr_t fd) {
  // The hashmap does not support keys with value 0.
  return reinterpret_cast<void*>(fd + 1);
}


uint32_t EventHandlerImplementation::GetHashmapHashFromFd(intptr_t fd) {
  // The hashmap does not support keys with value 0.
  return dart::Utils::WordHash(fd + 1);
}

}  // namespace bin
}  // namespace dart

#endif  // defined(TARGET_OS_MACOS)
