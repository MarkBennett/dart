// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Smoke test of the dart2js compiler API.
library dummy_compiler;

import 'dart:async';
import 'dart:uri';

import '../../sdk/lib/_internal/compiler/compiler.dart';

Future<String> provider(Uri uri) {
  String source;
  if (uri.scheme == "main") {
    source = "main() {}";
  } else if (uri.scheme == "lib") {
    if (uri.path.endsWith("/core.dart")) {
      source = """library core;
                  class Object {
                    operator==(other) {}
                  }
                  class Type {}
                  class bool {}
                  class num {}
                  class int {}
                  class double{}
                  class String{}
                  class Function{}
                  class List {}
                  class Map {}
                  class Closure {}
                  class Dynamic_ {}
                  class Null {}
                  class LinkedHashMap {}
                  identical(a, b) => true;
                  getRuntimeTypeInfo(o) {}
                  setRuntimeTypeInfo(o, i) {}
                  eqNull(a) {}
                  eqNullB(a) {}""";
    } else if (uri.path.endsWith('_patch.dart')) {
      source = '';
    } else if (uri.path.endsWith('interceptors.dart')) {
      source = """class Interceptor {
                    operator==(other) {}
                  }
                  class JSIndexable {
                    get length;
                  }
                  class JSMutableIndexable {}
                  class JSArray {
                    var removeLast;
                    var add;
                  }
                  class JSFixedArray {}
                  class JSExtendableArray {}
                  class JSString {
                    var split;
                    var concat;
                    var toString;
                  }
                  class JSFunction {}
                  class JSInt {}
                  class JSDouble {}
                  class JSNumber {}
                  class JSNull {}
                  class JSBool {}
                  getInterceptor(o){}
                  getDispatchProperty(o) {}
                  setDispatchProperty(o, v) {}""";
    } else if (uri.path.endsWith('js_helper.dart')) {
      source = 'library jshelper; class JSInvocationMirror {} '
               'class ConstantMap {} class TypeImpl {}';
    } else if (uri.path.endsWith('isolate_helper.dart')) {
      source = 'library isolatehelper; class _WorkerStub {}';
    } else {
      source = "library lib;";
    }
  } else {
   throw "unexpected URI $uri";
  }
  return new Future.value(source);
}

void handler(Uri uri, int begin, int end, String message, Diagnostic kind) {
  if (uri == null) {
    print('$kind: $message');
  } else {
    print('$uri:$begin:$end: $kind: $message');
  }
}

main() {
  Future<String> result =
      compile(new Uri.fromComponents(scheme: 'main'),
              new Uri.fromComponents(scheme: 'lib', path: '/'),
              new Uri.fromComponents(scheme: 'package', path: '/'),
              provider, handler);
  result.then((String code) {
    if (code == null) {
      throw 'Compilation failed';
    }
  }, onError: (e) {
      throw 'Compilation failed';
  });
}
