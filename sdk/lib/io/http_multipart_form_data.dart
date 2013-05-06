// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.io;


/**
 * [:HttpMultipartFormData:] class used for 'upgrading' a [MimeMultipart] by
 * parsing it as a 'multipart/form-data' part. The following code shows how
 * it can be used.
 *
 *   HttpServer server = ...;
 *   server.listen((request) {
 *     String boundary = request.headers.contentType.parameters['boundary'];
 *     request
 *         .transform(new MimeMultipartTransformer(boundary))
 *         .map(HttpMultipartFormData.parse)
 *         .map((HttpMultipartFormData formData) {
 *           // form data object available here.
 *         });
 *
 * [:HttpMultipartFormData:] is a Stream, serving either bytes or decoded
 * Strings. Use [isText] or [isBinary] to see what type of data is provided.
 */
abstract class HttpMultipartFormData implements Stream {
  /**
   * The parsed [:Content-Type:] header of the [:HttpMultipartFormData:].
   * Returns [:null:] if not present.
   */
  ContentType get contentType;

  /**
   * The parsed [:Content-Disposition:] header of the [:HttpMultipartFormData:].
   * This field is always present. Use this to extract e.g. name(form field
   * name)and filename (client provided name of uploaded file) parameters.
   */
  HeaderValue get contentDisposition;

  /**
   * The parsed [:Content-Transfer-Encoding:] header of the
   * [:HttpMultipartFormData:]. This field is used to determine how to decode
   * the data. Returns [:null:] if not present.
   */
  HeaderValue get contentTransferEncoding;

  /**
   * Returns [:true:] if the data is decoded as [String].
   */
  bool get isText;

  /**
   * Returns [:true:] if the data is raw bytes.
   */
  bool get isBinary;

  /**
   * Returns the value for the header named [name]. If there
   * is no header with the provided name, [:null:] will be returned.
   *
   * Use this method to index other headers available in the original
   * [MimeMultipart].
   */
  String value(String name);

  /**
   * Parse a [MimeMultipart] and return a [HttpMultipartFormData]. If the
   * [:Content-Disposition:] header is missing or invalid, a [HttpException] is
   * thrown.
   */
  static HttpMultipartFormData parse(MimeMultipart multipart)
      => _HttpMultipartFormData.parse(multipart);
}
