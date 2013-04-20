// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library args_test;

import 'package:unittest/unittest.dart';
import 'package:args/args.dart';

main() {
  group('ArgParser.addFlag()', () {
    test('throws ArgumentError if the flag already exists', () {
      var parser = new ArgParser();
      parser.addFlag('foo');
      throwsIllegalArg(() => parser.addFlag('foo'));
    });

    test('throws ArgumentError if the option already exists', () {
      var parser = new ArgParser();
      parser.addOption('foo');
      throwsIllegalArg(() => parser.addFlag('foo'));
    });

    test('throws ArgumentError if the abbreviation exists', () {
      var parser = new ArgParser();
      parser.addFlag('foo', abbr: 'f');
      throwsIllegalArg(() => parser.addFlag('flummox', abbr: 'f'));
    });

    test('throws ArgumentError if the abbreviation is longer '
         'than one character', () {
      var parser = new ArgParser();
      throwsIllegalArg(() => parser.addFlag('flummox', abbr: 'flu'));
    });

    test('throws ArgumentError if a flag name is invalid', () {
      var parser = new ArgParser();

      for(var name in _INVALID_OPTIONS) {
        var reason = '${Error.safeToString(name)} is not valid';
        throwsIllegalArg(() => parser.addFlag(name), reason: reason);
      }
    });

    test('accepts valid flag names', () {
      var parser = new ArgParser();

      for(var name in _VALID_OPTIONS) {
        var reason = '${Error.safeToString(name)} is valid';
        expect(() => parser.addFlag(name), returnsNormally, reason: reason);
      }
    });
  });

  group('ArgParser.addOption()', () {
    test('throws ArgumentError if the flag already exists', () {
      var parser = new ArgParser();
      parser.addFlag('foo');
      throwsIllegalArg(() => parser.addOption('foo'));
    });

    test('throws ArgumentError if the option already exists', () {
      var parser = new ArgParser();
      parser.addOption('foo');
      throwsIllegalArg(() => parser.addOption('foo'));
    });

    test('throws ArgumentError if the abbreviation exists', () {
      var parser = new ArgParser();
      parser.addFlag('foo', abbr: 'f');
      throwsIllegalArg(() => parser.addOption('flummox', abbr: 'f'));
    });

    test('throws ArgumentError if the abbreviation is longer '
         'than one character', () {
      var parser = new ArgParser();
      throwsIllegalArg(() => parser.addOption('flummox', abbr: 'flu'));
    });

    test('throws ArgumentError if the abbreviation is empty', () {
      var parser = new ArgParser();
      throwsIllegalArg(() => parser.addOption('flummox', abbr: ''));
    });

    test('throws ArgumentError if the abbreviation is an invalid value', () {
      var parser = new ArgParser();
      for(var name in _INVALID_OPTIONS.where((v) => v != null)) {
        throwsIllegalArg(() => parser.addOption('flummox', abbr: name));
      }
    });

    test('throws ArgumentError if the abbreviation is a dash', () {
      var parser = new ArgParser();
      throwsIllegalArg(() => parser.addOption('flummox', abbr: '-'));
    });

    test('allows explict null value for "abbr"', () {
      var parser = new ArgParser();
      expect(() => parser.addOption('flummox', abbr: null), returnsNormally);
    });

    test('throws ArgumentError if an option name is invalid', () {
      var parser = new ArgParser();

      for(var name in _INVALID_OPTIONS) {
        var reason = '${Error.safeToString(name)} is not valid';
        throwsIllegalArg(() => parser.addOption(name), reason: reason);
      }
    });

    test('accepts valid option names', () {
      var parser = new ArgParser();

      for(var name in _VALID_OPTIONS) {
        var reason = '${Error.safeToString(name)} is valid';
        expect(() => parser.addOption(name), returnsNormally, reason: reason);
      }
    });
  });

  group('ArgParser.getDefault()', () {
    test('returns the default value for an option', () {
      var parser = new ArgParser();
      parser.addOption('mode', defaultsTo: 'debug');
      expect(parser.getDefault('mode'), 'debug');
    });

    test('throws if the option is unknown', () {
      var parser = new ArgParser();
      parser.addOption('mode', defaultsTo: 'debug');
      throwsIllegalArg(() => parser.getDefault('undefined'));
    });
  });

  group('ArgParser.commands', () {
    test('returns an empty map if there are no commands', () {
      var parser = new ArgParser();
      expect(parser.commands, isEmpty);
    });

    test('returns the commands that were added', () {
      var parser = new ArgParser();
      parser.addCommand('hide');
      parser.addCommand('seek');
      expect(parser.commands, hasLength(2));
      expect(parser.commands['hide'], isNotNull);
      expect(parser.commands['seek'], isNotNull);
    });

    test('iterates over the commands in the order they were added', () {
      var parser = new ArgParser();
      parser.addCommand('a');
      parser.addCommand('d');
      parser.addCommand('b');
      parser.addCommand('c');
      expect(parser.commands.keys, equals(['a', 'd', 'b', 'c']));
    });
  });

  group('ArgParser.options', () {
    test('returns an empty map if there are no options', () {
      var parser = new ArgParser();
      expect(parser.options, isEmpty);
    });

    test('returns the options that were added', () {
      var parser = new ArgParser();
      parser.addFlag('hide');
      parser.addOption('seek');
      expect(parser.options, hasLength(2));
      expect(parser.options['hide'], isNotNull);
      expect(parser.options['seek'], isNotNull);
    });

    test('iterates over the options in the order they were added', () {
      var parser = new ArgParser();
      parser.addFlag('a');
      parser.addOption('d');
      parser.addFlag('b');
      parser.addOption('c');
      expect(parser.options.keys, equals(['a', 'd', 'b', 'c']));
    });
  });

  group('ArgResults.options', () {
    test('returns the provided options', () {
      var parser = new ArgParser();
      parser.addFlag('woof');
      parser.addOption('meow');
      var args = parser.parse(['--woof', '--meow', 'kitty']);
      expect(args.options, hasLength(2));
      expect(args.options.any((o) => o == 'woof'), isTrue);
      expect(args.options.any((o) => o == 'meow'), isTrue);
    });

    test('includes defaulted options', () {
      var parser = new ArgParser();
      parser.addFlag('woof', defaultsTo: false);
      parser.addOption('meow', defaultsTo: 'kitty');
      var args = parser.parse([]);
      expect(args.options, hasLength(2));
      expect(args.options.any((o) => o == 'woof'), isTrue);
      expect(args.options.any((o) => o == 'meow'), isTrue);
    });
  });

  group('ArgResults[]', () {
    test('throws if the name is not an option', () {
      var parser = new ArgParser();
      var results = parser.parse([]);
      throwsIllegalArg(() => results['unknown']);
    });
  });
}

throwsIllegalArg(function, {String reason: null}) {
  expect(function, throwsArgumentError, reason: reason);
}

throwsFormat(ArgParser parser, List<String> args) {
  expect(() => parser.parse(args), throwsFormatException);
}

const _INVALID_OPTIONS = const [
 ' ', '', '-', '--', '--foo',
 ' with space',
 'with\ttab',
 'with\rcarriage\rreturn',
 'with\nline\nfeed',
 "'singlequotes'",
 '"doublequotes"',
 'back\\slash',
 'forward/slash'
];

const _VALID_OPTIONS = const [
 'a' // one char
 'contains-dash',
 'contains_underscore',
 'ends-with-dash-',
 'contains--doubledash--',
 '1starts-with-number',
 'contains-a-1number',
 'ends-with-a-number8'
];
