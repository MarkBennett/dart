# Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

{
  'includes': [
    'sources.gypi',
    'test_sources.gypi',
  ],
  'targets': [
    {
      'target_name': 'dart_analyzer',
      'type': 'none',
      'conditions': [
        [ 'OS!="win"', {
          'variables': {
            'script_suffix': '',
          },
        }],
        [ 'OS=="win"', {
          'variables': {
            'script_suffix': '.bat',
          },
        }],
      ],
      'actions': [
        {
          'action_name': 'build_dart_analyzer',
          'inputs': [
            'sources.gypi',
            'test_sources.gypi',
            '<@(java_sources)',
            '<@(java_resources)',
            '<@(javatests_sources)',
            '<@(javatests_resources)',
            'dart_analyzer.xml',
            'scripts/dart_analyzer.sh',
            'scripts/dart_analyzer.bat',
            'scripts/analyzer_metrics.sh',
            '../third_party/args4j/2.0.12/args4j-2.0.12.jar',
            '../third_party/guava/r13/guava-13.0.1.jar',
            '../third_party/hamcrest/v1_3/hamcrest-core-1.3.0RC2.jar',
            '../third_party/hamcrest/v1_3/hamcrest-generator-1.3.0RC2.jar',
            '../third_party/hamcrest/v1_3/hamcrest-integration-1.3.0RC2.jar',
            '../third_party/hamcrest/v1_3/hamcrest-library-1.3.0RC2.jar',
          ],
          'outputs': [
            '<(INTERMEDIATE_DIR)/<(_target_name)/tests.jar',
            '<(PRODUCT_DIR)/analyzer/bin/dart_analyzer',
            '<(PRODUCT_DIR)/analyzer/bin/dart_analyzer.bat',
            '<(PRODUCT_DIR)/analyzer/util/analyzer/dart_analyzer.jar',
            '<(PRODUCT_DIR)/analyzer/util/analyzer/args4j/2.0.12/args4j-2.0.12.jar',
            '<(PRODUCT_DIR)/analyzer/util/analyzer/guava/r13/guava-13.0.1.jar',
          ],
          'action' : [
            '../third_party/apache_ant/1.8.4/bin/ant<(script_suffix)',
            '-f', 'dart_analyzer.xml',
            '-Dbuild.dir=<(INTERMEDIATE_DIR)/<(_target_name)',
            '-Ddist.dir=<(PRODUCT_DIR)/analyzer',
            'clean',
            'dist',
            'tests.jar',
          ],
          'message': 'Building dart_analyzer.',
        },
        {
          'action_name': 'copy_tests',
          'inputs': [ '<(INTERMEDIATE_DIR)/<(_target_name)/tests.jar' ],
          'outputs': [ '<(PRODUCT_DIR)/analyzer/dart_analyzer_tests.jar' ],
          'action': [ 'cp', '<@(_inputs)', '<@(_outputs)' ]
        },
      ],
    },
    {
      # GYP won't generate a catch-all target if there's only one target.
      'target_name': 'dummy',
      'type': 'none',
    },
  ],
}
