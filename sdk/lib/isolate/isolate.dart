// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dart.isolate;

import "dart:async";

part "isolate_stream.dart";

class IsolateSpawnException implements Exception {
  const IsolateSpawnException(String this._s);
  String toString() => "IsolateSpawnException: '$_s'";
  final String _s;
}

/**
 * The initial [ReceivePort] available by default for this isolate. This
 * [ReceivePort] is created automatically and it is commonly used to establish
 * the first communication between isolates (see [spawnFunction] and
 * [spawnUri]).
 */
ReceivePort get port => _Isolate.port;

/**
 * Creates and spawns an isolate that shares the same code as the current
 * isolate, but that starts from [topLevelFunction]. The [topLevelFunction]
 * argument must be a static top-level function or a static method that takes no
 * arguments. It is illegal to pass a function closure.
 *
 * When any isolate starts (even the main script of the application), a default
 * [ReceivePort] is created for it. This port is available from the top-level
 * getter [port] defined in this library.
 *
 * [spawnFunction] returns a [SendPort] derived from the child isolate's default
 * port.
 *
 * The optional [unhandledExceptionCallback] argument is invoked whenever an
 * exception inside the isolate is unhandled. It can be seen as a big
 * `try/catch` around everything that is executed inside the isolate. The
 * callback should return `true` when it was able to handled the exception.
 */
SendPort spawnFunction(void topLevelFunction(),
    [bool unhandledExceptionCallback(IsolateUnhandledException e)])
    => _Isolate.spawnFunction(topLevelFunction, unhandledExceptionCallback);

/**
 * Creates and spawns an isolate whose code is available at [uri].  Like with
 * [spawnFunction], the child isolate will have a default [ReceivePort], and a
 * this function returns a [SendPort] derived from it.
 */
SendPort spawnUri(String uri) => _Isolate.spawnUri(uri);

/**
 * [SendPort]s are created from [ReceivePort]s. Any message sent through
 * a [SendPort] is delivered to its respective [ReceivePort]. There might be
 * many [SendPort]s for the same [ReceivePort].
 *
 * [SendPort]s can be transmitted to other isolates.
 */
abstract class SendPort {

  /**
   * Sends an asynchronous [message] to this send port. The message is copied to
   * the receiving isolate. If specified, the [replyTo] port will be provided to
   * the receiver to facilitate exchanging sequences of messages.
   *
   * The content of [message] can be: primitive values (null, num, bool, double,
   * String), instances of [SendPort], and lists and maps whose elements are any
   * of these. List and maps are also allowed to be cyclic.
   *
   * In the special circumstances when two isolates share the same code and are
   * running in the same process (e.g. isolates created via [spawnFunction]), it
   * is also possible to send object instances (which would be copied in the
   * process). This is currently only supported by the dartvm.  For now, the
   * dart2js compiler only supports the restricted messages described above.
   *
   * Deprecation note: it is no longer valid to transmit a [ReceivePort] in a
   * message. Previously they were translated to the corresponding send port
   * before being transmitted.
   */
  void send(var message, [SendPort replyTo]);

  /**
   * Sends a message to this send port and returns a [Future] of the reply.
   * Basically, this internally creates a new receive port, sends a
   * message to this send port with replyTo set to such receive port, and, when
   * a reply is received, it closes the receive port and completes the returned
   * future.
   */
  Future call(var message);

  /**
   * Tests whether [other] is a [SendPort] pointing to the same
   * [ReceivePort] as this one.
   */
  bool operator==(var other);

  /**
   * Returns an immutable hash code for this send port that is
   * consistent with the == operator.
   */
  int get hashCode;

}

/**
 * [ReceivePort]s, together with [SendPort]s, are the only means of
 * communication between isolates. [ReceivePort]s have a [:toSendPort:] method
 * which returns a [SendPort]. Any message that is sent through this [SendPort]
 * is delivered to the [ReceivePort] it has been created from. There, they are
 * dispatched to the callback that has been registered on the receive port.
 *
 * A [ReceivePort] may have many [SendPort]s.
 */
abstract class ReceivePort {

  /**
   * Opens a long-lived port for receiving messages. The returned port
   * must be explicitly closed through [ReceivePort.close].
   */
  external factory ReceivePort();

  /**
   * Sets up a callback function for receiving pending or future
   * messages on this receive port.
   */
  void receive(void callback(var message, SendPort replyTo));

  /**
   * Closes this receive port immediately. Pending messages will not
   * be processed and it is impossible to re-open the port. Single-shot
   * reply ports, such as those created through [SendPort.call], are
   * automatically closed when the reply has been received. Multiple
   * invocations of [close] are allowed but ignored.
   */
  void close();

  /**
   * Creates a new send port that sends to this receive port. It is legal to
   * create several [SendPort]s from the same [ReceivePort].
   */
  SendPort toSendPort();

}

/**
 * [SendPortSync]s are created from [ReceivePortSync]s. Any message sent through
 * a [SendPortSync] is delivered to its respective [ReceivePortSync]. There
 * might be many [SendPortSync]s for the same [ReceivePortSync].
 *
 * [SendPortSync]s can be transmitted to other isolates.
 */
abstract class SendPortSync {
  /**
   * Sends a synchronous message to this send port and returns the result.
   */
  callSync(var message);

  /**
   * Tests whether [other] is a [SendPortSync] pointing to the same
   * [ReceivePortSync] as this one.
   */
  bool operator==(var other);

  /**
   * Returns an immutable hash code for this send port that is
   * consistent with the == operator.
   */
  int get hashCode;
}

// The VM doesn't support accessing external globals in the same library. We
// therefore create this wrapper class.
// TODO(6997): Don't go through static class for external variables.
abstract class _Isolate {
  external static ReceivePort get port;
  external static SendPort spawnFunction(void topLevelFunction(),
    [bool unhandledExceptionCallback(IsolateUnhandledException e)]);
  external static SendPort spawnUri(String uri);
}

/**
 * Wraps unhandled exceptions thrown during isolate execution. It is
 * used to show both the error message and the stack trace for unhandled
 * exceptions.
 */
class IsolateUnhandledException implements Exception {
  /** Message being handled when exception occurred. */
  final message;

  /** Wrapped exception. */
  final source;

  /** Trace for the wrapped exception. */
  final Object stackTrace;

  const IsolateUnhandledException(this.message, this.source, this.stackTrace);

  String toString() {
    return 'IsolateUnhandledException: exception while handling message: '
        '${message} \n  '
        '${source.toString().replaceAll("\n", "\n  ")}\n'
        'original stack trace:\n  '
        '${stackTrace.toString().replaceAll("\n","\n  ")}';
  }
}
