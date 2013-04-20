// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library builtin;
import 'dart:uri';

// Corelib 'print' implementation.
void _print(arg) {
  _Logger._printString(arg.toString());
}

class _Logger {
  static void _printString(String s) native "Logger_PrintString";
}

_getPrintClosure() => _print;

// The URI that the entrypoint script was loaded from. Remembered so that
// package imports can be resolved relative to it.
var _entrypoint;

// The directory to look in to resolve "package:" scheme URIs.
var _packageRoot;

void _logResolution(String msg) {
  final enabled = false;
  if (enabled) {
    _Logger._printString(msg);
  }
}

_setPackageRoot(String packageRoot) {
  // TODO(mattsh) - refactor windows drive and path handling code
  // so it can be used here if needed.
  _packageRoot = packageRoot;
}

String _resolveScriptUri(String cwd, String scriptName, bool isWindows) {
  _logResolution("# Current working directory: $cwd");
  _logResolution("# ScriptName: $scriptName");
  if (isWindows) {
    // For Windows we need to massage the paths a bit according to
    // http://blogs.msdn.com/b/ie/archive/2006/12/06/file-uris-in-windows.aspx
    //
    // Convert
    // C:\one\two\three
    // to
    // /C:/one/two/three
    cwd = "/${cwd.replaceAll('\\', '/')}";
    _logResolution("## cwd: $cwd");
    if ((scriptName.length > 2) && (scriptName[1] == ":")) {
      // This is an absolute path.
      scriptName = "/${scriptName.replaceAll('\\', '/')}";
    } else {
      scriptName = scriptName.replaceAll('\\', '/');
    }
    _logResolution("## scriptName: $scriptName");
  }
  var base =
      new Uri.fromComponents(
          scheme: "file",
          path: cwd.endsWith("/") ? cwd : "$cwd/");
  _entrypoint = base.resolve(scriptName);
  _logResolution("# Resolved script to: $_entrypoint");

  return _entrypoint.toString();
}

String _resolveUri(String base, String userString) {
  var baseUri = Uri.parse(base);
  _logResolution("# Resolving: $userString from $base");

  var uri = Uri.parse(userString);
  var resolved;
  if ('dart-ext' == uri.scheme) {
    // Relative URIs with scheme dart-ext should be resolved as if with no
    // scheme.
    resolved = baseUri.resolve(uri.path);
    var path = resolved.path;
    if (resolved.scheme == 'package') {
      // If we are resolving relative to a package URI we go directly to the
      // file path and keep the dart-ext scheme. Otherwise, we will lose the
      // package URI path part.
      path = _filePathFromPackageUri(resolved);
    }
    resolved = new Uri.fromComponents(scheme: "dart-ext", path: path);
  } else {
    resolved = baseUri.resolve(userString);
  }
  _logResolution("# Resolved to: $resolved");
  return resolved.toString();
}


String _filePathFromUri(String userUri, bool isWindows) {
  var uri = Uri.parse(userUri);
  _logResolution("# Getting file path from: $uri");

  var path;
  switch (uri.scheme) {
    case 'file':
      path = _filePathFromFileUri(uri);
      break;
    case 'dart-ext':
      path = _filePathFromOtherUri(uri);
      break;
    case 'package':
      path = _filePathFromPackageUri(uri);
      break;
    default:
      // Only handling file and package URIs in standalone binary.
      _logResolution("# Unknown scheme (${uri.scheme}) in $uri.");
      throw "Not a known scheme: $uri";
  }

  if (isWindows && path.startsWith("/")) {
    // For Windows we need to massage the paths a bit according to
    // http://blogs.msdn.com/b/ie/archive/2006/12/06/file-uris-in-windows.aspx
    //
    // Drop the leading / before the drive letter.
    path = path.substring(1);
    _logResolution("# path: $path");
  }

  return path;
}

String _filePathFromFileUri(Uri uri) {
  if (uri.domain != '') {
    throw "URIs using the 'file:' scheme may not contain a domain.";
  }

  _logResolution("# Path: ${uri.path}");
  return uri.path;
}

String _filePathFromOtherUri(Uri uri) {
  if (uri.domain != '') {
    throw "URIs whose paths are used as file paths may not contain a domain.";
  }

  _logResolution("# Path: ${uri.path}");
  return uri.path;
}

String _filePathFromPackageUri(Uri uri) {
  if (uri.domain != '') {
    var path = (uri.path != '') ? '${uri.domain}${uri.path}' : uri.domain;
    var right = 'package:$path';
    var wrong = 'package://$path';

    throw "URIs using the 'package:' scheme should look like "
          "'$right', not '$wrong'.";
  }

  var path;
  if (_packageRoot != null) {
    path = "${_packageRoot}${uri.path}";
  } else {
    path = _entrypoint.resolve('packages/${uri.path}').path;
  }

  _logResolution("# Package: $path");
  return path;
}
