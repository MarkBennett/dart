library WindowOpenTest;
import '../../pkg/unittest/lib/unittest.dart';
import '../../pkg/unittest/lib/html_config.dart';
import 'dart:html';
import 'dart:async';

main() {
  useHtmlConfiguration();
  evaluateJavaScript(code) {
    final scriptTag = new Element.tag('script');
    scriptTag.innerHtml = code;
    document.body.nodes.add(scriptTag);
  }
  evaluateJavaScript('(testRunner || layoutTestController).setCanOpenWindows()');

  test('TwoArgumentVersion', () {
    Window win = window.open('../resources/pong.html', 'testWindow');
    closeWindow(win);
  });
  test('ThreeArgumentVersion', () {
    Window win = window.open("resources/pong.html", "testWindow", "scrollbars=yes,width=75,height=100");
    closeWindow(win);
  });
}

closeWindow(win) {
  win.close();
  doneHandler() {
    if (!win.closed) {
      new Timer(const Duration(milliseconds: 1), expectAsync0(doneHandler));
    }
  }
  new Timer(const Duration(milliseconds: 1), expectAsync0(doneHandler));
}
