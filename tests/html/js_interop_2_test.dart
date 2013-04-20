// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file

library JsInterop2Test;
import '../../pkg/unittest/lib/unittest.dart';
import '../../pkg/unittest/lib/html_config.dart';
import 'dart:html';
import 'dart:isolate';

injectSource(code) {
  final script = new ScriptElement();
  script.type = 'text/javascript';
  script.innerHtml = code;
  document.body.nodes.add(script);
}

var isolateTest = """
  function test(data) {
    if (data == 'sent')
      return 'received';
  }

  var port = new ReceivePortSync();
  port.receive(test);
  window.registerPort('test', port.toSendPort());
""";

var portEqualityTest = """
  function identity(data) {
    return data;
  }

  var port = new ReceivePortSync();
  port.receive(identity);
  window.registerPort('identity', port.toSendPort());
""";

main() {
  useHtmlConfiguration();

  test('dart-to-js-ports', () {
    injectSource(isolateTest);

    SendPortSync port = window.lookupPort('test');
    var result = port.callSync('sent');
    expect(result, 'received');

    result = port.callSync('ignore');
    expect(result, isNull);
  });

  test('port-equality', () {
    injectSource(portEqualityTest);

    SendPortSync port1 = window.lookupPort('identity');
    SendPortSync port2 = window.lookupPort('identity');
    expect(port1, equals(port2));

    SendPortSync port3 = port1.callSync(port2);
    expect(port3, equals(port2));
  });
}
