// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library lock_file_test;

import 'package:unittest/unittest.dart';
import 'package:yaml/yaml.dart';

import '../lib/src/lock_file.dart';
import '../lib/src/package.dart';
import '../lib/src/source.dart';
import '../lib/src/source_registry.dart';
import '../lib/src/utils.dart';
import '../lib/src/version.dart';

class MockSource extends Source {
  final String name = 'mock';
  final bool shouldCache = false;

  dynamic parseDescription(String filePath, String description,
                           {bool fromLockFile: false}) {
    if (!description.endsWith(' desc')) throw new FormatException();
    return description;
  }

  String packageName(String description) {
    // Strip off ' desc'.
    return description.substring(0, description.length - 5);
  }
}

main() {
  var sources = new SourceRegistry();
  var mockSource = new MockSource();
  sources.register(mockSource);

  group('LockFile', () {
    group('parse()', () {
      test('returns an empty lockfile if the contents are empty', () {
        var lockFile = new LockFile.parse('', sources);
        expect(lockFile.packages.length, equals(0));
      });

      test('returns an empty lockfile if the contents are whitespace', () {
        var lockFile = new LockFile.parse('  \t\n  ', sources);
        expect(lockFile.packages.length, equals(0));
      });

      test('parses a series of package descriptions', () {
        var lockFile = new LockFile.parse('''
packages:
  bar:
    version: 1.2.3
    source: mock
    description: bar desc
  foo:
    version: 2.3.4
    source: mock
    description: foo desc
''', sources);

        expect(lockFile.packages.length, equals(2));

        var bar = lockFile.packages['bar'];
        expect(bar.name, equals('bar'));
        expect(bar.version, equals(new Version(1, 2, 3)));
        expect(bar.source, equals(mockSource));
        expect(bar.description, equals('bar desc'));

        var foo = lockFile.packages['foo'];
        expect(foo.name, equals('foo'));
        expect(foo.version, equals(new Version(2, 3, 4)));
        expect(foo.source, equals(mockSource));
        expect(foo.description, equals('foo desc'));
      });

      test("throws if the version is missing", () {
        expect(() {
          new LockFile.parse('''
packages:
  foo:
    source: mock
    description: foo desc
''', sources);
        }, throwsFormatException);
      });

      test("throws if the version is invalid", () {
        expect(() {
          new LockFile.parse('''
packages:
  foo:
    version: vorpal
    source: mock
    description: foo desc
''', sources);
        }, throwsFormatException);
      });

      test("throws if the source is missing", () {
        expect(() {
          new LockFile.parse('''
packages:
  foo:
    version: 1.2.3
    description: foo desc
''', sources);
        }, throwsFormatException);
      });

      test("throws if the source is unknown", () {
        expect(() {
          new LockFile.parse('''
packages:
  foo:
    version: 1.2.3
    source: notreal
    description: foo desc
''', sources);
        }, throwsFormatException);
      });

      test("throws if the description is missing", () {
        expect(() {
          new LockFile.parse('''
packages:
  foo:
    version: 1.2.3
    source: mock
''', sources);
        }, throwsFormatException);
      });

      test("throws if the description is invalid", () {
        expect(() {
          new LockFile.parse('''
packages:
  foo:
    version: 1.2.3
    source: mock
    description: foo desc is bad
''', sources);
        }, throwsFormatException);
      });

      test("ignores extra stuff in file", () {
        var lockFile = new LockFile.parse('''
extra:
  some: stuff
packages:
  foo:
    bonus: not used
    version: 1.2.3
    source: mock
    description: foo desc
''', sources);
      });
    });

    group('serialize()', () {
      var lockfile;
      setUp(() {
        lockfile = new LockFile.empty();
      });

      test('dumps the lockfile to YAML', () {
        lockfile.packages['foo'] = new PackageId(
            'foo', mockSource, new Version.parse('1.2.3'), 'foo desc');
        lockfile.packages['bar'] = new PackageId(
            'bar', mockSource, new Version.parse('3.2.1'), 'bar desc');

        expect(loadYaml(lockfile.serialize()), equals({
          'packages': {
            'foo': {
              'version': '1.2.3',
              'source': 'mock',
              'description': 'foo desc'
            },
            'bar': {
              'version': '3.2.1',
              'source': 'mock',
              'description': 'bar desc'
            }
          }
        }));
      });

      test('lockfile is alphabetized by package name', () {
        var testNames = ['baz', 'Qwe', 'Q', 'B', 'Bar', 'bar', 'foo'];
        testNames.forEach((name) {
          lockfile.packages[name] = new PackageId(name, mockSource,
            new Version.parse('5.5.5'), '$name desc');
        });

        expect(lockfile.serialize(),
          '# Generated by pub\n'
          '# See http://pub.dartlang.org/doc/glossary.html#lockfile\n'
          '\n'
          '{"packages":{'
          '"B":{"version":"5.5.5","source":"mock","description":"B desc"},'
          '"Bar":{"version":"5.5.5","source":"mock","description":"Bar desc"},'
          '"Q":{"version":"5.5.5","source":"mock","description":"Q desc"},'
          '"Qwe":{"version":"5.5.5","source":"mock","description":"Qwe desc"},'
          '"bar":{"version":"5.5.5","source":"mock","description":"bar desc"},'
          '"baz":{"version":"5.5.5","source":"mock","description":"baz desc"},'
          '"foo":{"version":"5.5.5","source":"mock","description":"foo desc"}}}'
          '\n'
        );
      });
    });
  });
}
