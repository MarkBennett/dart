// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library chat_server;
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:json' as json;
import 'dart:math';

void startChatServer() {
  var server = new ChatServer();
  server.init();
  port.receive(server.dispatch);
}

class ChatServer extends IsolatedServer {
}

class ServerMain {
  ServerMain.start(SendPort serverPort,
                   String hostAddress,
                   int tcpPort)
      : _statusPort = new ReceivePort(),
        _serverPort = serverPort {
    // We can only guess this is the right URL. At least it gives a
    // hint to the user.
    print('Server starting http://${hostAddress}:${tcpPort}/');
    _start(hostAddress, tcpPort);
  }

    void _start(String hostAddress, int tcpPort) {
    // Handle status messages from the server.
    _statusPort.receive((var message, SendPort replyTo) {
      String status = message.message;
      print("Received status: $status");
    });

    // Send server start message to the server.
    var command = new ChatServerCommand.start(hostAddress, tcpPort);
    _serverPort.send(command, _statusPort.toSendPort());
  }

  void shutdown() {
    // Send server stop message to the server.
    _serverPort.send(new ChatServerCommand.stop(), _statusPort.toSendPort());
    _statusPort.close();
  }

  ReceivePort _statusPort;  // Port for receiving messages from the server.
  SendPort _serverPort;  // Port for sending messages to the server.
}


class User {
  static int nextSessionId = 0;

  User(this._handle) {
    _sessionId = "a${nextSessionId++}";
    markActivity();
  }

  void markActivity() { _lastActive = new DateTime.now(); }
  Duration idleTime(DateTime now) => now.difference(_lastActive);

  String get handle => _handle;
  String get sessionId => _sessionId;

  String _handle;
  String _sessionId;
  DateTime _lastActive;
}


class Message {
  static const int JOIN = 0;
  static const int MESSAGE = 1;
  static const int LEAVE = 2;
  static const int TIMEOUT = 3;
  static const List<String> _typeName =
      const [ "join", "message", "leave", "timeout"];

  Message.join(this._from)
      : _received = new DateTime.now(), _type = JOIN;
  Message(this._from, this._message)
      : _received = new DateTime.now(), _type = MESSAGE;
  Message.leave(this._from)
      : _received = new DateTime.now(), _type = LEAVE;
  Message.timeout(this._from)
      : _received = new DateTime.now(), _type = TIMEOUT;

  User get from => _from;
  DateTime get received => _received;
  String get message => _message;
  void set messageNumber(int n) { _messageNumber = n; }

  Map toMap() {
    Map map = new Map();
    map["from"] = _from.handle;
    map["received"] = _received.toString();
    map["type"] = _typeName[_type];
    if (_type == MESSAGE) map["message"] = _message;
    map["number"] = _messageNumber;
    return map;
  }

  User _from;
  DateTime _received;
  int _type;
  String _message;
  int _messageNumber;
}


class Topic {
  static const int DEFAULT_IDLE_TIMEOUT = 60 * 60 * 1000;  // One hour.
  Topic()
      : _activeUsers = new Map(),
        _messages = new List(),
        _nextMessageNumber = 0,
        _callbacks = new Map();

  int get activeUsers => _activeUsers.length;

  User _userJoined(String handle) {
    User user = new User(handle);
    _activeUsers[user.sessionId] = user;
    Message message = new Message.join(user);
    _addMessage(message);
    return user;
  }

  User _userLookup(String sessionId) => _activeUsers[sessionId];

  void _userLeft(String sessionId) {
    User user = _userLookup(sessionId);
    Message message = new Message.leave(user);
    _addMessage(message);
    _activeUsers.remove(sessionId);
  }

  bool _addMessage(Message message) {
    message.messageNumber = _nextMessageNumber++;
    _messages.add(message);

    // Send the new message to all polling clients.
    List messages = new List();
    messages.add(message.toMap());
    _callbacks.forEach((String sessionId, Function callback) {
      callback(messages);
    });
    _callbacks = new Map();
  }

  bool _userMessage(Map requestData) {
    String sessionId = requestData["sessionId"];
    User user = _userLookup(sessionId);
    if (user == null) return false;
    String handle = user.handle;
    String messageText = requestData["message"];
    if (messageText == null) return false;

    // Add new message.
    Message message = new Message(user, messageText);
    _addMessage(message);
    user.markActivity();

    return true;
  }

  List messagesFrom(int messageNumber, int maxMessages) {
    if (_messages.length > messageNumber) {
      if (maxMessages != null) {
        if (_messages.length - messageNumber > maxMessages) {
          messageNumber = _messages.length - maxMessages;
        }
      }
      List messages = new List();
      for (int i = messageNumber; i < _messages.length; i++) {
        messages.add(_messages[i].toMap());
      }
      return messages;
    } else {
      return null;
    }
  }

  void registerChangeCallback(String sessionId, var callback) {
    _callbacks[sessionId] = callback;
  }

  void _handleTimer(Timer timer) {
    Set inactiveSessions = new Set();
    // Collect all sessions which have not been active for some time.
    DateTime now = new DateTime.now();
    _activeUsers.forEach((String sessionId, User user) {
      if (user.idleTime(now).inMilliseconds > DEFAULT_IDLE_TIMEOUT) {
        inactiveSessions.add(sessionId);
      }
    });
    // Terminate the inactive sessions.
    inactiveSessions.forEach((String sessionId) {
      Function callback = _callbacks.remove(sessionId);
      if (callback != null) callback(null);
      User user = _activeUsers.remove(sessionId);
      Message message = new Message.timeout(user);
      _addMessage(message);
    });
  }

  Map<String, User> _activeUsers;
  List<Message> _messages;
  int _nextMessageNumber;
  Map<String, Function> _callbacks;
}


class ChatServerCommand {
  static const START = 0;
  static const STOP = 1;

  ChatServerCommand.start(String this._host,
                          int this._port,
                          {bool logging: false})
      : _command = START, _logging = logging;
  ChatServerCommand.stop() : _command = STOP;

  bool get isStart => _command == START;
  bool get isStop => _command == STOP;

  String get host => _host;
  int get port => _port;
  bool get logging => _logging;

  int _command;
  String _host;
  int _port;
  bool _logging;
}


class ChatServerStatus {
  static const STARTING = 0;
  static const STARTED = 1;
  static const STOPPING = 2;
  static const STOPPED = 3;
  static const ERROR = 4;

  ChatServerStatus(this._state, this._message);
  ChatServerStatus.starting() : _state = STARTING;
  ChatServerStatus.started(this._port) : _state = STARTED;
  ChatServerStatus.stopping() : _state = STOPPING;
  ChatServerStatus.stopped() : _state = STOPPED;
  ChatServerStatus.error2([this._error]) : _state = ERROR;

  bool get isStarting => _state == STARTING;
  bool get isStarted => _state == STARTED;
  bool get isStopping => _state == STOPPING;
  bool get isStopped => _state == STOPPED;
  bool get isError => _state == ERROR;

  int get state => _state;
  String get message {
    if (_message != null) return _message;
    switch (_state) {
      case STARTING: return "Server starting";
      case STARTED: return "Server listening";
      case STOPPING: return "Server stopping";
      case STOPPED: return "Server stopped";
      case ERROR:
        if (_error == null) {
          return "Server error";
        } else {
          return "Server error: $_error";
        }
    }
  }

  int get port => _port;
  dynamic get error => _error;

  int _state;
  String _message;
  int _port;
  var _error;
}


class IsolatedServer {
  static const String redirectPageHtml = """
<html>
<head><title>Welcome to the dart server</title></head>
<body><h1>Redirecting to the front page...</h1></body>
</html>""";
  static const String notFoundPageHtml = """
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL was not found on this server.</p>
</body></html>""";

  void _sendJSONResponse(HttpResponse response, Map responseData) {
    response.headers.set("Content-Type", "application/json; charset=UTF-8");
    response.write(json.stringify(responseData));
    response.close();
  }

  void redirectPageHandler(HttpRequest request,
                           HttpResponse response,
                           String redirectPath) {
    if (_redirectPage == null) {
      _redirectPage = redirectPageHtml.codeUnits;
    }
    response.statusCode = HttpStatus.FOUND;
    response.headers.set(
        "Location", "http://$_host:$_port/${redirectPath}");
    response.contentLength = _redirectPage.length;
    response.add(_redirectPage);
    response.close();
  }

  // Serve the content of a file.
  void fileHandler(
      HttpRequest request, HttpResponse response, [String fileName = null]) {
    final int BUFFER_SIZE = 4096;
    if (fileName == null) {
      fileName = request.uri.path.substring(1);
    }
    File file = new File(fileName);
    if (file.existsSync()) {
      String mimeType = "text/html; charset=UTF-8";
      int lastDot = fileName.lastIndexOf(".", fileName.length);
      if (lastDot != -1) {
        String extension = fileName.substring(lastDot);
        if (extension == ".css") { mimeType = "text/css"; }
        if (extension == ".js") { mimeType = "application/javascript"; }
        if (extension == ".ico") { mimeType = "image/vnd.microsoft.icon"; }
        if (extension == ".png") { mimeType = "image/png"; }
      }
      response.headers.set("Content-Type", mimeType);
      // Get the length of the file for setting the Content-Length header.
      RandomAccessFile openedFile = file.openSync();
      response.contentLength = openedFile.lengthSync();
      openedFile.closeSync();
      // Pipe the file content into the response.
      file.openRead().pipe(response);
    } else {
      print("File not found: $fileName");
      _notFoundHandler(request, response);
    }
  }

  // Serve the not found page.
  void _notFoundHandler(HttpRequest request, HttpResponse response) {
    if (_notFoundPage == null) {
      _notFoundPage = notFoundPageHtml.codeUnits;
    }
    response.statusCode = HttpStatus.NOT_FOUND;
    response.headers.set("Content-Type", "text/html; charset=UTF-8");
    response.contentLength = _notFoundPage.length;
    response.add(_notFoundPage);
    response.close();
  }

  // Unexpected protocol data.
  void _protocolError(HttpRequest request, HttpResponse response) {
    response.statusCode = HttpStatus.INTERNAL_SERVER_ERROR;
    response.contentLength = 0;
    response.close();
  }

  // Join request:
  // { "request": "join",
  //   "handle": <handle> }
  void _joinHandler(HttpRequest request, HttpResponse response) {
    StringBuffer body = new StringBuffer();
    request.listen(
      (data) => body.write(new String.fromCharCodes(data)),
      onDone: () {
        String data = body.toString();
        if (data != null) {
          var requestData = json.parse(data);
          if (requestData["request"] == "join") {
            String handle = requestData["handle"];
            if (handle != null) {
              // New user joining.
              User user = _topic._userJoined(handle);

              // Send response.
              Map responseData = new Map();
              responseData["response"] = "join";
              responseData["sessionId"] = user.sessionId;
              _sendJSONResponse(response, responseData);
            } else {
              _protocolError(request, response);
            }
          } else {
            _protocolError(request, response);
          }
        } else {
          _protocolError(request, response);
        }
      });
  }

  // Leave request:
  // { "request": "leave",
  //   "sessionId": <sessionId> }
  void _leaveHandler(HttpRequest request, HttpResponse response) {
    StringBuffer body = new StringBuffer();
    request.listen(
      (data) => body.write(new String.fromCharCodes(data)),
      onDone: () {
        String data = body.toString();
        var requestData = json.parse(data);
        if (requestData["request"] == "leave") {
          String sessionId = requestData["sessionId"];
          if (sessionId != null) {
            // User leaving.
            _topic._userLeft(sessionId);

            // Send response.
            Map responseData = new Map();
            responseData["response"] = "leave";
            _sendJSONResponse(response, responseData);
          } else {
            _protocolError(request, response);
          }
        } else {
          _protocolError(request, response);
        }
      });
  }

  // Message request:
  // { "request": "message",
  //   "sessionId": <sessionId>,
  //   "message": <message> }
  void _messageHandler(HttpRequest request, HttpResponse response) {
    StringBuffer body = new StringBuffer();
    request.listen(
      (data) => body.write(new String.fromCharCodes(data)),
      onDone: () {
        String data = body.toString();
        _messageCount++;
        _messageRate.record(1);
        var requestData = json.parse(data);
        if (requestData["request"] == "message") {
          String sessionId = requestData["sessionId"];
          if (sessionId != null) {
            // New message from user.
            bool success = _topic._userMessage(requestData);

            // Send response.
            if (success) {
              Map responseData = new Map();
              responseData["response"] = "message";
              _sendJSONResponse(response, responseData);
            } else {
              _protocolError(request, response);
            }
          } else {
            _protocolError(request, response);
          }
        } else {
          _protocolError(request, response);
        }
      });
  }

  // Receive request:
  // { "request": "receive",
  //   "sessionId": <sessionId>,
  //   "nextMessage": <nextMessage>,
  //   "maxMessages": <maxMesssages> }
  void _receiveHandler(HttpRequest request, HttpResponse response) {
    StringBuffer body = new StringBuffer();
    request.listen(
      (data) => body.write(new String.fromCharCodes(data)),
      onDone: () {
        String data = body.toString();
        var requestData = json.parse(data);
        if (requestData["request"] == "receive") {
          String sessionId = requestData["sessionId"];
          int nextMessage = requestData["nextMessage"];
          int maxMessages = requestData["maxMessages"];
          if (sessionId != null && nextMessage != null) {

            void sendResponse(messages) {
              // Send response.
              Map responseData = new Map();
              responseData["response"] = "receive";
              if (messages != null) {
                responseData["messages"] = messages;
                responseData["activeUsers"] = _topic.activeUsers;
                responseData["upTime"] =
                    new DateTime.now().difference(_serverStart).inMilliseconds;
              } else {
                responseData["disconnect"] = true;
              }
              _sendJSONResponse(response, responseData);
            }

            // Receive request from user.
            List messages = _topic.messagesFrom(nextMessage, maxMessages);
            if (messages == null) {
              _topic.registerChangeCallback(sessionId, sendResponse);
            } else {
              sendResponse(messages);
            }

          } else {
            _protocolError(request, response);
          }
        } else {
          _protocolError(request, response);
        }
      });
  }

  void init() {
    _logRequests = false;
    _topic = new Topic();
    _serverStart = new DateTime.now();
    _messageCount = 0;
    _messageRate = new Rate();

    // Start a timer for cleanup events.
    _cleanupTimer = new Timer.periodic(const Duration(seconds: 10),
                                       _topic._handleTimer);
  }

  // Start timer for periodic logging.
  void _handleLogging(Timer timer) {
    if (_logging) {
      print("${_messageRate.rate} messages/s "
            "(total $_messageCount messages)");
    }
  }

  void dispatch(message, replyTo) {
    if (message.isStart) {
      _host = message.host;
      _port = message.port;
      _logging = message.logging;
      replyTo.send(new ChatServerStatus.starting(), null);
      var handlers = {};
      void addRequestHandler(String path, Function handler) {
        handlers[path] = handler;
      }
      addRequestHandler("/", (request, response) {
        redirectPageHandler(request, response, "dart_client/index.html");
      });
      addRequestHandler("/js_client/index.html", fileHandler);
      addRequestHandler("/js_client/code.js", fileHandler);
      addRequestHandler("/dart_client/index.html", fileHandler);
      addRequestHandler("/out.js", fileHandler);
      addRequestHandler("/favicon.ico", (request, response) {
        fileHandler(request, response, "static/favicon.ico");
      });
      addRequestHandler("/join", _joinHandler);
      addRequestHandler("/leave", _leaveHandler);
      addRequestHandler("/message", _messageHandler);
      addRequestHandler("/receive", _receiveHandler);
      HttpServer.bind(_host, _port)
          .then((s) {
            _server = s;
            _server.listen((request) {
              if (handlers.containsKey(request.uri.path)) {
                handlers[request.uri.path](request, request.response);
              } else {
                _notFoundHandler(request, request.response);
              }
            });
            replyTo.send(new ChatServerStatus.started(_server.port), null);
            _loggingTimer =
                new Timer.periodic(const Duration(seconds: 1), _handleLogging);
          })
          .catchError((e) {
            replyTo.send(new ChatServerStatus.error2(e.toString()), null);
          });
    } else if (message.isStop) {
      replyTo.send(new ChatServerStatus.stopping(), null);
      stop();
      replyTo.send(new ChatServerStatus.stopped(), null);
    }
  }

  stop() {
    _server.close();
    _cleanupTimer.cancel();
    port.close();
  }

  String _host;
  int _port;
  HttpServer _server;  // HTTP server instance.
  bool _logRequests;

  Topic _topic;
  Timer _cleanupTimer;
  Timer _loggingTimer;
  DateTime _serverStart;

  bool _logging;
  int _messageCount;
  Rate _messageRate;

  // Static HTML.
  List<int> _redirectPage;
  List<int> _notFoundPage;
}


// Calculate the rate of events over a given time range. The time
// range is split over a number of buckets where each bucket collects
// the number of events happening in that time sub-range. The first
// constructor arument specifies the time range in milliseconds. The
// buckets are in the list _buckets organized at a circular buffer
// with _currentBucket marking the bucket where an event was last
// recorded. A current sum of the content of all buckets except the
// one pointed a by _currentBucket is kept in _sum.
class Rate {
  Rate([int timeRange = 1000, int buckets = 10])
      : _timeRange = timeRange,
        _buckets = new List(buckets + 1),  // Current bucket is not in the sum.
        _currentBucket = 0,
        _currentBucketTime = new DateTime.now().millisecondsSinceEpoch,
        _sum = 0 {
    _bucketTimeRange = (_timeRange / buckets).toInt();
    for (int i = 0; i < _buckets.length; i++) {
      _buckets[i] = 0;
    }
  }

  // Record the specified number of events.
  void record(int count) {
    _timePassed();
    _buckets[_currentBucket] = _buckets[_currentBucket] + count;
  }

  // Returns the current rate of events for the time range.
  num get rate {
    _timePassed();
    return _sum;
  }

  // Update the current sum as time passes. If time has passed by the
  // current bucket add it to the sum and move forward to the bucket
  // matching the current time. Subtract all buckets vacated from the
  // sum as bucket for current time is located.
  void _timePassed() {
    int time = new DateTime.now().millisecondsSinceEpoch;
    if (time < _currentBucketTime + _bucketTimeRange) {
      // Still same bucket.
      return;
    }

    // Add collected bucket to the sum.
    _sum += _buckets[_currentBucket];

    // Find the bucket for the current time. Subtract all buckets
    // reused from the sum.
    while (time >= _currentBucketTime + _bucketTimeRange) {
      _currentBucket = (_currentBucket + 1) % _buckets.length;
      _sum -= _buckets[_currentBucket];
      _buckets[_currentBucket] = 0;
      _currentBucketTime += _bucketTimeRange;
    }
  }

  int _timeRange;
  List<int> _buckets;
  int _currentBucket;
  int _currentBucketTime;
  num _bucketTimeRange;
  int _sum;
}
