#!/usr/bin/env python
#
# Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.
#

import optparse
import os
import re
import shutil
import subprocess
import sys
import utils

HOST_OS = utils.GuessOS()
HOST_CPUS = utils.GuessCpus()
SCRIPT_DIR = os.path.dirname(sys.argv[0])
DART_ROOT = os.path.realpath(os.path.join(SCRIPT_DIR, '..'))
THIRD_PARTY_ROOT = os.path.join(DART_ROOT, 'third_party')

arm_cc_error = """
Couldn't find the arm cross compiler.
To make sure that you have the arm cross compilation tools installed, run:

$ wget http://src.chromium.org/chrome/trunk/src/build/install-build-deps.sh
OR
$ svn co http://src.chromium.org/chrome/trunk/src/build; cd build
Then,
$ chmod u+x install-build-deps.sh
$ ./install-build-deps.sh --arm --no-chromeos-fonts
"""
DEFAULT_ARM_CROSS_COMPILER_PATH = '/usr'

def BuildOptions():
  result = optparse.OptionParser()
  result.add_option("-m", "--mode",
      help='Build variants (comma-separated).',
      metavar='[all,debug,release]',
      default='debug')
  result.add_option("-v", "--verbose",
      help='Verbose output.',
      default=False, action="store_true")
  result.add_option("-a", "--arch",
      help='Target architectures (comma-separated).',
      metavar='[all,ia32,x64,simarm,arm,simmips,mips]',
      default=utils.GuessArchitecture())
  result.add_option("--os",
    help='Target OSs (comma-separated).',
    metavar='[all,host,android]',
    default='host')
  result.add_option("-j",
      help='The number of parallel jobs to run.',
      metavar=HOST_CPUS,
      default=str(HOST_CPUS))
  (vs_directory, vs_executable) = utils.GuessVisualStudioPath()
  result.add_option("--devenv",
      help='Path containing devenv.com on Windows',
      default=vs_directory)
  result.add_option("--executable",
      help='Name of the devenv.com/msbuild executable on Windows (varies for '
           'different versions of Visual Studio)',
      default=vs_executable)
  return result


def ProcessOsOption(os):
  if os == 'host':
    return HOST_OS
  return os


def ProcessOptions(options, args):
  if options.arch == 'all':
    options.arch = 'ia32,x64,simarm,simmips'
  if options.mode == 'all':
    options.mode = 'release,debug'
  if options.os == 'all':
    options.os = 'host,android'
  options.mode = options.mode.split(',')
  options.arch = options.arch.split(',')
  options.os = options.os.split(',')
  for mode in options.mode:
    if not mode in ['debug', 'release']:
      print "Unknown mode %s" % mode
      return False
  for arch in options.arch:
    if not arch in ['ia32', 'x64', 'simarm', 'arm', 'simmips', 'mips']:
      print "Unknown arch %s" % arch
      return False
  options.os = [ProcessOsOption(os) for os in options.os]
  for os in options.os:
    if not os in ['android', 'freebsd', 'linux', 'macos', 'win32']:
      print "Unknown os %s" % os
      return False
    if os != HOST_OS:
      if os != 'android':
        print "Unsupported target os %s" % os
        return False
      if not HOST_OS in ['linux']:
        print ("Cross-compilation to %s is not supported on host os %s."
               % (os, HOST_OS))
        return False
      if not arch in ['ia32']:
        print ("Cross-compilation to %s is not supported for architecture %s."
               % (os, arch))
        return False
      # We have not yet tweaked the v8 dart build to work with the Android
      # NDK/SDK, so don't try to build it.
      if args == []:
        print "For android builds you must specify a target, such as 'dart'."
        return False
      if 'v8' in args:
        print "The v8 target is not supported for android builds."
        return False
  return True


def SetTools(arch, toolchainprefix):
  toolsOverride = None
  if arch == 'arm' and toolchainprefix == None:
    toolchainprefix = DEFAULT_ARM_CROSS_COMPILER_PATH + "/bin/arm-linux-gnueabi"
  if toolchainprefix:
    toolsOverride = {
      "CC.target"  :  toolchainprefix + "-gcc",
      "CXX.target" :  toolchainprefix + "-g++",
      "AR.target"  :  toolchainprefix + "-ar",
      "LINK.target":  toolchainprefix + "-g++",
      "NM.target"  :  toolchainprefix + "-nm",
    }
  return toolsOverride


def CheckDirExists(path, docstring):
  if not os.path.isdir(path):
    raise Exception('Could not find %s directory %s'
          % (docstring, path))


def SetCrossCompilationEnvironment(host_os, target_os, target_arch, old_path):
  global THIRD_PARTY_ROOT
  if host_os not in ['linux']:
    raise Exception('Unsupported host os %s' % host_os)
  if target_os not in ['android']:
    raise Exception('Unsupported target os %s' % target_os)
  if target_arch not in ['ia32']:
    raise Exception('Unsupported target architecture %s' % target_arch)

  CheckDirExists(THIRD_PARTY_ROOT, 'third party tools');
  android_tools = os.path.join(THIRD_PARTY_ROOT, 'android_tools')
  CheckDirExists(android_tools, 'Android tools')
  android_ndk_root = os.path.join(android_tools, 'ndk')
  CheckDirExists(android_ndk_root, 'Android NDK')
  android_sdk_root = os.path.join(android_tools, 'sdk')
  CheckDirExists(android_sdk_root, 'Android SDK')

  os.environ['ANDROID_NDK_ROOT'] = android_ndk_root
  os.environ['ANDROID_SDK_ROOT'] = android_sdk_root

  toolchain_arch = 'x86-4.4.3'
  toolchain_dir = 'linux-x86'
  android_toolchain = os.path.join(android_ndk_root,
      'toolchains', toolchain_arch,
      'prebuilt', toolchain_dir, 'bin')
  CheckDirExists(android_toolchain, 'Android toolchain')

  os.environ['ANDROID_TOOLCHAIN'] = android_toolchain

  android_sdk_version = 9

  android_sdk_tools = os.path.join(android_sdk_root, 'tools')
  CheckDirExists(android_sdk_tools, 'Android SDK tools')

  android_sdk_platform_tools = os.path.join(android_sdk_root, 'platform-tools')
  CheckDirExists(android_sdk_platform_tools, 'Android SDK platform tools')

  pathList = [old_path,
              android_ndk_root,
              android_sdk_tools,
              android_sdk_platform_tools,
              # for Ninja - maybe don't need?
              android_toolchain
              ]
  os.environ['PATH'] = ':'.join(pathList)

  gypDefinesList = [
    'target_arch=ia32',
    'OS=%s' % target_os,
    'android_build_type=0',
    'host_os=%s' % host_os,
    'linux_fpic=1',
    'release_optimize=s',
    'linux_use_tcmalloc=0',
    'android_sdk=%s', os.path.join(android_sdk_root, 'platforms',
        'android-%d' % android_sdk_version),
    'android_sdk_tools=%s' % android_sdk_platform_tools
    ]

  os.environ['GYP_DEFINES'] = ' '.join(gypDefinesList)


def Execute(args):
  process = subprocess.Popen(args)
  process.wait()
  if process.returncode != 0:
    raise Exception(args[0] + " failed")


def GClientRunHooks():
  Execute(['gclient', 'runhooks'])


def RunhooksIfNeeded(host_os, mode, arch, target_os):
  if host_os != 'linux':
    return
  build_root = utils.GetBuildRoot(host_os)
  build_cookie_path = os.path.join(build_root, 'lastHooksTargetOS.txt')

  old_target_os = None
  try:
    with open(build_cookie_path) as f:
      old_target_os = f.read(1024)
  except IOError as e:
    pass
  if target_os != old_target_os:
    try:
      os.mkdir(build_root)
    except OSError as e:
      pass
    with open(build_cookie_path, 'w') as f:
      f.write(target_os)
    GClientRunHooks()


def CurrentDirectoryBaseName():
  """Returns the name of the current directory"""
  return os.path.relpath(os.curdir, start=os.pardir)


def FilterEmptyXcodebuildSections(process):
  """
  Filter output from xcodebuild so empty sections are less verbose.

  The output from xcodebuild looks like this:

Build settings from command line:
    SYMROOT = .../xcodebuild

=== BUILD AGGREGATE TARGET samples OF PROJECT dart WITH CONFIGURATION ...
Check dependencies


=== BUILD AGGREGATE TARGET upload_sdk OF PROJECT dart WITH CONFIGURATION ...
Check dependencies

PhaseScriptExecution "Action \"upload_sdk_py\"" xcodebuild/dart.build/...
    cd ...
    /bin/sh -c .../xcodebuild/dart.build/ReleaseIA32/upload_sdk.build/...


** BUILD SUCCEEDED **

  """

  def is_empty_chunk(chunk):
    empty_chunk = ['Check dependencies', '', '']
    return not chunk or (len(chunk) == 4 and chunk[1:] == empty_chunk)

  def unbuffered(callable):
    # Use iter to disable buffering in for-in.
    return iter(callable, '')

  section = None
  chunk = []
  # Is stdout a terminal which supports colors?
  is_fancy_tty = False
  clr_eol = None
  if sys.stdout.isatty():
    term = os.getenv('TERM', 'dumb')
    # The capability "clr_eol" means clear the line from cursor to end
    # of line.  See man pages for tput and terminfo.
    try:
      with open('/dev/null', 'a') as dev_null:
        clr_eol = subprocess.check_output(['tput', '-T' + term, 'el'],
                                          stderr=dev_null)
      if clr_eol:
        is_fancy_tty = True
    except subprocess.CalledProcessError:
      is_fancy_tty = False
    except AttributeError:
      is_fancy_tty = False
  pattern = re.compile(r'=== BUILD .* TARGET (.*) OF PROJECT (.*) WITH ' +
                       r'CONFIGURATION (.*) ===')
  has_interesting_info = False
  for line in unbuffered(process.stdout.readline):
    line = line.rstrip()
    if line.startswith('=== BUILD ') or line.startswith('** BUILD '):
      has_interesting_info = False
      section = line
      if is_fancy_tty:
        match = re.match(pattern, section)
        if match:
          section = '%s/%s/%s' % (
            match.group(3), match.group(2), match.group(1))
        # Truncate to avoid extending beyond 80 columns.
        section = section[:80]
        # If stdout is a terminal, emit "progress" information.  The
        # progress information is the first line of the current chunk.
        # After printing the line, move the cursor back to the
        # beginning of the line.  This has two effects: First, if the
        # chunk isn't empty, the first line will be overwritten
        # (avoiding duplication).  Second, the next segment line will
        # overwrite it too avoid long scrollback.  clr_eol ensures
        # that there is no trailing garbage when a shorter line
        # overwrites a longer line.
        print '%s%s\r' % (clr_eol, section),
      chunk = []
    if not section or has_interesting_info:
      print line
    else:
      length = len(chunk)
      if length == 1 and line != 'Check dependencies':
        has_interesting_info = True
      elif (length == 2 or length == 3) and line:
        has_interesting_info = True
      if has_interesting_info:
        print '\n'.join(chunk)
        chunk = []
      else:
        chunk.append(line)
  if not is_empty_chunk(chunk):
    print '\n'.join(chunk)


def Main():
  utils.ConfigureJava()
  # Parse the options.
  parser = BuildOptions()
  (options, args) = parser.parse_args()
  if not ProcessOptions(options, args):
    parser.print_help()
    return 1
  # Determine which targets to build. By default we build the "all" target.
  if len(args) == 0:
    if HOST_OS == 'macos':
      target = 'All'
    else:
      target = 'all'
  else:
    target = args[0]

  filter_xcodebuild_output = False
  # Remember path
  old_path = os.environ['PATH']
  # Build the targets for each requested configuration.
  for target_os in options.os:
    for mode in options.mode:
      for arch in options.arch:
        os.environ['DART_BUILD_MODE'] = mode
        build_config = utils.GetBuildConf(mode, arch)
        if HOST_OS == 'macos':
          filter_xcodebuild_output = True
          project_file = 'dart.xcodeproj'
          if os.path.exists('dart-%s.gyp' % CurrentDirectoryBaseName()):
            project_file = 'dart-%s.xcodeproj' % CurrentDirectoryBaseName()
          args = ['xcodebuild',
                  '-project',
                  project_file,
                  '-target',
                  target,
                  '-configuration',
                  build_config,
                  'SYMROOT=%s' % os.path.abspath('xcodebuild')
                  ]
        elif HOST_OS == 'win32':
          project_file = 'dart.sln'
          if os.path.exists('dart-%s.gyp' % CurrentDirectoryBaseName()):
            project_file = 'dart-%s.sln' % CurrentDirectoryBaseName()
          if target == 'all':
            args = [options.devenv + os.sep + options.executable,
                    '/build',
                    build_config,
                    project_file
                   ]
          else:
            args = [options.devenv + os.sep + options.executable,
                    '/build',
                    build_config,
                    '/project',
                    target,
                    project_file
                   ]
        else:
          make = 'make'
          if HOST_OS == 'freebsd':
            make = 'gmake'
            # work around lack of flock
            os.environ['LINK'] = '$(CXX)'
          args = [make,
                  '-j',
                  options.j,
                  'BUILDTYPE=' + build_config,
                  ]
          if target_os != HOST_OS:
            args += ['builddir_name=' + utils.GetBuildDir(HOST_OS, target_os)]
          if options.verbose:
            args += ['V=1']

          args += [target]

        if target_os != HOST_OS:
          SetCrossCompilationEnvironment(
              HOST_OS, target_os, arch, old_path)

        RunhooksIfNeeded(HOST_OS, mode, arch, target_os)

        toolchainprefix = None
        if target_os == 'android':
          toolchainprefix = ('%s/i686-linux-android'
                              % os.environ['ANDROID_TOOLCHAIN'])
        toolsOverride = SetTools(arch, toolchainprefix)
        if toolsOverride:
          printToolOverrides = target_os != 'android'
          for k, v in toolsOverride.iteritems():
            args.append(  k + "=" + v)
            if printToolOverrides:
              print k + " = " + v
          if not os.path.isfile(toolsOverride['CC.target']):
            if arch == 'arm':
              print arm_cc_error
            else:
              print "Couldn't find compiler: %s" % toolsOverride['CC.target']
            return 1


        print ' '.join(args)
        process = None
        if filter_xcodebuild_output:
          process = subprocess.Popen(args,
                                     stdin=None,
                                     bufsize=1, # Line buffered.
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT)
          FilterEmptyXcodebuildSections(process)
        else:
          process = subprocess.Popen(args, stdin=None)
        process.wait()
        if process.returncode != 0:
          print "BUILD FAILED"
          return 1

  return 0


if __name__ == '__main__':
  sys.exit(Main())
