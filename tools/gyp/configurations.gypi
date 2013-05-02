# Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

{
  'variables': {
    'common_gcc_warning_flags': [
      '-Wall',
      '-Wextra', # Also known as -W.
      '-Wno-unused-parameter',
    ],

    # Default value.  This may be overridden in a containing project gyp.
    'target_arch%': 'ia32',

  'conditions': [
    ['"<(target_arch)"=="ia32"', { 'dart_target_arch': 'IA32', }],
    ['"<(target_arch)"=="x64"', { 'dart_target_arch': 'X64', }],
    ['"<(target_arch)"=="arm"', { 'dart_target_arch': 'ARM', }],
    ['"<(target_arch)"=="simarm"', { 'dart_target_arch': 'SIMARM', }],
    ['"<(target_arch)"=="mips"', { 'dart_target_arch': 'MIPS', }],
    ['"<(target_arch)"=="simmips"', { 'dart_target_arch': 'SIMMIPS', }],
  ],
  },
  'conditions': [
    [ 'OS=="android"', { 'includes': [ 'configurations_android.gypi', ], } ],
    [ 'OS=="linux"', { 'includes': [ 'configurations_make.gypi', ], } ],
    [ 'OS=="mac"', { 'includes': [ 'configurations_xcode.gypi', ], } ],
    [ 'OS=="win"', { 'includes': [ 'configurations_msvs.gypi', ], } ],
  ],
  'target_defaults': {
    'default_configuration': 'DebugIA32',
    'configurations': {
      'Dart_Base': {
        'abstract': 1,
      },

      'Dart_ia32_Base': {
        'abstract': 1,
      },

      'Dart_x64_Base': {
        'abstract': 1,
      },

      'Dart_simarm_Base': {
        'abstract': 1,
        'defines': [
          'TARGET_ARCH_ARM',
        ]
      },

      'Dart_arm_Base': {
        'abstract': 1,
        'defines': [
          'TARGET_ARCH_ARM',
        ],
      },

      'Dart_simmips_Base': {
        'abstract': 1,
        'defines': [
          'TARGET_ARCH_MIPS',
        ]
      },

      'Dart_mips_Base': {
        'abstract': 1,
        'defines': [
          'TARGET_ARCH_MIPS',
        ],
      },

      'Dart_Debug': {
        'abstract': 1,
      },

      'Dart_Release': {
        'abstract': 1,
        'defines': [
          'NDEBUG',
        ],
      },

      'DebugIA32': {
        'inherit_from': ['Dart_Base', 'Dart_ia32_Base', 'Dart_Debug'],
      },

      'ReleaseIA32': {
        'inherit_from': ['Dart_Base', 'Dart_ia32_Base', 'Dart_Release'],
      },

      'DebugX64': {
        'inherit_from': ['Dart_Base', 'Dart_x64_Base', 'Dart_Debug'],
      },

      'ReleaseX64': {
        'inherit_from': ['Dart_Base', 'Dart_x64_Base', 'Dart_Release'],
      },

      'DebugSIMARM': {
        'inherit_from': ['Dart_Base', 'Dart_simarm_Base', 'Dart_Debug'],
        'defines': [
          'DEBUG',
        ],
      },

      'ReleaseSIMARM': {
        'inherit_from': ['Dart_Base', 'Dart_simarm_Base', 'Dart_Release'],
      },

      'DebugARM': {
        'inherit_from': ['Dart_Base', 'Dart_arm_Base', 'Dart_Debug'],
      },

      'ReleaseARM': {
        'inherit_from': ['Dart_Base', 'Dart_arm_Base', 'Dart_Release'],
      },

      'DebugSIMMIPS': {
        'inherit_from': ['Dart_Base', 'Dart_simmips_Base', 'Dart_Debug'],
        'defines': [
          'DEBUG',
        ],
      },

      'ReleaseSIMMIPS': {
        'inherit_from': ['Dart_Base', 'Dart_simmips_Base', 'Dart_Release'],
      },

      'DebugMIPS': {
        'inherit_from': ['Dart_Base', 'Dart_mips_Base', 'Dart_Debug'],
      },

      'ReleaseMIPS': {
        'inherit_from': ['Dart_Base', 'Dart_mips_Base', 'Dart_Release'],
      },

      # These targets assume that target_arch is passed in explicitly
      # by the containing project (e.g., chromium).
      'Debug': {
        'inherit_from': ['Debug<(dart_target_arch)']
      },

      'Release': {
        'inherit_from': ['Release<(dart_target_arch)']
      },
    },
  },
}
