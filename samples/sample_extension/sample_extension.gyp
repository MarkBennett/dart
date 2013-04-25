# Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

{
  'targets': [
    {
      'target_name': 'sample_extension',
      'type': 'shared_library',
      'dependencies': [
        '../../runtime/dart-runtime.gyp:dart',
      ],
      'include_dirs': [
        '../../runtime/include',
      ],
      'sources': [
        'sample_extension.cc',
        'sample_extension_dllmain_win.cc',
      ],
      'defines': [
        'DART_SHARED_LIB',
      ],
      'conditions': [
        ['OS=="win"', {
          'msvs_settings': {
            'VCLinkerTool': {
              'AdditionalDependencies': [ 'dart.lib' ],
              'AdditionalLibraryDirectories': [ '<(PRODUCT_DIR)' ],
            },
          },
        }],
        ['OS=="mac"', {
          'xcode_settings': {
            'OTHER_LDFLAGS': [ '-undefined', 'dynamic_lookup' ],
          },
        }],
        ['OS=="linux"', {
          'cflags': [
            '-fPIC',
          ],
        }],
      ],
    },
  ],
}
