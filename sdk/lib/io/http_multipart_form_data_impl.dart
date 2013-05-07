// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.io;


class _HttpMultipartFormData extends Stream implements HttpMultipartFormData {
  final ContentType contentType;
  final HeaderValue contentDisposition;
  final HeaderValue contentTransferEncoding;

  final MimeMultipart _mimeMultipart;

  bool _isText = false;

  Stream _stream;

  _HttpMultipartFormData(ContentType this.contentType,
                         HeaderValue this.contentDisposition,
                         HeaderValue this.contentTransferEncoding,
                         MimeMultipart this._mimeMultipart) {
    _stream = _mimeMultipart;
    if (contentTransferEncoding != null) {
      // TODO(ajohnsen): Support BASE64, etc.
      throw new HttpException("Unsupported contentTransferEncoding: "
                              "${contentTransferEncoding.value}");
    }

    if (contentType == null ||
        contentType.primaryType == 'text' ||
        contentType.mimeType == 'application/json') {
      _isText = true;
      StringBuffer buffer = new StringBuffer();
      Encoding encoding;
      if (contentType != null) {
        encoding = Encoding.fromName(contentType.charset);
      }
      if (encoding == null) encoding = Encoding.ISO_8859_1;
      _stream = _stream
          .transform(new StringDecoder(encoding))
          .expand((data) {
            buffer.write(data);
            var out = _HttpUtils.decodeHttpEntityString(buffer.toString());
            if (out != null) {
              buffer = new StringBuffer();
              return [out];
            }
            return const [];
          });
    }
  }

  bool get isText => _isText;
  bool get isBinary => !_isText;

  static HttpMultipartFormData parse(MimeMultipart multipart) {
    var type;
    var encoding;
    var disposition;
    var remaining = new Map<String, String>();
    for (String key in multipart.headers.keys) {
      switch (key) {
        case HttpHeaders.CONTENT_TYPE:
          type = ContentType.parse(multipart.headers[key]);
          break;

        case 'content-transfer-encoding':
          encoding = HeaderValue.parse(multipart.headers[key]);
          break;

        case 'content-disposition':
          disposition = HeaderValue.parse(multipart.headers[key]);
          break;

        default:
          remaining[key] = multipart.headers[key];
          break;
      }
    }
    if (disposition == null) {
      throw new HttpException(
          "Mime Multipart doesn't contain a Content-Disposition header value");
    }
    return new _HttpMultipartFormData(type, disposition, encoding, multipart);
  }

  StreamSubscription listen(void onData(data),
                            {void onDone(),
                             void onError(error),
                             bool cancelOnError}) {
    return _stream.listen(onData,
                          onDone: onDone,
                          onError: onError,
                          cancelOnError: cancelOnError);
  }

  String value(String name) {
    return _mimeMultipart.headers[name];
  }
}

