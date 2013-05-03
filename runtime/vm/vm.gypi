# Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

{
  'variables': {
    'gen_source_dir': '<(LIB_DIR)',
    'libgen_in_cc_file': '../lib/libgen_in.cc',
    'builtin_in_cc_file': '../bin/builtin_in.cc',
    'async_cc_file': '<(gen_source_dir)/async_gen.cc',
    'async_patch_cc_file': '<(gen_source_dir)/async_patch_gen.cc',
    'corelib_cc_file': '<(gen_source_dir)/corelib_gen.cc',
    'corelib_patch_cc_file': '<(gen_source_dir)/corelib_patch_gen.cc',
    'collection_cc_file': '<(gen_source_dir)/collection_gen.cc',
    'collection_patch_cc_file': '<(gen_source_dir)/collection_patch_gen.cc',
    'collection_dev_cc_file': '<(gen_source_dir)/collection_dev_gen.cc',
    'collection_dev_patch_cc_file': '<(gen_source_dir)/collection_dev_patch_gen.cc',
    'crypto_cc_file': '<(gen_source_dir)/crypto_gen.cc',
    'math_cc_file': '<(gen_source_dir)/math_gen.cc',
    'math_patch_cc_file': '<(gen_source_dir)/math_patch_gen.cc',
    'mirrors_cc_file': '<(gen_source_dir)/mirrors_gen.cc',
    'mirrors_patch_cc_file': '<(gen_source_dir)/mirrors_patch_gen.cc',
    'isolate_cc_file': '<(gen_source_dir)/isolate_gen.cc',
    'isolate_patch_cc_file': '<(gen_source_dir)/isolate_patch_gen.cc',
    'json_cc_file': '<(gen_source_dir)/json_gen.cc',
    'json_patch_cc_file': '<(gen_source_dir)/json_patch_gen.cc',
    'typed_data_cc_file': '<(gen_source_dir)/typed_data_gen.cc',
    'typed_data_patch_cc_file': '<(gen_source_dir)/typed_data_patch_gen.cc',
    'uri_cc_file': '<(gen_source_dir)/uri_gen.cc',
    'utf_cc_file': '<(gen_source_dir)/utf_gen.cc',
    'snapshot_test_dat_file': '<(gen_source_dir)/snapshot_test.dat',
    'snapshot_test_in_dat_file': 'snapshot_test_in.dat',
    'snapshot_test_dart_file': 'snapshot_test.dart',
  },
  'targets': [
    {
      'target_name': 'libdart_vm',
      'type': 'static_library',
      'toolsets':['host', 'target'],
      'includes': [
        'vm_sources.gypi',
        '../platform/platform_headers.gypi',
        '../platform/platform_sources.gypi',
      ],
      'sources/': [
        # Exclude all _test.[cc|h] files.
        ['exclude', '_test\\.(cc|h)$'],
      ],
      'include_dirs': [
        '..',
      ],
      'conditions': [
        ['OS=="android"', {
          'link_settings': {
            'libraries': [
              '-lc',
              '-lpthread',
            ],
          },
        }],
        ['OS=="linux"', {
          'link_settings': {
            'libraries': [
              '-lpthread',
              '-lrt',
            ],
          },
        }],
        ['OS=="win"', {
          'sources/' : [
            ['exclude', 'gdbjit.cc'],
          ],
       }],
       ['dart_vtune_support==0', {
          'sources/' : [
            ['exclude', 'vtune\\.(cc|h)$'],
          ],
       }],
       ['dart_vtune_support==1', {
          'include_dirs': ['<(dart_vtune_root)/include'],
          'defines': ['DART_VTUNE_SUPPORT'],
          'link_settings': {
            'conditions': [
              ['OS=="linux"', {
                 'libraries': ['-ljitprofiling'],
              }],
              ['OS=="win"', {
                 'libraries': ['-ljitprofiling.lib'],
              }],
            ],
          },
        }]],
    },
    {
      'target_name': 'libdart_lib_withcore',
      'type': 'static_library',
      'toolsets':['host', 'target'],
      'dependencies': [
        'generate_async_cc_file',
        'generate_async_patch_cc_file',
        'generate_corelib_cc_file',
        'generate_corelib_patch_cc_file',
        'generate_collection_cc_file',
        'generate_collection_patch_cc_file',
        'generate_collection_dev_cc_file',
        'generate_collection_dev_patch_cc_file',
        'generate_crypto_cc_file',
        'generate_math_cc_file',
        'generate_math_patch_cc_file',
        'generate_isolate_cc_file',
        'generate_isolate_patch_cc_file',
        'generate_json_cc_file',
        'generate_json_patch_cc_file',
        'generate_mirrors_cc_file',
        'generate_mirrors_patch_cc_file',
        'generate_typed_data_cc_file',
        'generate_typed_data_patch_cc_file',
        'generate_uri_cc_file',
        'generate_utf_cc_file',
      ],
      'includes': [
        '../lib/async_sources.gypi',
        '../lib/collection_sources.gypi',
        '../lib/corelib_sources.gypi',
        '../lib/isolate_sources.gypi',
        '../lib/math_sources.gypi',
        '../lib/mirrors_sources.gypi',
        '../lib/typed_data_sources.gypi',
      ],
      'sources': [
        'bootstrap.cc',
        # Include generated source files.
        '<(async_cc_file)',
        '<(async_patch_cc_file)',
        '<(corelib_cc_file)',
        '<(corelib_patch_cc_file)',
        '<(collection_cc_file)',
        '<(collection_patch_cc_file)',
        '<(collection_dev_cc_file)',
        '<(collection_dev_patch_cc_file)',
        '<(crypto_cc_file)',
        '<(math_cc_file)',
        '<(math_patch_cc_file)',
        '<(isolate_cc_file)',
        '<(isolate_patch_cc_file)',
        '<(json_cc_file)',
        '<(json_patch_cc_file)',
        '<(mirrors_cc_file)',
        '<(mirrors_patch_cc_file)',
        '<(typed_data_cc_file)',
        '<(typed_data_patch_cc_file)',
        '<(uri_cc_file)',
        '<(utf_cc_file)',
      ],
      'include_dirs': [
        '..',
      ],
    },
    {
      'target_name': 'libdart_lib',
      'type': 'static_library',
      'toolsets':['host', 'target'],
      'includes': [
        '../lib/async_sources.gypi',
        '../lib/collection_sources.gypi',
        '../lib/corelib_sources.gypi',
        '../lib/isolate_sources.gypi',
        '../lib/math_sources.gypi',
        '../lib/mirrors_sources.gypi',
        '../lib/typed_data_sources.gypi',
      ],
      'sources': [
        'bootstrap_nocorelib.cc',
      ],
      'include_dirs': [
        '..',
      ],
    },
    {
      'target_name': 'generate_async_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        '../../sdk/lib/async/async_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_async_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(async_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(async_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::async_source_paths_',
            '--library_name', 'dart:async',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(async_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_corelib_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared core library sources.
        '../../sdk/lib/core/corelib_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_corelib_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(corelib_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(corelib_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::corelib_source_paths_',
            '--library_name', 'dart:core',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(corelib_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_corelib_patch_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the runtime implementation sources.
        '../lib/corelib_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_corelib_patch_cc',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(builtin_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(corelib_patch_cc_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(corelib_patch_cc_file)',
            '--input_cc', '<(builtin_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::corelib_patch_',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(corelib_patch_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_collection_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared collection library sources.
        '../../sdk/lib/collection/collection_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_collection_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(collection_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(collection_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::collection_source_paths_',
            '--library_name', 'dart:collection',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(collection_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_collection_dev_patch_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the runtime implementation sources.
        '../lib/collection_dev_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_collection_dev_patch_cc',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(builtin_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(collection_dev_patch_cc_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(collection_dev_patch_cc_file)',
            '--input_cc', '<(builtin_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::collection_dev_patch_',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(collection_dev_patch_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_collection_dev_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared collection_dev library sources.
        '../../sdk/lib/_collection_dev/collection_dev_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_collection_dev_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(collection_dev_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(collection_dev_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::collection_dev_source_paths_',
            '--library_name', 'dart:_collection-dev',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(collection_dev_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_crypto_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared crypto sources.
        '../../sdk/lib/crypto/crypto_sources.gypi',
      ],
      'actions': [
        {
          'action_name': 'generate_crypto_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(crypto_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(crypto_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::crypto_source_paths_',
            '--library_name', 'dart:crypto',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(crypto_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_math_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared math library sources.
        '../../sdk/lib/math/math_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_math_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(math_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(math_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::math_source_paths_',
            '--library_name', 'dart:math',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(math_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_math_patch_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared math library sources.
        '../lib/math_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_math_patch_cc',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(builtin_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(math_patch_cc_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(math_patch_cc_file)',
            '--input_cc', '<(builtin_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::math_patch_',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(math_patch_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_mirrors_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared core library sources.
        '../../sdk/lib/mirrors/mirrors_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_mirrors_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(mirrors_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(mirrors_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::mirrors_source_paths_',
            '--library_name', 'dart:mirrors',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(mirrors_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_mirrors_patch_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the patch sources.
        '../lib/mirrors_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_mirrors_patch_cc',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(builtin_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(mirrors_patch_cc_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(mirrors_patch_cc_file)',
            '--input_cc', '<(builtin_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::mirrors_patch_',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(mirrors_patch_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_isolate_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the runtime implementation sources.
        '../../sdk/lib/isolate/isolate_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_isolate_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(isolate_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(isolate_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::isolate_source_paths_',
            '--library_name', 'dart:isolate',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(isolate_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_async_patch_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the runtime implementation sources.
        '../lib/async_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_async_patch_cc',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(builtin_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(async_patch_cc_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(async_patch_cc_file)',
            '--input_cc', '<(builtin_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::async_patch_',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(async_patch_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_collection_patch_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the runtime implementation sources.
        '../lib/collection_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_collection_patch_cc',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(builtin_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(collection_patch_cc_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(collection_patch_cc_file)',
            '--input_cc', '<(builtin_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::collection_patch_',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(collection_patch_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_isolate_patch_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the runtime implementation sources.
        '../lib/isolate_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_isolate_patch_cc',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(builtin_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(isolate_patch_cc_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(isolate_patch_cc_file)',
            '--input_cc', '<(builtin_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::isolate_patch_',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(isolate_patch_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_json_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared json sources.
        '../../sdk/lib/json/json_sources.gypi',
      ],
      'actions': [
        {
          'action_name': 'generate_json_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(json_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(json_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::json_source_paths_',
            '--library_name', 'dart:json',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(json_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_json_patch_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared json library sources.
        '../lib/json_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_json_patch_cc',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(builtin_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(json_patch_cc_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(json_patch_cc_file)',
            '--input_cc', '<(builtin_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::json_patch_',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(json_patch_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_typed_data_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared library sources.
        '../../sdk/lib/typed_data/typed_data_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_typed_data_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(typed_data_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(typed_data_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::typed_data_source_paths_',
            '--library_name', 'dart:typed_data',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(typed_data_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_typed_data_patch_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the runtime implementation sources.
        '../lib/typed_data_sources.gypi',
      ],
      'sources/': [
        # Exclude all .[cc|h] files.
        # This is only here for reference. Excludes happen after
        # variable expansion, so the script has to do its own
        # exclude processing of the sources being passed.
        ['exclude', '\\.cc|h$'],
      ],
      'actions': [
        {
          'action_name': 'generate_typed_data_patch_cc',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(builtin_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(typed_data_patch_cc_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(typed_data_patch_cc_file)',
            '--input_cc', '<(builtin_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::typed_data_patch_',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(typed_data_patch_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_uri_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared uri sources.
        '../../sdk/lib/uri/uri_sources.gypi',
      ],
      'actions': [
        {
          'action_name': 'generate_uri_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(uri_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(uri_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::uri_source_paths_',
            '--library_name', 'dart:uri',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(uri_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_utf_cc_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'includes': [
        # Load the shared utf sources.
        '../../sdk/lib/utf/utf_sources.gypi',
      ],
      'actions': [
        {
          'action_name': 'generate_utf_cc',
          'inputs': [
            '../tools/gen_library_src_paths.py',
            '<(libgen_in_cc_file)',
            '<@(_sources)',
          ],
          'outputs': [
            '<(utf_cc_file)',
          ],
          'action': [
            'python',
            'tools/gen_library_src_paths.py',
            '--output', '<(utf_cc_file)',
            '--input_cc', '<(libgen_in_cc_file)',
            '--include', 'vm/bootstrap.h',
            '--var_name', 'dart::Bootstrap::utf_source_paths_',
            '--library_name', 'dart:utf',
            '<@(_sources)',
          ],
          'message': 'Generating ''<(utf_cc_file)'' file.'
        },
      ]
    },
    {
      'target_name': 'generate_snapshot_test_dat_file',
      'type': 'none',
      'toolsets':['host', 'target'],
      'actions': [
        {
          'action_name': 'generate_snapshot_test_dat',
          'inputs': [
            '../tools/create_string_literal.py',
            '<(snapshot_test_in_dat_file)',
            '<(snapshot_test_dart_file)',
          ],
          'outputs': [
            '<(snapshot_test_dat_file)',
          ],
          'action': [
            'python',
            'tools/create_string_literal.py',
            '--output', '<(snapshot_test_dat_file)',
            '--input_cc', '<(snapshot_test_in_dat_file)',
            '--include', 'INTENTIONALLY_LEFT_BLANK',
            '--var_name', 'INTENTIONALLY_LEFT_BLANK_TOO',
            '<(snapshot_test_dart_file)',
          ],
          'message': 'Generating ''<(snapshot_test_dat_file)'' file.'
        },
      ]
    },
  ]
}
