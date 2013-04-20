// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "platform/assert.h"
#include "vm/message.h"
#include "vm/unit_test.h"

namespace dart {


// Provide access to private members of MessageQueue for testing.
class MessageQueueTestPeer {
 public:
  explicit MessageQueueTestPeer(MessageQueue* queue) : queue_(queue) {}

  bool HasMessage() const {
    // We don't really need to grab the monitor during the unit test,
    // but it doesn't hurt.
    bool result = (queue_->head_ != NULL);
    return result;
  }

 private:
  MessageQueue* queue_;

  DISALLOW_COPY_AND_ASSIGN(MessageQueueTestPeer);
};


static uint8_t* AllocMsg(const char* str) {
  return reinterpret_cast<uint8_t*>(strdup(str));
}


TEST_CASE(MessageQueue_BasicOperations) {
  MessageQueue queue;
  MessageQueueTestPeer queue_peer(&queue);
  EXPECT(!queue_peer.HasMessage());

  Dart_Port port = 1;

  const char* str1 = "msg1";
  const char* str2 = "msg2";

  // Add two messages.
  Message* msg1 =
      new Message(port, 0, AllocMsg(str1), strlen(str1) + 1,
                  Message::kNormalPriority);
  queue.Enqueue(msg1);
  EXPECT(queue_peer.HasMessage());

  Message* msg2 =
      new Message(port, 0, AllocMsg(str2), strlen(str2) + 1,
                  Message::kNormalPriority);

  queue.Enqueue(msg2);
  EXPECT(queue_peer.HasMessage());

  // Remove two messages.
  Message* msg = queue.Dequeue();
  EXPECT(msg != NULL);
  EXPECT_STREQ(str1, reinterpret_cast<char*>(msg->data()));
  EXPECT(queue_peer.HasMessage());

  msg = queue.Dequeue();
  EXPECT(msg != NULL);
  EXPECT_STREQ(str2, reinterpret_cast<char*>(msg->data()));
  EXPECT(!queue_peer.HasMessage());

  delete msg1;
  delete msg2;
}


TEST_CASE(MessageQueue_Clear) {
  MessageQueue queue;
  MessageQueueTestPeer queue_peer(&queue);
  Dart_Port port1 = 1;
  Dart_Port port2 = 2;

  const char* str1 = "msg1";
  const char* str2 = "msg2";

  // Add two messages.
  Message* msg1 =
      new Message(port1, 0, AllocMsg(str1), strlen(str1) + 1,
                  Message::kNormalPriority);
  queue.Enqueue(msg1);
  Message* msg2 =
      new Message(port2, 0, AllocMsg(str2), strlen(str2) + 1,
                  Message::kNormalPriority);
  queue.Enqueue(msg2);

  EXPECT(queue_peer.HasMessage());
  queue.Clear();
  EXPECT(!queue_peer.HasMessage());

  // msg1 and msg2 already delete by FlushAll.
}

}  // namespace dart
