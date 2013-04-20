// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


library logging_test;

import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';

main() {
  test('level comparison is a valid comparator', () {
    var level1 = const Level('NOT_REAL1', 253);
    expect(level1 == level1, isTrue);
    expect(level1 <= level1, isTrue);
    expect(level1 >= level1, isTrue);
    expect(level1 < level1, isFalse);
    expect(level1 > level1, isFalse);

    var level2 = const Level('NOT_REAL2', 455);
    expect(level1 <= level2, isTrue);
    expect(level1 < level2, isTrue);
    expect(level2 >= level1, isTrue);
    expect(level2 > level1, isTrue);

    var level3 = const Level('NOT_REAL3', 253);
    expect(!identical(level1, level3), isTrue); // different instances
    expect(level1 == level3, isTrue); // same value.
  });

  test('default levels are in order', () {
    final levels = const [
        Level.ALL, Level.FINEST, Level.FINER, Level.FINE, Level.CONFIG,
        Level.INFO, Level.WARNING, Level.SEVERE, Level.SHOUT, Level.OFF
      ];

    for (int i = 0; i < levels.length; i++) {
      for (int j = i + 1; j < levels.length; j++) {
        expect(levels[i] < levels[j], isTrue);
      }
    }
  });

  test('levels are comparable', () {
    final unsorted = [
        Level.INFO, Level.CONFIG, Level.FINE, Level.SHOUT, Level.OFF,
        Level.FINER, Level.ALL, Level.WARNING, Level.FINEST,  Level.SEVERE,
      ];
    final sorted = const [
        Level.ALL, Level.FINEST, Level.FINER, Level.FINE, Level.CONFIG,
        Level.INFO, Level.WARNING, Level.SEVERE, Level.SHOUT, Level.OFF
      ];
    expect(unsorted, isNot(orderedEquals(sorted)));

    unsorted.sort((a, b) => a.compareTo(b));
    expect(unsorted, orderedEquals(sorted));
  });

  test('levels are hashable', () {
    var map = new Map<Level, String>();
    map[Level.INFO] = 'info';
    map[Level.SHOUT] = 'shout';
    expect(map[Level.INFO], equals('info'));
    expect(map[Level.SHOUT], equals('shout'));
  });

  test('logger name cannot start with a "." ', () {
    expect(() => new Logger('.c'), throws);
  });

  test('logger naming is hierarchical', () {
    Logger c = new Logger('a.b.c');
    expect(c.name, equals('c'));
    expect(c.parent.name, equals('b'));
    expect(c.parent.parent.name, equals('a'));
    expect(c.parent.parent.parent.name, equals(''));
    expect(c.parent.parent.parent.parent, isNull);
  });

  test('logger full name', () {
    Logger c = new Logger('a.b.c');
    expect(c.fullName, equals('a.b.c'));
    expect(c.parent.fullName, equals('a.b'));
    expect(c.parent.parent.fullName, equals('a'));
    expect(c.parent.parent.parent.fullName, equals(''));
    expect(c.parent.parent.parent.parent, isNull);
  });

  test('logger parent-child links are correct', () {
    Logger a = new Logger('a');
    Logger b = new Logger('a.b');
    Logger c = new Logger('a.c');
    expect(a == b.parent, isTrue);
    expect(a == c.parent, isTrue);
    expect(a.children['b'] == b, isTrue);
    expect(a.children['c'] == c, isTrue);
  });

  test('loggers are singletons', () {
    Logger a1 = new Logger('a');
    Logger a2 = new Logger('a');
    Logger b = new Logger('a.b');
    Logger root = Logger.root;
    expect(identical(a1, a2), isTrue);
    expect(identical(a1, b.parent), isTrue);
    expect(identical(root, a1.parent), isTrue);
    expect(identical(root, new Logger('')), isTrue);
  });

  group('mutating levels', () {
    Logger root = Logger.root;
    Logger a = new Logger('a');
    Logger b = new Logger('a.b');
    Logger c = new Logger('a.b.c');
    Logger d = new Logger('a.b.c.d');
    Logger e = new Logger('a.b.c.d.e');

    setUp(() {
      hierarchicalLoggingEnabled = true;
      root.level = Level.INFO;
      a.level = null;
      b.level = null;
      c.level = null;
      d.level = null;
      e.level = null;
      root.clearListeners();
      a.clearListeners();
      b.clearListeners();
      c.clearListeners();
      d.clearListeners();
      e.clearListeners();
      hierarchicalLoggingEnabled = false;
      root.level = Level.INFO;
    });

    test('cannot set level if hierarchy is disabled', () {
      expect(() {a.level = Level.FINE;}, throws);
    });

    test('loggers effective level - no hierarchy', () {
      expect(root.level, equals(Level.INFO));
      expect(a.level, equals(Level.INFO));
      expect(b.level, equals(Level.INFO));

      root.level = Level.SHOUT;

      expect(root.level, equals(Level.SHOUT));
      expect(a.level, equals(Level.SHOUT));
      expect(b.level, equals(Level.SHOUT));
    });

    test('loggers effective level - with hierarchy', () {
      hierarchicalLoggingEnabled = true;
      expect(root.level, equals(Level.INFO));
      expect(a.level, equals(Level.INFO));
      expect(b.level, equals(Level.INFO));
      expect(c.level, equals(Level.INFO));

      root.level = Level.SHOUT;
      b.level = Level.FINE;

      expect(root.level, equals(Level.SHOUT));
      expect(a.level, equals(Level.SHOUT));
      expect(b.level, equals(Level.FINE));
      expect(c.level, equals(Level.FINE));
    });

    test('isLoggable is appropriate', () {
      hierarchicalLoggingEnabled = true;
      root.level = Level.SEVERE;
      c.level = Level.ALL;
      e.level = Level.OFF;

      expect(root.isLoggable(Level.SHOUT), isTrue);
      expect(root.isLoggable(Level.SEVERE), isTrue);
      expect(root.isLoggable(Level.WARNING), isFalse);
      expect(c.isLoggable(Level.FINEST), isTrue);
      expect(c.isLoggable(Level.FINE), isTrue);
      expect(!e.isLoggable(Level.SHOUT), isTrue);
    });

    test('add/remove handlers - no hierarchy', () {
      int calls = 0;
      var handler = (_) { calls++; };
      final sub = c.onRecord.listen(handler);
      root.info("foo");
      root.info("foo");
      expect(calls, equals(2));
      sub.cancel();
      root.info("foo");
      expect(calls, equals(2));
    });

    test('add/remove handlers - with hierarchy', () {
      hierarchicalLoggingEnabled = true;
      int calls = 0;
      var handler = (_) { calls++; };
      c.onRecord.listen(handler);
      root.info("foo");
      root.info("foo");
      expect(calls, equals(0));
    });

    test('logging methods store appropriate level', () {
      root.level = Level.ALL;
      var rootMessages = [];
      root.onRecord.listen((record) {
        rootMessages.add('${record.level}: ${record.message}');
      });

      root.finest('1');
      root.finer('2');
      root.fine('3');
      root.config('4');
      root.info('5');
      root.warning('6');
      root.severe('7');
      root.shout('8');

      expect(rootMessages, equals([
        'FINEST: 1',
        'FINER: 2',
        'FINE: 3',
        'CONFIG: 4',
        'INFO: 5',
        'WARNING: 6',
        'SEVERE: 7',
        'SHOUT: 8']));
    });

    test('message logging - no hierarchy', () {
      root.level = Level.WARNING;
      var rootMessages = [];
      var aMessages = [];
      var cMessages = [];
      c.onRecord.listen((record) {
        cMessages.add('${record.level}: ${record.message}');
      });
      a.onRecord.listen((record) {
        aMessages.add('${record.level}: ${record.message}');
      });
      root.onRecord.listen((record) {
        rootMessages.add('${record.level}: ${record.message}');
      });

      root.info('1');
      root.fine('2');
      root.shout('3');

      b.info('4');
      b.severe('5');
      b.warning('6');
      b.fine('7');

      c.fine('8');
      c.warning('9');
      c.shout('10');

      expect(rootMessages, equals([
            // 'INFO: 1' is not loggable
            // 'FINE: 2' is not loggable
            'SHOUT: 3',
            // 'INFO: 4' is not loggable
            'SEVERE: 5',
            'WARNING: 6',
            // 'FINE: 7' is not loggable
            // 'FINE: 8' is not loggable
            'WARNING: 9',
            'SHOUT: 10']));

      // no hierarchy means we all hear the same thing.
      expect(aMessages, equals(rootMessages));
      expect(cMessages, equals(rootMessages));
    });

    test('message logging - with hierarchy', () {
      hierarchicalLoggingEnabled = true;

      b.level = Level.WARNING;

      var rootMessages = [];
      var aMessages = [];
      var cMessages = [];
      c.onRecord.listen((record) {
        cMessages.add('${record.level}: ${record.message}');
      });
      a.onRecord.listen((record) {
        aMessages.add('${record.level}: ${record.message}');
      });
      root.onRecord.listen((record) {
        rootMessages.add('${record.level}: ${record.message}');
      });

      root.info('1');
      root.fine('2');
      root.shout('3');

      b.info('4');
      b.severe('5');
      b.warning('6');
      b.fine('7');

      c.fine('8');
      c.warning('9');
      c.shout('10');

      expect(rootMessages, equals([
            'INFO: 1',
            // 'FINE: 2' is not loggable
            'SHOUT: 3',
            // 'INFO: 4' is not loggable
            'SEVERE: 5',
            'WARNING: 6',
            // 'FINE: 7' is not loggable
            // 'FINE: 8' is not loggable
            'WARNING: 9',
            'SHOUT: 10']));

      expect(aMessages, equals([
            // 1,2 and 3 are lower in the hierarchy
            // 'INFO: 4' is not loggable
            'SEVERE: 5',
            'WARNING: 6',
            // 'FINE: 7' is not loggable
            // 'FINE: 8' is not loggable
            'WARNING: 9',
            'SHOUT: 10']));

      expect(cMessages, equals([
            // 1 - 7 are lower in the hierarchy
            // 'FINE: 8' is not loggable
            'WARNING: 9',
            'SHOUT: 10']));
    });
  });
}
