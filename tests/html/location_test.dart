library LocationTest;
import '../../pkg/unittest/lib/unittest.dart';
import '../../pkg/unittest/lib/html_config.dart';
import 'dart:html';
import 'dart:uri';

main() {
  useHtmlConfiguration();

  var isLocation = predicate((x) => x is Location, 'is a Location');

  test('location hash', () {
      final location = window.location;
      expect(location, isLocation);

      // The only navigation we dare try is hash.
      location.hash = 'hello';
      var h = location.hash;
      expect(h, '#hello');
    });

  test('location.origin', () {
    var origin = window.location.origin;

    // We build up the origin from Uri, then make sure that it matches.
    var uri = new Uri(window.location.href);
    var reconstructedOrigin = '${uri.scheme}://${uri.domain}';
    if (uri.port != 0) {
      reconstructedOrigin = '$reconstructedOrigin:${uri.port}';
    }

    expect(origin, reconstructedOrigin);
  });
}
