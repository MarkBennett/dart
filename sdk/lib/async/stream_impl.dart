// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.async;

// States shared by single/multi stream implementations.

// Completion state of the stream.
/// Initial and default state where the stream can receive and send events.
const int _STREAM_OPEN = 0;
/// The stream has received a request to complete, but hasn't done so yet.
/// No further events can be added to the stream.
const int _STREAM_CLOSED = 1;
/// The stream has completed and will no longer receive or send events.
/// Also counts as closed. The stream must not be paused when it's completed.
/// Always used in conjunction with [_STREAM_CLOSED].
const int _STREAM_COMPLETE = 2;

/// Bit that alternates between events, and listeners are updated to the
/// current value when they are notified of the event.
const int _STREAM_EVENT_ID = 4;
const int _STREAM_EVENT_ID_SHIFT = 2;

// The activity state of the stream: What is it currently doing.
/// Bit set while firing and clear while not.
const int _STREAM_FIRING = 8;
/// Bit set while calling a pause-state or subscription-state change callback.
const int _STREAM_CALLBACK = 16;

// The pause state of the stream.
/// Bit set when resuming with pending events. Cleared after all pending events
/// have been transmitted. Means that the controller still considers the
/// stream paused, even if the listener doesn't.
const int _STREAM_PENDING_RESUME = 32;
/// The count of times a stream has paused is stored in the
/// state, shifted by this amount.
const int _STREAM_PAUSE_COUNT_SHIFT = 6;

// States for listeners.

/// The listener is currently not subscribed to its source stream.
const int _LISTENER_UNSUBSCRIBED = 0;
/// The listener is actively subscribed to its source stream.
const int _LISTENER_SUBSCRIBED = 1;
/// The listener is subscribed until it has been notified of the current event.
/// This flag bit is always used in conjuction with [_LISTENER_SUBSCRIBED].
const int _LISTENER_PENDING_UNSUBSCRIBE = 2;

/// Bit that contains the last sent event's "id bit".
const int _LISTENER_EVENT_ID = 4;
const int _LISTENER_EVENT_ID_SHIFT = 2;

/// The count of times a listener has paused is stored in the
/// state, shifted by this amount.
const int _LISTENER_PAUSE_COUNT_SHIFT = 3;

/** Throws the given error in the next cycle. */
_throwDelayed(var error, [Object stackTrace]) {
  // We are going to reach the top-level here, but there might be a global
  // exception handler. This means that we shouldn't print the stack trace.
  // TODO(floitsch): Find better solution that doesn't print the stack trace
  // if there is a global exception handler.
  runAsync(() {
    if (stackTrace != null) print(stackTrace);
    var trace = getAttachedStackTrace(error);
    if (trace != null && trace != stackTrace) print(trace);
    throw error;
  });
}


// -------------------------------------------------------------------
// Common base class for single and multi-subscription streams.
// -------------------------------------------------------------------
abstract class _StreamImpl<T> extends Stream<T> {
  /** Current state of the stream. */
  int _state = _STREAM_OPEN;

  /**
   * List of pending events.
   *
   * If events are added to the stream (using [_add], [_addError] or [_done])
   * while the stream is paused, or while another event is firing, events will
   * stored here.
   * Also supports scheduling the events for later execution.
   */
  _PendingEvents _pendingEvents;

  // ------------------------------------------------------------------
  // Stream interface.

  StreamSubscription<T> listen(void onData(T data),
                               { void onError(error),
                                 void onDone(),
                                 bool cancelOnError }) {
    if (_isComplete) {
      return new _DoneSubscription(onDone);
    }
    if (onData == null) onData = _nullDataHandler;
    if (onError == null) onError = _nullErrorHandler;
    if (onDone == null) onDone = _nullDoneHandler;
    cancelOnError = identical(true, cancelOnError);
    _StreamSubscriptionImpl subscription =
        _createSubscription(onData, onError, onDone, cancelOnError);
    _addListener(subscription);
    return subscription;
  }

  // ------------------------------------------------------------------
  // EventSink interface-like methods for sending events into the stream.
  // It's the responsibility of the caller to ensure that the stream is not
  // paused when adding events. If the stream is paused, the events will be
  // queued, but it's better to not send events at all.

  /**
   * Send or queue a data event.
   */
  void _add(T value) {
    if (_isClosed) throw new StateError("Sending on closed stream");
    if (!_mayFireState) {
      // Not the time to send events.
      _addPendingEvent(new _DelayedData<T>(value));
      return;
    }
    if (_hasPendingEvent) {
      _addPendingEvent(new _DelayedData<T>(value));
    } else {
      _sendData(value);
    }
    _handlePendingEvents();
  }

  /**
   * Send or enqueue an error event.
   *
   * If a subscription has requested to be unsubscribed on errors,
   * it will be unsubscribed after receiving this event.
   */
  void _addError(error) {
    if (_isClosed) throw new StateError("Sending on closed stream");
    if (!_mayFireState) {
      // Not the time to send events.
      _addPendingEvent(new _DelayedError(error));
      return;
    }
    if (_hasPendingEvent) {
      _addPendingEvent(new _DelayedError(error));
    } else {
      _sendError(error);
    }
    _handlePendingEvents();
  }

  /**
   * Send or enqueue a "done" message.
   *
   * The "done" message should be sent at most once by a stream, and it
   * should be the last message sent.
   */
  void _close() {
    if (_isClosed) return;
    _state |= _STREAM_CLOSED;
    if (!_mayFireState) {
      // Not the time to send events.
      _addPendingEvent(const _DelayedDone());
      return;
    }
    if (_hasPendingEvent) {
      _addPendingEvent(new _DelayedDone());
      _handlePendingEvents();
    } else {
      _sendDone();
      assert(_isComplete);
      assert(!_hasPendingEvent);
    }
  }

  // -------------------------------------------------------------------
  // Internal implementation.

  // State predicates.

  // Lifecycle state.
  /** Whether the stream is in the default, open, state for events. */
  bool get _isOpen => (_state & (_STREAM_CLOSED | _STREAM_COMPLETE)) == 0;

  /** Whether the stream has been closed (a done event requested). */
  bool get _isClosed => (_state & _STREAM_CLOSED) != 0;

  /** Whether the stream is completed. */
  bool get _isComplete => (_state & _STREAM_COMPLETE) != 0;

  // Pause state.

  /** Whether one or more active subscribers have requested a pause. */
  bool get _isPaused => _state >= (1 << _STREAM_PAUSE_COUNT_SHIFT);

  /** How many times the stream has been paused. */
  int get _pauseCount => _state >> _STREAM_PAUSE_COUNT_SHIFT;

  /**
   * Whether a controller thinks the stream is paused.
   *
   * When this changes, a pause-state change callback is performed.
   *
   * It may differ from [_isPaused] if there are pending events
   * in the queue when the listeners resume. The controller won't
   * be informed until all queued events have been fired.
   */
  bool get _isInputPaused => _state >= (_STREAM_PENDING_RESUME);

  /** Whether we have a pending resume scheduled. */
  bool get _hasPendingResume => (_state & _STREAM_PENDING_RESUME) != 0;


  // Action state. If the stream makes a call-out to external code,
  // this state tracks it and avoids reentrancy problems.

  /** Whether the stream is not currently firing or calling a callback. */
  bool get _isInactive => (_state & (_STREAM_CALLBACK | _STREAM_FIRING)) == 0;

  /** Whether we are currently executing a state-chance callback. */
  bool get _isInCallback => (_state & _STREAM_CALLBACK) != 0;

  /** Whether we are currently firing an event. */
  bool get _isFiring => (_state & _STREAM_FIRING) != 0;

  /** Check whether the pending event queue is non-empty */
  bool get _hasPendingEvent =>
      _pendingEvents != null && !_pendingEvents.isEmpty;

  /**
   * The bit representing the current or last event fired.
   *
   * This bit matches a bit on listeners that have received the corresponding
   * event. It is toggled for each new event being fired.
   */
  int get _currentEventIdBit =>
      (_state & _STREAM_EVENT_ID ) >> _STREAM_EVENT_ID_SHIFT;

  /** Whether there is currently a subscriber on this [Stream]. */
  bool get _hasListener;


  /** Whether the state bits allow firing. */
  bool get _mayFireState {
    // The state allows firing unless:
    // - it's currently firing
    // - it's currently in a callback
    // - it's paused
    const int mask =
        _STREAM_FIRING |
        _STREAM_CALLBACK |
        ~((1 << _STREAM_PAUSE_COUNT_SHIFT) - 1);
    return (_state & mask) == 0;
  }

  // State modification.

  /** Record an increases in the number of times the listener has paused. */
  void _incrementPauseCount(_StreamListener<T> listener) {
    listener._incrementPauseCount();
    _state &= ~_STREAM_PENDING_RESUME;
    _updatePauseCount(1);
  }

  /** Record a decrease in the number of times the listener has paused. */
  void _decrementPauseCount(_StreamListener<T> listener) {
    assert(_isPaused);
    listener._decrementPauseCount();
    _updatePauseCount(-1);
  }

  /** Update the stream's own pause count only. */
  void _updatePauseCount(int by) {
    int oldState = _state;
    // We can't just _state += by << _STREAM_PAUSE_COUNT_SHIFT, since dart2js
    // converts the result of the left-shift to a positive number.
    if (by >= 0) {
      _state = oldState + (by << _STREAM_PAUSE_COUNT_SHIFT);
    } else {
      _state = oldState - ((-by) << _STREAM_PAUSE_COUNT_SHIFT);
    }
    assert(_state >= 0);
    assert((_state >> _STREAM_PAUSE_COUNT_SHIFT) ==
        (oldState >> _STREAM_PAUSE_COUNT_SHIFT) + by);
  }

  void _setClosed() {
    assert(!_isClosed);
    _state |= _STREAM_CLOSED;
  }

  void _setComplete() {
    assert(_isClosed);
    _state = _state |_STREAM_COMPLETE;
  }

  void _startFiring() {
    assert(!_isFiring);
    assert(!_isInCallback);
    assert(_hasListener);
    assert(!_isPaused);
    // This sets the _STREAM_FIRING bit and toggles the _STREAM_EVENT_ID
    // bit. All current subscribers will now have a _LISTENER_EVENT_ID
    // that doesn't match _STREAM_EVENT_ID, and they will receive the
    // event being fired.
    _state ^= _STREAM_FIRING | _STREAM_EVENT_ID;
  }

  void _endFiring(bool wasInputPaused) {
    assert(_isFiring);
    _state ^= _STREAM_FIRING;
    // Had listeners, or we wouldn't have fired.
    _checkCallbacks(true, wasInputPaused);
  }

  /**
   * Record that a listener wants a pause from events.
   *
   * This methods is called from [_StreamListener.pause()].
   * Subclasses can override this method, along with [isPaused] and
   * [createSubscription], if they want to do a different handling of paused
   * subscriptions, e.g., a filtering stream pausing its own source if all its
   * subscribers are paused.
   */
  void _pause(_StreamListener<T> listener, Future resumeSignal) {
    assert(identical(listener._source, this));
    if (!listener._isSubscribed) {
      throw new StateError("Subscription has been canceled.");
    }
    assert(!_isComplete);  // There can be no subscribers when complete.
    bool wasInputPaused = _isInputPaused;
    bool wasPaused = _isPaused;
    _incrementPauseCount(listener);
    if (resumeSignal != null) {
      resumeSignal.whenComplete(() { this._resume(listener, true); });
    }
    if (!wasPaused && _hasPendingEvent && _pendingEvents.isScheduled) {
      _pendingEvents.cancelSchedule();
    }
    if (_isInactive && !wasInputPaused) {
      _checkCallbacks(true, false);
      if (!_isPaused && _hasPendingEvent) {
        _schedulePendingEvents();
      }
    }
  }

  /** Stops pausing due to one request from the given listener. */
  void _resume(_StreamListener<T> listener, bool fromEvent) {
    if (!listener.isPaused) return;
    assert(listener._isSubscribed);
    assert(_isPaused);
    _decrementPauseCount(listener);
    if (!_isPaused) {
      if (_hasPendingEvent) {
        _state |= _STREAM_PENDING_RESUME;
        // Controller's pause state hasn't changed.
        // If we can fire events now, fire any pending events right away.
        if (_isInactive) {
          if (fromEvent) {
            _handlePendingEvents();
          } else {
            _schedulePendingEvents();
          }
        }
      } else if (_isInactive) {
        _checkCallbacks(true, true);
        if (!_isPaused && _hasPendingEvent) {
          if (fromEvent) {
            _handlePendingEvents();
          } else {
            _schedulePendingEvents();
          }
        }
      }
    }
  }

  /** Schedule pending events to be executed. */
  void _schedulePendingEvents() {
    assert(_hasPendingEvent);
    _pendingEvents.schedule(this);
  }

  /** Create a subscription object. Called by [subcribe]. */
  _StreamSubscriptionImpl<T> _createSubscription(
      void onData(T data),
      void onError(error),
      void onDone(),
      bool cancelOnError);

  /**
   * Adds a listener to this stream.
   */
  void _addListener(_StreamSubscriptionImpl subscription);

  /**
   * Handle a cancel requested from a [_StreamSubscriptionImpl].
   *
   * This method is called from [_StreamSubscriptionImpl.cancel].
   *
   * If an event is currently firing, the cancel is delayed
   * until after the subscribers have received the event.
   */
  void _cancel(_StreamSubscriptionImpl subscriber);

  /**
   * Iterate over all current subscribers and perform an action on each.
   *
   * Subscribers added during the iteration will not be visited.
   * Subscribers unsubscribed during the iteration will only be removed
   * after they have been acted on.
   *
   * Any change in the pause state is only reported after all subscribers have
   * received the event.
   *
   * The [action] must not throw, or the controller will be left in an
   * invalid state.
   *
   * This method must not be called while [isFiring] is true.
   */
  void _forEachSubscriber(void action(_StreamSubscriptionImpl<T> subscription));

  /**
   * Checks whether the subscription/pause state has changed.
   *
   * Calls the appropriate callback if the state has changed from the
   * provided one. Repeats calling callbacks as long as the call changes
   * the state.
   */
  void _checkCallbacks(bool hadListener, bool wasPaused) {
    assert(!_isFiring);
    // Will be handled after the current callback.
    if (_isInCallback) return;
    if (_hasPendingResume && !_hasPendingEvent) {
      _state ^= _STREAM_PENDING_RESUME;
    }
    _state |= _STREAM_CALLBACK;
    while (true) {
      bool hasListener = _hasListener;
      bool isPaused = _isInputPaused;
      if (hadListener != hasListener) {
        _onSubscriptionStateChange();
      } else if (isPaused != wasPaused) {
        _onPauseStateChange();
      } else {
        _state ^= _STREAM_CALLBACK;
        return;
      }
      wasPaused = isPaused;
      hadListener = hasListener;
    }
  }

  /**
   * Called when the first subscriber requests a pause or the last a resume.
   *
   * Read [isPaused] to see the new state.
   */
  void _onPauseStateChange() {}

  /**
   * Called when the first listener subscribes or the last unsubscribes.
   *
   * Read [hasListener] to see what the new state is.
   */
  void _onSubscriptionStateChange() {}

  /**
   * Add a pending event at the end of the pending event queue.
   *
   * Schedules events if currently not paused and inside a callback.
   */
  void _addPendingEvent(_DelayedEvent event) {
    if (_pendingEvents == null) _pendingEvents = new _StreamImplEvents();
    _StreamImplEvents events = _pendingEvents;
    events.add(event);
    if (_isPaused || _isFiring) return;
    if (_isInCallback) {
      _schedulePendingEvents();
      return;
    }
  }

  /** Fire any pending events until the pending event queue is empty. */
  void _handlePendingEvents() {
    assert(_isInactive);
    if (!_hasPendingEvent) return;
    _PendingEvents events = _pendingEvents;
    do {
      if (_isPaused) return;
      if (events.isScheduled) events.cancelSchedule();
      events.handleNext(this);
    } while (!events.isEmpty);
  }

  /**
   * Send a data event directly to each subscriber.
   */
  _sendData(T value) {
    assert(!_isPaused);
    assert(!_isComplete);
    if (!_hasListener) return;
    _forEachSubscriber((subscriber) {
      try {
        subscriber._sendData(value);
      } catch (e, s) {
        _throwDelayed(e, s);
      }
    });
  }

  /**
   * Sends an error event directly to each subscriber.
   */
  void _sendError(error) {
    assert(!_isPaused);
    assert(!_isComplete);
    if (!_hasListener) return;
    _forEachSubscriber((subscriber) {
      try {
        subscriber._sendError(error);
      } catch (e, s) {
        _throwDelayed(e, s);
      }
    });
  }

  /**
   * Sends the "done" message directly to each subscriber.
   * This automatically stops further subscription and
   * unsubscribes all subscribers.
   */
  void _sendDone() {
    assert(!_isPaused);
    assert(_isClosed);
    _setComplete();
    if (!_hasListener) return;
    _forEachSubscriber((subscriber) {
      _cancel(subscriber);
      try {
        subscriber._sendDone();
      } catch (e, s) {
        _throwDelayed(e, s);
      }
    });
    assert(!_hasListener);
  }
}

// -------------------------------------------------------------------
// Default implementation of a stream with a single subscriber.
// -------------------------------------------------------------------
/**
 * Default implementation of stream capable of sending events to one subscriber.
 *
 * Any class needing to implement [Stream] can either directly extend this
 * class, or extend [Stream] and delegate the subscribe method to an instance
 * of this class.
 *
 * The only public methods are those of [Stream], so instances of
 * [_SingleStreamImpl] can be returned directly as a [Stream] without exposing
 * internal functionality.
 *
 * The [StreamController] is a public facing version of this class, with
 * some methods made public.
 *
 * The user interface of [_SingleStreamImpl] are the following methods:
 * * [_add]: Add a data event to the stream.
 * * [_addError]: Add an error event to the stream.
 * * [_close]: Request to close the stream.
 * * [_onSubscriberStateChange]: Called when receiving the first subscriber or
 *                               when losing the last subscriber.
 * * [_onPauseStateChange]: Called when entering or leaving paused mode.
 * * [_hasListener]: Test whether there are currently any subscribers.
 * * [_isInputPaused]: Test whether the stream is currently paused.
 * The user should not add new events while the stream is paused, but if it
 * happens anyway, the stream will enqueue the events just as when new events
 * arrive while still firing an old event.
 */
class _SingleStreamImpl<T> extends _StreamImpl<T> {
  _StreamListener _subscriber = null;

  /** Whether there is currently a subscriber on this [Stream]. */
  bool get _hasListener => _subscriber != null;

  // -------------------------------------------------------------------
  // Internal implementation.

  _SingleStreamImpl() {
    // Start out paused.
    _updatePauseCount(1);
  }

  /**
   * Create the new subscription object.
   */
  _StreamSubscriptionImpl<T> _createSubscription(
      void onData(T data),
      void onError(error),
      void onDone(),
      bool cancelOnError) {
    return new _StreamSubscriptionImpl<T>(
        this, onData, onError, onDone, cancelOnError);
  }

  void _addListener(_StreamListener subscription) {
    assert(!_isComplete);
    if (_hasListener) {
      throw new StateError("Stream already has subscriber.");
    }
    assert(_pauseCount == 1);
    _updatePauseCount(-1);
    _subscriber = subscription;
    subscription._setSubscribed(0);
    if (_isInactive) {
      _checkCallbacks(false, true);
      if (!_isPaused && _hasPendingEvent) {
        _schedulePendingEvents();
      }
    }
  }

  /**
   * Handle a cancel requested from a [_StreamSubscriptionImpl].
   *
   * This method is called from [_StreamSubscriptionImpl.cancel].
   */
  void _cancel(_StreamListener subscriber) {
    assert(identical(subscriber._source, this));
    // We allow unsubscribing the currently firing subscription during
    // the event firing, because it is indistinguishable from delaying it since
    // that event has already received the event.
    if (!identical(_subscriber, subscriber)) {
      // You may unsubscribe more than once, only the first one counts.
      return;
    }
    _subscriber = null;
    // Unsubscribing a paused subscription also cancels its pauses.
    int resumeCount = subscriber._setUnsubscribed();
    // Keep being paused while there is no subscriber and the stream is not
    // complete.
    _updatePauseCount(_isComplete ? -resumeCount : -resumeCount + 1);
    if (_isInactive) {
      _checkCallbacks(true, resumeCount > 0);
      if (!_isPaused && _hasPendingEvent) {
        _schedulePendingEvents();
      }
    }
  }

  void _forEachSubscriber(
      void action(_StreamListener<T> subscription)) {
    assert(!_isPaused);
    bool wasInputPaused = _isInputPaused;
    _StreamListener subscription = _subscriber;
    assert(subscription != null);
    _startFiring();
    action(subscription);
    _endFiring(wasInputPaused);
  }
}

// -------------------------------------------------------------------
// Default implementation of a stream with subscribers.
// -------------------------------------------------------------------

/**
 * Default implementation of stream capable of sending events to subscribers.
 *
 * Any class needing to implement [Stream] can either directly extend this
 * class, or extend [Stream] and delegate the subscribe method to an instance
 * of this class.
 *
 * The only public methods are those of [Stream], so instances of
 * [_MultiStreamImpl] can be returned directly as a [Stream] without exposing
 * internal functionality.
 *
 * The [StreamController] is a public facing version of this class, with
 * some methods made public.
 *
 * The user interface of [_MultiStreamImpl] are the following methods:
 * * [_add]: Add a data event to the stream.
 * * [_addError]: Add an error event to the stream.
 * * [_close]: Request to close the stream.
 * * [_onSubscriptionStateChange]: Called when receiving the first subscriber or
 *                                 when losing the last subscriber.
 * * [_onPauseStateChange]: Called when entering or leaving paused mode.
 * * [_hasListener]: Test whether there are currently any subscribers.
 * * [_isPaused]: Test whether the stream is currently paused.
 * The user should not add new events while the stream is paused, but if it
 * happens anyway, the stream will enqueue the events just as when new events
 * arrive while still firing an old event.
 */
class _MultiStreamImpl<T> extends _StreamImpl<T>
                          implements _InternalLinkList {
  // Link list implementation (mixin when possible).
  _InternalLink _nextLink;
  _InternalLink _previousLink;

  _MultiStreamImpl() {
    _nextLink = _previousLink = this;
  }

  bool get isBroadcast => true;

  Stream<T> asBroadcastStream() => this;

  // ------------------------------------------------------------------
  // Helper functions that can be overridden in subclasses.

  /** Whether there are currently any subscribers on this [Stream]. */
  bool get _hasListener => !_InternalLinkList.isEmpty(this);

  /**
   * Create the new subscription object.
   */
  _StreamListener<T> _createSubscription(
      void onData(T data),
      void onError(error),
      void onDone(),
      bool cancelOnError) {
    return new _StreamSubscriptionImpl<T>(
        this, onData, onError, onDone, cancelOnError);
  }

  // -------------------------------------------------------------------
  // Internal implementation.

  /**
   * Iterate over all current subscribers and perform an action on each.
   *
   * The set of subscribers cannot be modified during this iteration.
   * All attempts to add or unsubscribe subscribers will be delayed until
   * after the iteration is complete.
   *
   * The [action] must not throw, or the controller will be left in an
   * invalid state.
   *
   * This method must not be called while [isFiring] is true.
   */
  void _forEachSubscriber(
      void action(_StreamListener<T> subscription)) {
    assert(!_isFiring);
    if (!_hasListener) return;
    bool wasInputPaused = _isInputPaused;
    _startFiring();
    _InternalLink cursor = this._nextLink;
    while (!identical(cursor, this)) {
      _StreamListener<T> current = cursor;
      if (current._needsEvent(_currentEventIdBit)) {
        action(current);
        // Marks as having received the event.
        current._toggleEventReceived();
      }
      cursor = current._nextLink;
      if (current._isPendingUnsubscribe) {
        _removeListener(current);
      }
    }
    _endFiring(wasInputPaused);
  }

  void _addListener(_StreamListener listener) {
    listener._setSubscribed(_currentEventIdBit);
    bool hadListener = _hasListener;
    _InternalLinkList.add(this, listener);
    if (!hadListener && _isInactive) {
      _checkCallbacks(false, false);
      if (!_isPaused && _hasPendingEvent) {
        _schedulePendingEvents();
      }
    }
  }

  /**
   * Handle a cancel requested from a [_StreamListener].
   *
   * This method is called from [_StreamListener.cancel].
   *
   * If an event is currently firing, the cancel is delayed
   * until after the subscribers have received the event.
   */
  void _cancel(_StreamListener listener) {
    assert(identical(listener._source, this));
    if (_InternalLink.isUnlinked(listener)) {
      // You may unsubscribe more than once, only the first one counts.
      return;
    }
    if (_isFiring) {
      if (listener._needsEvent(_currentEventIdBit)) {
        assert(listener._isSubscribed);
        listener._setPendingUnsubscribe(_currentEventIdBit);
      } else {
        // The listener has been notified of the event (or don't need to,
        // if it's still pending subscription) so it's safe to remove it.
        _removeListener(listener);
      }
      // Pause and subscription state changes are reported when we end
      // firing.
    } else {
      bool wasInputPaused = _isInputPaused;
      _removeListener(listener);
      if (_isInactive) {
        _checkCallbacks(true, wasInputPaused);
        if (!_isPaused && _hasPendingEvent) {
          _schedulePendingEvents();
        }
      }
    }
  }

  /**
   * Removes a listener from this stream and cancels its pauses.
   *
   * This is a low-level action that doesn't call [_onSubscriptionStateChange].
   * or [_callOnPauseStateChange].
   */
  void _removeListener(_StreamListener listener) {
    int pauseCount = listener._setUnsubscribed();
    _InternalLinkList.remove(listener);
    if (pauseCount > 0) {
      _updatePauseCount(-pauseCount);
      if (!_isPaused && _hasPendingEvent) {
        _state |= _STREAM_PENDING_RESUME;
      }
    }
  }
}


/** Stream that generates its own events. */
class _GeneratedSingleStreamImpl<T> extends _SingleStreamImpl<T> {
  /**
   * Initializes the stream to have only the events provided by [events].
   *
   * A [_PendingEvents] implementation provides events that are handled
   * by calling [_PendingEvents.handleNext] with the [_StreamImpl].
   */
  _GeneratedSingleStreamImpl(_PendingEvents events) {
    _pendingEvents = events;
    _setClosed();  // Closed for input since all events are already pending.
  }

  void _add(T value) {
    throw new UnsupportedError("Cannot inject events into generated stream");
  }

  void _addError(value) {
    throw new UnsupportedError("Cannot inject events into generated stream");
  }

  void _close() {
    throw new UnsupportedError("Cannot inject events into generated stream");
  }
}


/** Pending events object that gets its events from an [Iterable]. */
class _IterablePendingEvents<T> extends _PendingEvents {
  final Iterator<T> _iterator;
  /**
   * Whether there are no more events to be sent.
   *
   * This starts out as [:false:] since there is always at least
   * a 'done' event to be sent.
   */
  bool _isDone = false;

  _IterablePendingEvents(Iterable<T> data) : _iterator = data.iterator;

  bool get isEmpty => _isDone;

  void handleNext(_StreamImpl<T> stream) {
    if (_isDone) throw new StateError("No events pending.");
    try {
      _isDone = !_iterator.moveNext();
      if (!_isDone) {
        stream._sendData(_iterator.current);
      } else {
        stream._sendDone();
      }
    } catch (e, s) {
      stream._sendError(_asyncError(e, s));
      stream._sendDone();
      _isDone = true;
    }
  }
}


/**
 * The subscription class that the [StreamController] uses.
 *
 * The [_StreamImpl.createSubscription] method should
 * create an object of this type, or another subclass of [_StreamListener].
 * A subclass of [_StreamImpl] can specify which subclass
 * of [_StreamSubscriptionImpl] it uses by overriding
 * [_StreamImpl.createSubscription].
 *
 * The subscription is in one of three states:
 * * Subscribed.
 * * Paused-and-subscribed.
 * * Unsubscribed.
 * Unsubscribing also resumes any pauses started by the subscription.
 */
class _StreamSubscriptionImpl<T> extends _StreamListener<T>
                                 implements StreamSubscription<T> {
  final bool _cancelOnError;
  // TODO(ahe): Restore type when feature is implemented in dart2js
  // checked mode. http://dartbug.com/7733
  var /* _DataHandler<T> */ _onData;
  _ErrorHandler _onError;
  _DoneHandler _onDone;
  _StreamSubscriptionImpl(_StreamImpl source,
                          this._onData,
                          this._onError,
                          this._onDone,
                          this._cancelOnError) : super(source);

  void onData(void handleData(T event)) {
    if (handleData == null) handleData = _nullDataHandler;
    _onData = handleData;
  }

  void onError(void handleError(error)) {
    if (handleError == null) handleError = _nullErrorHandler;
    _onError = handleError;
  }

  void onDone(void handleDone()) {
    if (handleDone == null) handleDone = _nullDoneHandler;
    _onDone = handleDone;
  }

  void _sendData(T data) {
    _onData(data);
  }

  void _sendError(error) {
    _onError(error);
    if (_cancelOnError) _source._cancel(this);
  }

  void _sendDone() {
    _onDone();
  }

  void cancel() {
    if (!_isSubscribed) return;
    _source._cancel(this);
  }

  void pause([Future resumeSignal]) {
    if (!_isSubscribed) return;
    _source._pause(this, resumeSignal);
  }

  void resume() {
    if (!_isSubscribed || !isPaused) return;
    _source._resume(this, false);
  }

  Future asFuture([var futureValue]) {
    _FutureImpl<T> result = new _FutureImpl<T>();

    // Overwrite the onDone and onError handlers.
    onDone(() { result._setValue(futureValue); });
    onError((error) {
      cancel();
      result._setError(error);
    });

    return result;
  }
}

// Internal helpers.

// Types of the different handlers on a stream. Types used to type fields.
typedef void _DataHandler<T>(T value);
typedef void _ErrorHandler(error);
typedef void _DoneHandler();


/** Default data handler, does nothing. */
void _nullDataHandler(var value) {}

/** Default error handler, reports the error to the global handler. */
void _nullErrorHandler(error) {
  _throwDelayed(error);
}

/** Default done handler, does nothing. */
void _nullDoneHandler() {}


/** A delayed event on a stream implementation. */
abstract class _DelayedEvent {
  /** Added as a linked list on the [StreamController]. */
  _DelayedEvent next;
  /** Execute the delayed event on the [StreamController]. */
  void perform(_StreamImpl stream);
}

/** A delayed data event. */
class _DelayedData<T> extends _DelayedEvent{
  final T value;
  _DelayedData(this.value);
  void perform(_StreamImpl<T> stream) {
    stream._sendData(value);
  }
}

/** A delayed error event. */
class _DelayedError extends _DelayedEvent {
  final error;
  _DelayedError(this.error);
  void perform(_StreamImpl stream) {
    stream._sendError(error);
  }
}

/** A delayed done event. */
class _DelayedDone implements _DelayedEvent {
  const _DelayedDone();
  void perform(_StreamImpl stream) {
    stream._sendDone();
  }

  _DelayedEvent get next => null;

  void set next(_DelayedEvent _) {
    throw new StateError("No events after a done.");
  }
}

/**
 * Simple internal doubly-linked list implementation.
 *
 * In an internal linked list, the links are in the data objects themselves,
 * instead of in a separate object. That means each element can be in at most
 * one list at a time.
 *
 * All links are always members of an element cycle. At creation it's a
 * singleton cycle.
 */
abstract class _InternalLink {
  _InternalLink _nextLink;
  _InternalLink _previousLink;

  _InternalLink() {
    this._previousLink = this._nextLink = this;
  }

  /* Removes a link from any list it may be part of, and links it to itself. */
  static void unlink(_InternalLink element) {
    _InternalLink next = element._nextLink;
    _InternalLink previous = element._previousLink;
    next._previousLink = previous;
    previous._nextLink = next;
    element._nextLink = element._previousLink = element;
  }

  /** Check whether an element is unattached to other elements. */
  static bool isUnlinked(_InternalLink element) {
    return identical(element, element._nextLink);
  }
}

/**
 * Marker interface for "list" links.
 *
 * An "InternalLinkList" is an abstraction on top of a link cycle, where the
 * "list" object itself is not considered an element (it's just a header link
 * created to avoid edge cases).
 * An element is considered part of a list if it is in the list's cycle.
 * There should never be more than one "list" object in a cycle.
 */
abstract class _InternalLinkList extends _InternalLink {
  /**
   * Adds an element to a list, just before the header link.
   *
   * This effectively adds it at the end of the list.
   */
  static void add(_InternalLinkList list, _InternalLink element) {
    if (!_InternalLink.isUnlinked(element)) _InternalLink.unlink(element);
    _InternalLink listEnd = list._previousLink;
    listEnd._nextLink = element;
    list._previousLink = element;
    element._previousLink = listEnd;
    element._nextLink = list;
  }

  /** Removes an element from its list. */
  static void remove(_InternalLink element) {
    _InternalLink.unlink(element);
  }

  /** Check whether a list contains no elements, only the header link. */
  static bool isEmpty(_InternalLinkList list) => _InternalLink.isUnlinked(list);

  /** Moves all elements from the list [other] to [list]. */
  static void addAll(_InternalLinkList list, _InternalLinkList other) {
    if (isEmpty(other)) return;
    _InternalLink listLast = list._previousLink;
    _InternalLink otherNext = other._nextLink;
    listLast._nextLink = otherNext;
    otherNext._previousLink = listLast;
    _InternalLink otherLast = other._previousLink;
    list._previousLink = otherLast;
    otherLast._nextLink = list;
    // Clean up [other].
    other._nextLink = other._previousLink = other;
  }
}

/** Abstract type for an internal interface for sending events. */
abstract class _EventOutputSink<T> {
  _sendData(T data);
  _sendError(error);
  _sendDone();
}

abstract class _StreamListener<T> extends _InternalLink
                                  implements _EventOutputSink<T> {
  final _StreamImpl _source;
  int _state = _LISTENER_UNSUBSCRIBED;

  _StreamListener(this._source);

  bool get isPaused => _state >= (1 << _LISTENER_PAUSE_COUNT_SHIFT);

  bool get _isPendingUnsubscribe =>
      (_state & _LISTENER_PENDING_UNSUBSCRIBE) != 0;

  bool get _isSubscribed => (_state & _LISTENER_SUBSCRIBED) != 0;

  /**
   * Whether the listener still needs to receive the currently firing event.
   *
   * The currently firing event is identified by a single bit, which alternates
   * between events. The [_state] contains the previously sent event's bit in
   * the [_LISTENER_EVENT_ID] bit. If the two don't match, this listener
   * still need the current event.
   */
  bool _needsEvent(int currentEventIdBit) {
    int lastEventIdBit =
        (_state & _LISTENER_EVENT_ID) >> _LISTENER_EVENT_ID_SHIFT;
    return lastEventIdBit != currentEventIdBit;
  }

  /// If a subscriber's "firing bit" doesn't match the stream's firing bit,
  /// we are currently firing an event and the subscriber still need to receive
  /// the event.
  void _toggleEventReceived() {
    _state ^= _LISTENER_EVENT_ID;
  }

  void _setSubscribed(int eventIdBit) {
    assert(eventIdBit == 0 || eventIdBit == 1);
    _state = _LISTENER_SUBSCRIBED | (eventIdBit << _LISTENER_EVENT_ID_SHIFT);
  }

  void _setPendingUnsubscribe(int currentEventIdBit) {
    assert(_isSubscribed);
    // Sets the pending unsubscribe, and ensures that the listener
    // won't get the current event.
    _state |= _LISTENER_PENDING_UNSUBSCRIBE | _LISTENER_EVENT_ID;
    _state ^= (1 ^ currentEventIdBit) << _LISTENER_EVENT_ID_SHIFT;
    assert(!_needsEvent(currentEventIdBit));
  }

  /**
   * Marks the listener as unsubscibed.
   *
   * Returns the number of unresumed pauses for the listener.
   */
  int _setUnsubscribed() {
    assert(_isSubscribed);
    int timesPaused = _state >> _LISTENER_PAUSE_COUNT_SHIFT;
    _state = _LISTENER_UNSUBSCRIBED;
    return timesPaused;
  }

  void _incrementPauseCount() {
    _state += 1 << _LISTENER_PAUSE_COUNT_SHIFT;
  }

  void _decrementPauseCount() {
    assert(isPaused);
    _state -= 1 << _LISTENER_PAUSE_COUNT_SHIFT;
  }

  _sendData(T data);
  _sendError(error);
  _sendDone();
}

/** Superclass for provider of pending events. */
abstract class _PendingEvents {
  /**
   * Timer set when pending events are scheduled for execution.
   *
   * When scheduling pending events for execution in a later cycle, the timer
   * is stored here. If pending events are executed earlier than that, e.g.,
   * due to a second event in the current cycle, the timer is canceled again.
   */
  Timer scheduleTimer = null;

  bool get isEmpty;

  bool get isScheduled => scheduleTimer != null;

  void schedule(_StreamImpl stream) {
    if (isScheduled) return;
    scheduleTimer = new Timer(Duration.ZERO, () {
      scheduleTimer = null;
      stream._handlePendingEvents();
    });
  }

  void cancelSchedule() {
    assert(isScheduled);
    scheduleTimer.cancel();
    scheduleTimer = null;
  }

  void handleNext(_StreamImpl stream);
}


/** Class holding pending events for a [_StreamImpl]. */
class _StreamImplEvents extends _PendingEvents {
  /// Single linked list of [_DelayedEvent] objects.
  _DelayedEvent firstPendingEvent = null;
  /// Last element in the list of pending events. New events are added after it.
  _DelayedEvent lastPendingEvent = null;

  bool get isEmpty => lastPendingEvent == null;

  bool get isScheduled => scheduleTimer != null;

  void add(_DelayedEvent event) {
    if (lastPendingEvent == null) {
      firstPendingEvent = lastPendingEvent = event;
    } else {
      lastPendingEvent = lastPendingEvent.next = event;
    }
  }

  void handleNext(_StreamImpl stream) {
    assert(!isScheduled);
    _DelayedEvent event = firstPendingEvent;
    firstPendingEvent = event.next;
    if (firstPendingEvent == null) {
      lastPendingEvent = null;
    }
    event.perform(stream);
  }
}


class _DoneSubscription<T> implements StreamSubscription<T> {
  _DoneHandler _handler;
  Timer _timer;
  int _pauseCount = 0;

  _DoneSubscription(this._handler) {
    _delayDone();
  }

  void _delayDone() {
    assert(_timer == null && _pauseCount == 0);
    _timer = new Timer(Duration.ZERO, () {
      if (_handler != null) _handler();
    });
  }

  bool get _isComplete => _timer == null && _pauseCount == 0;

  void onData(void handleAction(T value)) {}

  void onError(void handleError(error)) {}

  void onDone(void handleDone()) {
    _handler = handleDone;
  }

  void pause([Future signal]) {
    if (_isComplete) return;
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    _pauseCount++;
    if (signal != null) signal.whenComplete(resume);
  }

  void resume() {
    if (_isComplete) return;
    if (_pauseCount == 0) return;
    _pauseCount--;
    if (_pauseCount == 0) {
      _delayDone();
    }
  }

  bool get isPaused => _pauseCount > 0;

  void cancel() {
    if (_isComplete) return;
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    _pauseCount = 0;
  }

  Future asFuture([var futureValue]) {
    // TODO(floitsch): share more code.
    _FutureImpl<T> result = new _FutureImpl<T>();

    // Overwrite the onDone and onError handlers.
    onDone(() { result._setValue(futureValue); });
    onError((error) {
      cancel();
      result._setError(error);
    });

    return result;
  }
}

class _SingleStreamMultiplexer<T> extends _MultiStreamImpl<T> {
  final Stream<T> _source;
  StreamSubscription<T> _subscription;

  _SingleStreamMultiplexer(this._source);

  void _callOnPauseStateChange() {
    if (_isPaused) {
      if (_subscription != null) {
        _subscription.pause();
      }
    } else {
      if (_subscription != null) {
        _subscription.resume();
      }
    }
  }

  /**
    * Subscribe or unsubscribe on [_source] depending on whether
    * [_stream] has subscribers.
    */
  void _onSubscriptionStateChange() {
    if (_hasListener) {
      assert(_subscription == null);
      _subscription = _source.listen(this._add,
                                     onError: this._addError,
                                     onDone: this._close);
    } else {
      // TODO(lrn): Check why this can happen.
      if (_subscription == null) return;
      _subscription.cancel();
      _subscription = null;
    }
  }
}
