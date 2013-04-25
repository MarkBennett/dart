// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * This file contains functionality for getting dart version numbers using
 * our standard version construction method. Systems that does not include this
 * file should emulate the structure for revision numbers that we have here.
 *
 * The version number of a dart build is constructed as follows:
 *   1. The major, minor, build and patch numbers are extracted from the VERSION
 *      file in the root directory. We call these MAJOR, MINOR, BUILD and PATCH.
 *   2. The svn revision number for the current checkout is extracted from the
 *      source control system that is used in the current checkout. We call this
 *      REVISION.
 *   3. If this is _not_ a official build, i.e., this is not build by our
 *      buildbot infrastructure, we extract the user-name of the logged in
 *      person from the operating system. We call this USERNAME.
 *   4. The version number is constructed as follows:
 *      MAJOR.MINOR.BUILD.PATCH_rREVISION_USERNAME
 */

library version;

import "dart:async";
import "dart:io";

/**
 * Generates version information for builds.
 */
class Version {
  String _versionFileName;
  String USERNAME;
  int REVISION;
  int MAJOR;
  int MINOR;
  int BUILD;
  int PATCH;

  Version(Path versionFile) {
    _versionFileName = versionFile.toNativePath();
  }

  /**
   * Get the version number for this specific build using the version info
   * from the VERSION file in the root directory and the revision info
   * from the source control system of the current checkout.
   */
  Future<String> getVersion() {
    File f = new File(_versionFileName);
    Completer c = new Completer();

    var wasCompletedWithError = false;
    completeError(String msg) {
      if (!wasCompletedWithError) {
        c.completeError(msg);
        wasCompletedWithError = true;
      }
    }
    f.exists().then((existed) {
      if (!existed) {
        completeError("No VERSION file");
        return;
      }
      Stream<String> stream =
          f.openRead().transform(new StringDecoder())
                      .transform(new LineTransformer());
      stream.listen((String line) {
        if (line == null) {
          completeError(
              "VERSION input file seems to be in the wrong format");
          return;
        }
        var values = line.split(" ");
        if (values.length != 2) {
          completeError(
              "VERSION input file seems to be in the wrong format");
          return;
        }
        var number = 0;
        try {
          number = int.parse(values[1]);
        } catch (e) {
          completeError("Can't parse version numbers, not an int");
          return;
        }
        switch (values[0]) {
          case "MAJOR":
            MAJOR = number;
            break;
          case "MINOR":
            MINOR = number;
            break;
          case "BUILD":
            BUILD = number;
            break;
          case "PATCH":
            PATCH = number;
            break;
          default:
            completeError("Wrong format in VERSION file, line does not "
                            "contain one of {MAJOR, MINOR, BUILD, PATCH}");
            return;
        }
      },
      onDone: () {
        // Only complete if we did not already complete with a failure.
        if (!wasCompletedWithError) {
          getRevision().then((revision) {
            REVISION = revision;
            USERNAME = getUserName();
            var userNameString = "";
            if (USERNAME != '') userNameString = "_$USERNAME";
            var revisionString = "";
            if (revision != 0) revisionString = "_r$revision";
            c.complete(
                "$MAJOR.$MINOR.$BUILD.$PATCH$revisionString$userNameString");
            return;
          });
        }
      });
    });
    return c.future;
  }

  String getExecutableSuffix() {
    if (Platform.operatingSystem == 'windows') {
      return '.bat';
    }
    return '';
  }

  int getRevisionFromSvnInfo(String info) {
    if (info == null || info == '') return 0;
    var lines = info.split("\n");
    RegExp exp = new RegExp(r"Last Changed Rev: (\d*)");
    for (var line in lines) {
      if (exp.hasMatch(line)) {
        String revisionString = (exp.firstMatch(line).group(1));
        try {
          return int.parse(revisionString);
        } catch(e) {
          return 0;
        }
      }
    }
    return 0;
  }

  Future<int> getRevision() {
    if (repositoryType == RepositoryType.UNKNOWN) {
      return new Future.immediate(0);
    }
    var isSvn = repositoryType == RepositoryType.SVN;
    var command = isSvn ? "svn" : "git";
    command = "$command${getExecutableSuffix()}";
    var arguments = isSvn ? ["info"] : ["svn", "info"];
    ProcessOptions options = new ProcessOptions();
    // Run the command from the root to get the last changed revision for this
    // "branch". Since we have both trunk and bleeding edge in the same
    // repository and since we always build TOT we need this to get the
    // right version number.
    Path toolsDirectory = new Path(_versionFileName).directoryPath;
    Path root = toolsDirectory.join(new Path(".."));
    options.workingDirectory = root.toNativePath();
    return Process.run(command, arguments, options).then((result) {
      if (result.exitCode != 0) {
        return 0;
      }
      return getRevisionFromSvnInfo(result.stdout);
    });
  }

  bool isProductionBuild(String username) {
    return username == "chrome-bot";
  }

  String getUserName() {
    // TODO(ricow): Don't add this on the buildbot.
    var key = "USER";
    if (Platform.operatingSystem == 'windows') {
      key = "USERNAME";
    }
    if (!Platform.environment.containsKey(key)) return "";
    var username = Platform.environment[key];
    // If this is a production build, i.e., this is something we are shipping,
    // don't suffix  the version with the username.
    if (isProductionBuild(username)) return "";
    return username;
  }

  bool isGitRepository() {
    var currentPath = new Path(new Directory.current().path);
    while (!new Directory.fromPath(currentPath.append(".git")).existsSync()) {
      currentPath = currentPath.directoryPath;
      if (currentPath.toString() == "/") {
        break;
      }
    }
    return new Directory.fromPath(currentPath.append(".git")).existsSync();
  }

  RepositoryType get repositoryType {
    if (new Directory(".svn").existsSync()) return RepositoryType.SVN;
    if (isGitRepository()) return RepositoryType.GIT;
    return RepositoryType.UNKNOWN;
  }
}

class RepositoryType {
  static final RepositoryType SVN = const RepositoryType("SVN");
  static final RepositoryType GIT = const RepositoryType("GIT");
  static final RepositoryType UNKNOWN = const RepositoryType("UNKNOWN");

  const RepositoryType(String this.name);

  static RepositoryType guessType() {
    if (new Directory(".svn").existsSync()) return RepositoryType.SVN;
    if (new Directory(".git").existsSync()) return RepositoryType.GIT;
    return RepositoryType.UNKNOWN;
  }

  String toString() => name;

  final String name;
}
