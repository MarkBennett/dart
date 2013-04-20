library KeyboardEventTest;
import '../../pkg/unittest/lib/unittest.dart';
import '../../pkg/unittest/lib/html_config.dart';
import 'dart:html';

// Test that we are correctly determining keyCode and charCode uniformly across
// browsers.

main() {

  useHtmlConfiguration();

  keydownHandlerTest(KeyEvent e) {
    expect(e.charCode, 0);
  }

  test('keyboardEvent constructor', () {
    var event = new KeyboardEvent('keyup');
  });
  test('keys', () {
    // This test currently is pretty much a no-op because we
    // can't (right now) construct KeyboardEvents with specific keycode/charcode
    // values (a KeyboardEvent can be "init"-ed but not all the information can
    // be programmatically populated. It exists as an example for how to use
    // KeyboardEventController more than anything else.
    KeyboardEventStream.onKeyDown(document.body).listen(
        keydownHandlerTest);
    KeyEvent.keyDownEvent.forTarget(document.body).listen(keydownHandlerTest);
    document.body.onKeyDown.listen((e) => print('regular listener'));
  });
}


