// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.io;

class FileSystemEntityType {
  static const FILE = const FileSystemEntityType._internal(0);
  static const DIRECTORY = const FileSystemEntityType._internal(1);
  static const LINK = const FileSystemEntityType._internal(2);
  static const NOT_FOUND = const FileSystemEntityType._internal(3);
  static const _typeList = const [FileSystemEntityType.FILE,
                                  FileSystemEntityType.DIRECTORY,
                                  FileSystemEntityType.LINK,
                                  FileSystemEntityType.NOT_FOUND];
  const FileSystemEntityType._internal(int this._type);

  static FileSystemEntityType _lookup(int type) => _typeList[type];
  String toString() => const ['FILE', 'DIRECTORY', 'LINK', 'NOT_FOUND'][_type];

  final int _type;
}

/**
 * A [FileSystemEntity] is a common super class for [File] and
 * [Directory] objects.
 *
 * [FileSystemEntity] objects are returned from directory listing
 * operations. To determine if a FileSystemEntity is a [File] or a
 * [Directory], perform a type check:
 *
 *     if (entity is File) (entity as File).readAsStringSync();
 */
abstract class FileSystemEntity {
  String get path;

  external static _getType(String path, bool followLinks);
  external static _identical(String path1, String path2);

  static int _getTypeSync(String path, bool followLinks) {
    var result = _getType(path, followLinks);
    _throwIfError(result, 'Error getting type of FileSystemEntity');
    return result;
  }

  static Future<int> _getTypeAsync(String path, bool followLinks) {
    // Get a new file service port for each request.  We could also cache one.
    var service = _FileUtils._newServicePort();
    List request = new List(3);
    request[0] = _TYPE_REQUEST;
    request[1] = path;
    request[2] = followLinks;
    return service.call(request).then((response) {
      if (_isErrorResponse(response)) {
        throw _exceptionFromResponse(response,
                                     "Error getting type of '$path'");
      }
      return response;
    });
  }

  /**
   * Do two paths refer to the same object in the file system?
   * Links are not identical to their targets, and two links
   * are not identical just because they point to identical targets.
   * Links in intermediate directories in the paths are followed, though.
   *
   * Throws an error if one of the paths points to an object that does not
   * exist.
   * The target of a link can be compared by first getting it with Link.target.
   */
  static Future<bool> identical(String path1, String path2) {
    // Get a new file service port for each request.  We could also cache one.
    var service = _FileUtils._newServicePort();
    List request = new List(3);
    request[0] = _IDENTICAL_REQUEST;
    request[1] = path1;
    request[2] = path2;
    return service.call(request).then((response) {
      if (_isErrorResponse(response)) {
        throw _exceptionFromResponse(response,
            "Error in FileSystemEntity.identical($path1, $path2)");
      }
      return response;
    });
  }


  /**
   * Do two paths refer to the same object in the file system?
   * Links are not identical to their targets, and two links
   * are not identical just because they point to identical targets.
   * Links in intermediate directories in the paths are followed, though.
   *
   * Throws an error if one of the paths points to an object that does not
   * exist.
   * The target of a link can be compared by first getting it with Link.target.
   */
  static bool identicalSync(String path1, String path2) {
    var result = _identical(path1, path2);
    _throwIfError(result, 'Error in FileSystemEntity.identicalSync');
    return result;
  }

  static Future<FileSystemEntityType> type(String path,
                                           {bool followLinks: true})
      => _getTypeAsync(path, followLinks).then(FileSystemEntityType._lookup);

  static FileSystemEntityType typeSync(String path, {bool followLinks: true})
      => FileSystemEntityType._lookup(_getTypeSync(path, followLinks));

  static Future<bool> isLink(String path) => _getTypeAsync(path, false)
      .then((type) => (type == FileSystemEntityType.LINK._type));

  static Future<bool> isFile(String path) => _getTypeAsync(path, true)
      .then((type) => (type == FileSystemEntityType.FILE._type));

  static Future<bool> isDirectory(String path) => _getTypeAsync(path, true)
      .then((type) => (type == FileSystemEntityType.DIRECTORY._type));

  static bool isLinkSync(String path) =>
      (_getTypeSync(path, false) == FileSystemEntityType.LINK._type);

  static bool isFileSync(String path) =>
      (_getTypeSync(path, true) == FileSystemEntityType.FILE._type);

  static bool isDirectorySync(String path) =>
      (_getTypeSync(path, true) == FileSystemEntityType.DIRECTORY._type);

  static _throwIfError(Object result, String msg) {
    if (result is OSError) {
      throw new FileIOException(msg, result);
    } else if (result is ArgumentError) {
      throw result;
    }
  }
}
