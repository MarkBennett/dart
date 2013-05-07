// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.io;

class _HttpBodyHandlerTransformer
    extends StreamEventTransformer<HttpRequest, HttpRequestBody> {
  void handleData(HttpRequest request, EventSink<HttpRequestBody> sink) {
    HttpBodyHandler.processRequest(request)
        .then(sink.add, onError: sink.addError);
  }
}

class _HttpBodyHandler {
  static Future<HttpRequestBody> processRequest(HttpRequest request) {
    return process(request, request.headers)
        .then((body) => new _HttpRequestBody(request, body),
              onError: (error) {
                // Try to send BAD_REQUEST response.
                request.response.statusCode = HttpStatus.BAD_REQUEST;
                request.response.close();
                request.response.done.catchError((_) {});
                throw error;
              });
  }

  static Future<HttpClientResponseBody> processResponse(
      HttpClientResponse response) {
    return process(response, response.headers)
        .then((body) => new _HttpClientResponseBody(response, body));
  }

  static Future<HttpBody> process(Stream<List<int>> stream,
                                  HttpHeaders headers) {
    ContentType contentType = headers.contentType;

    Future<HttpBody> asBinary() {
      return stream
          .fold(new _BufferList(), (buffer, data) => buffer..add(data))
          .then((buffer) => new _HttpBody(contentType,
                                          "binary",
                                          buffer.readBytes()));
    }

    Future<HttpBody> asText(Encoding defaultEncoding) {
      var encoding;
      var charset = contentType.charset;
      if (charset != null) encoding = Encoding.fromName(charset);
      if (encoding == null) encoding = defaultEncoding;
      return stream
          .transform(new StringDecoder(encoding))
          .fold(new StringBuffer(), (buffer, data) => buffer..write(data))
          .then((buffer) => new _HttpBody(contentType,
                                          "text",
                                          buffer.toString()));
    }

    Future<HttpBody> asFormData() {
      return stream
          .transform(new MimeMultipartTransformer(
                contentType.parameters['boundary']))
          .map((HttpMultipartFormData.parse))
          .map((multipart) {
            var future;
            if (multipart.isText) {
              future = multipart
                  .fold(new StringBuffer(), (b, s) => b..write(s))
                  .then((b) => b.toString());
            } else {
              future = multipart
                  .fold(new _BufferList(), (b, d) => b..add(d))
                  .then((b) => b.readBytes());
            }
            return future.then((data) {
              var filename =
                  multipart.contentDisposition.parameters['filename'];
              if (filename != null) {
                data = new _HttpBodyFileUpload(multipart.contentType,
                                               filename,
                                               data);
              }
              return [multipart.contentDisposition.parameters['name'], data];
            });
          })
          .fold([], (l, f) => l..add(f))
          .then(Future.wait)
          .then((parts) {
            Map<String, dynamic> map = new Map<String, dynamic>();
            for (var part in parts) {
              map[part[0]] = part[1];  // Override existing entries.
            }
            return new _HttpBody(contentType, 'form', map);
          });
    }

    if (contentType == null) {
      return asBinary();
    }

    switch (contentType.primaryType) {
      case "text":
        return asText(Encoding.ASCII);

      case "application":
        switch (contentType.subType) {
          case "json":
            return asText(Encoding.UTF_8)
                .then((body) => new _HttpBody(contentType,
                                              "json",
                                              JSON.parse(body.body)));

          default:
            break;
        }
        break;

      case "multipart":
        switch (contentType.subType) {
          case "form-data":
            return asFormData();

          default:
            break;
        }
        break;

      default:
        break;
    }

    return asBinary();
  }
}

class _HttpBodyFileUpload implements HttpBodyFileUpload {
  final ContentType contentType;
  final String filename;
  final dynamic content;
  _HttpBodyFileUpload(this.contentType, this.filename, this.content);
}

class _HttpBody implements HttpBody {
  final ContentType contentType;
  final String type;
  final dynamic body;

  _HttpBody(ContentType this.contentType,
            String this.type,
            dynamic this.body);
}

class _HttpRequestBody extends _HttpBody implements HttpRequestBody {
  final String method;
  final Uri uri;
  final HttpHeaders headers;
  final HttpResponse response;

  _HttpRequestBody(HttpRequest request, HttpBody body)
      : super(body.contentType, body.type, body.body),
        method = request.method,
        uri = request.uri,
        headers = request.headers,
        response = request.response;
}

class _HttpClientResponseBody
    extends _HttpBody implements HttpClientResponseBody {
  final HttpClientResponse response;

  _HttpClientResponseBody(HttpClientResponse response, HttpBody body)
      : super(body.contentType, body.type, body.body),
        this.response = response;

  int get statusCode => response.statusCode;

  String get reasonPhrase => response.reasonPhrase;

  HttpHeaders get headers => response.headers;
}
