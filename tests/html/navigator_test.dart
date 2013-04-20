library NavigatorTest;
import '../../pkg/unittest/lib/unittest.dart';
import '../../pkg/unittest/lib/html_config.dart';
import 'dart:html';

main() {
  useHtmlConfiguration();

  test('language never returns null', () {
      expect(window.navigator.language, isNotNull);
    });
}
