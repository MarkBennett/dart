// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:pathos/path.dart' as path;
import 'package:scheduled_test/descriptor.dart' as d;
import 'package:scheduled_test/scheduled_test.dart';

import '../metatest.dart';
import 'utils.dart';

void main() {
  setUpTimeout();

  expectTestsPass("directory().create() creates a directory and its contents",
      () {
    test('test', () {
      scheduleSandbox();

      d.dir('dir', [
        d.dir('subdir', [
          d.file('subfile1.txt', 'subcontents1'),
          d.file('subfile2.txt', 'subcontents2')
        ]),
        d.file('file1.txt', 'contents1'),
        d.file('file2.txt', 'contents2')
      ]).create();

      schedule(() {
        expect(new File(path.join(sandbox, 'dir', 'file1.txt')).readAsString(),
            completion(equals('contents1')));
        expect(new File(path.join(sandbox, 'dir', 'file2.txt')).readAsString(),
            completion(equals('contents2')));
        expect(new File(path.join(sandbox, 'dir', 'subdir', 'subfile1.txt'))
                .readAsString(),
            completion(equals('subcontents1')));
        expect(new File(path.join(sandbox, 'dir', 'subdir', 'subfile2.txt'))
                .readAsString(),
            completion(equals('subcontents2')));
      });
    });
  });

  expectTestsPass("directory().create() works if the directory already exists",
      () {
    test('test', () {
      scheduleSandbox();

      d.dir('dir').create();
      d.dir('dir', [d.file('name.txt', 'contents')]).create();

      schedule(() {
        expect(new File(path.join(sandbox, 'dir', 'name.txt')).readAsString(),
            completion(equals('contents')));
      });
    });
  });

  expectTestsPass("directory().validate() completes successfully if the "
      "filesystem matches the descriptor", () {
    test('test', () {
      scheduleSandbox();

      schedule(() {
        var dirPath = path.join(sandbox, 'dir');
        var subdirPath = path.join(dirPath, 'subdir');
        return new Directory(subdirPath).create(recursive: true).then((_) {
          return Future.wait([
            new File(path.join(dirPath, 'file1.txt'))
                .writeAsString('contents1'),
            new File(path.join(dirPath, 'file2.txt'))
                .writeAsString('contents2'),
            new File(path.join(subdirPath, 'subfile1.txt'))
                .writeAsString('subcontents1'),
            new File(path.join(subdirPath, 'subfile2.txt'))
                .writeAsString('subcontents2')
          ]);
        });
      });

      d.dir('dir', [
        d.dir('subdir', [
          d.file('subfile1.txt', 'subcontents1'),
          d.file('subfile2.txt', 'subcontents2')
        ]),
        d.file('file1.txt', 'contents1'),
        d.file('file2.txt', 'contents2')
      ]).validate();
    });
  });

  expectTestsPass("directory().validate() fails if a directory isn't found"
      , () {
    var errors;
    test('test 1', () {
      scheduleSandbox();

      currentSchedule.onException.schedule(() {
        errors = currentSchedule.errors;
      });

      schedule(() {
        var dirPath = path.join(sandbox, 'dir');
        return new Directory(dirPath).create().then((_) {
          return Future.wait([
            new File(path.join(dirPath, 'file1.txt'))
                .writeAsString('contents1'),
            new File(path.join(dirPath, 'file2.txt'))
                .writeAsString('contents2')
          ]);
        });
      });

      d.dir('dir', [
        d.dir('subdir', [
          d.file('subfile1.txt', 'subcontents1'),
          d.file('subfile2.txt', 'subcontents2')
        ]),
        d.file('file1.txt', 'contents1'),
        d.file('file2.txt', 'contents2')
      ]).validate();
    });

    test('test 2', () {
      expect(errors, everyElement(new isInstanceOf<ScheduleError>()));
      expect(errors.length, equals(1));
      expect(errors.first.error.toString(),
          matches(r"^Directory not found: '[^']+[\\/]dir[\\/]subdir'\.$"));
    });
  }, passing: ['test 2']);

  expectTestsPass("directory().validate() fails if a file isn't found", () {
    var errors;
    test('test 1', () {
      scheduleSandbox();

      currentSchedule.onException.schedule(() {
        errors = currentSchedule.errors;
      });

      schedule(() {
        var dirPath = path.join(sandbox, 'dir');
        var subdirPath = path.join(dirPath, 'subdir');
        return new Directory(subdirPath).create(recursive: true).then((_) {
          return Future.wait([
            new File(path.join(dirPath, 'file1.txt'))
                .writeAsString('contents1'),
            new File(path.join(subdirPath, 'subfile1.txt'))
                .writeAsString('subcontents1'),
            new File(path.join(subdirPath, 'subfile2.txt'))
                .writeAsString('subcontents2')
          ]);
        });
      });

      d.dir('dir', [
        d.dir('subdir', [
          d.file('subfile1.txt', 'subcontents1'),
          d.file('subfile2.txt', 'subcontents2')
        ]),
        d.file('file1.txt', 'contents1'),
        d.file('file2.txt', 'contents2')
      ]).validate();
    });

    test('test 2', () {
      expect(errors, everyElement(new isInstanceOf<ScheduleError>()));
      expect(errors.length, equals(1));
      expect(errors.first.error.toString(),
          matches(r"^File not found: '[^']+[\\/]dir[\\/]file2\.txt'\.$"));
    });
  }, passing: ['test 2']);

  expectTestsPass("directory().validate() fails if multiple children aren't "
      "found or have the wrong contents", () {
    var errors;
    test('test 1', () {
      scheduleSandbox();

      currentSchedule.onException.schedule(() {
        errors = currentSchedule.errors;
      });

      schedule(() {
        var dirPath = path.join(sandbox, 'dir');
        var subdirPath = path.join(dirPath, 'subdir');
        return new Directory(subdirPath).create(recursive: true).then((_) {
          return Future.wait([
            new File(path.join(dirPath, 'file1.txt'))
                .writeAsString('contents1'),
            new File(path.join(subdirPath, 'subfile2.txt'))
                .writeAsString('subwrongtents2')
          ]);
        });
      });

      d.dir('dir', [
        d.dir('subdir', [
          d.file('subfile1.txt', 'subcontents1'),
          d.file('subfile2.txt', 'subcontents2')
        ]),
        d.file('file1.txt', 'contents1'),
        d.file('file2.txt', 'contents2')
      ]).validate();
    });

    test('test 2', () {
      expect(errors, everyElement(new isInstanceOf<ScheduleError>()));
      expect(errors.length, equals(1));
      expect(errors.first.error.toString(), matches(
          r"^\* File not found: '[^']+[\\/]dir[\\/]subdir[\\/]subfile1\.txt'\."
              r"\n"
          r"\* File 'subfile2\.txt' should contain:\n"
          r"  \| subcontents2\n"
          r"  but actually contained:\n"
          r"  X subwrongtents2\n"
          r"\* File not found: '[^']+[\\/]dir[\\/]file2\.txt'\.$"));
    });
  }, passing: ['test 2']);

  expectTestsPass("directory().validate() fails if a file has the wrong "
      "contents", () {
    var errors;
    test('test 1', () {
      scheduleSandbox();

      currentSchedule.onException.schedule(() {
        errors = currentSchedule.errors;
      });

      schedule(() {
        var dirPath = path.join(sandbox, 'dir');
        var subdirPath = path.join(dirPath, 'subdir');
        return new Directory(subdirPath).create(recursive: true).then((_) {
          return Future.wait([
            new File(path.join(dirPath, 'file1.txt'))
                .writeAsString('contents1'),
            new File(path.join(dirPath, 'file2.txt'))
                .writeAsString('contents2'),
            new File(path.join(subdirPath, 'subfile1.txt'))
                .writeAsString('wrongtents1'),
            new File(path.join(subdirPath, 'subfile2.txt'))
                .writeAsString('subcontents2')
          ]);
        });
      });

      d.dir('dir', [
        d.dir('subdir', [
          d.file('subfile1.txt', 'subcontents1'),
          d.file('subfile2.txt', 'subcontents2')
        ]),
        d.file('file1.txt', 'contents1'),
        d.file('file2.txt', 'contents2')
      ]).validate();
    });

    test('test 2', () {
      expect(errors, everyElement(new isInstanceOf<ScheduleError>()));
      expect(errors.map((e) => e.error.toString()), equals([
        "File 'subfile1.txt' should contain:\n"
        "| subcontents1\n"
        "but actually contained:\n"
        "X wrongtents1"
      ]));
    });
  }, passing: ['test 2']);

  expectTestsPass("directory().load() loads a file", () {
    test('test', () {
      var dir = d.dir('dir', [d.file('name.txt', 'contents')]);
      expect(byteStreamToString(dir.load('name.txt')),
          completion(equals('contents')));
    });
  });

  expectTestsPass("directory().load() loads a deeply-nested file", () {
    test('test', () {
      var dir = d.dir('dir', [
        d.dir('subdir', [
          d.file('name.txt', 'subcontents')
        ]),
        d.file('name.txt', 'contents')
      ]);

      expect(byteStreamToString(dir.load('subdir/name.txt')),
          completion(equals('subcontents')));
    });
  });

  expectTestsPass("directory().read() fails", () {
    test('test', () {
      var dir = d.dir('dir', [d.file('name.txt', 'contents')]);
      expect(dir.read().toList(),
          throwsA(equals("Can't read the contents of 'dir': is a directory.")));
    });
  });

  expectTestsPass("directory().load() fails to load a nested directory", () {
    test('test', () {
      var dir = d.dir('dir', [
        d.dir('subdir', [
          d.file('name.txt', 'subcontents')
        ]),
        d.file('name.txt', 'contents')
      ]);

      expect(dir.load('subdir').toList(),
          throwsA(equals("Can't read the contents of 'subdir': is a "
              "directory.")));
    });
  });

  expectTestsPass("directory().load() fails to load an absolute path", () {
    test('test', () {
      var dir = d.dir('dir', [d.file('name.txt', 'contents')]);

      expect(dir.load('/name.txt').toList(),
          throwsA(equals("Can't load absolute path '/name.txt'.")));
    });
  });

  expectTestsPass("directory().load() fails to load '.', '..', or ''", () {
    test('test', () {
      var dir = d.dir('dir', [d.file('name.txt', 'contents')]);

      expect(dir.load('.').toList(),
          throwsA(equals("Can't load '.' from within 'dir'.")));

      expect(dir.load('..').toList(),
          throwsA(equals("Can't load '..' from within 'dir'.")));

      expect(dir.load('').toList(),
          throwsA(equals("Can't load '' from within 'dir'.")));
    });
  });

  expectTestsPass("directory().load() fails to load a file that doesn't exist",
      () {
    test('test', () {
      var dir = d.dir('dir', [d.file('name.txt', 'contents')]);

      expect(dir.load('not-name.txt').toList(),
          throwsA(equals("Couldn't find an entry named 'not-name.txt' within "
              "'dir'.")));
    });
  });

  expectTestsPass("directory().load() fails to load a file that exists "
      "multiple times", () {
    test('test', () {
      var dir = d.dir('dir', [
        d.file('name.txt', 'contents'),
        d.file('name.txt', 'contents')
      ]);

      expect(dir.load('name.txt').toList(),
          throwsA(equals("Found multiple entries named 'name.txt' within "
              "'dir'.")));
    });
  });

  expectTestsPass("directory().describe() lists the contents of the directory",
      () {
    test('test', () {
      var dir = d.dir('dir', [
        d.file('file1.txt', 'contents1'),
        d.file('file2.txt', 'contents2')
      ]);

      expect(dir.describe(), equals(
          "dir\n"
          "|-- file1.txt\n"
          "'-- file2.txt"));
    });
  });

  expectTestsPass("directory().describe() lists the contents of nested "
      "directories", () {
    test('test', () {
      var dir = d.dir('dir', [
        d.file('file1.txt', 'contents1'),
        d.dir('subdir', [
          d.file('subfile1.txt', 'subcontents1'),
          d.file('subfile2.txt', 'subcontents2'),
          d.dir('subsubdir', [
            d.file('subsubfile.txt', 'subsubcontents')
          ])
        ]),
        d.file('file2.txt', 'contents2')
      ]);

      expect(dir.describe(), equals(
          "dir\n"
          "|-- file1.txt\n"
          "|-- subdir\n"
          "|   |-- subfile1.txt\n"
          "|   |-- subfile2.txt\n"
          "|   '-- subsubdir\n"
          "|       '-- subsubfile.txt\n"
          "'-- file2.txt"));
    });
  });

  expectTestsPass("directory().describe() with no contents returns the "
      "directory name", () {
    test('test', () {
      expect(d.dir('dir').describe(), equals('dir'));
    });
  });
}