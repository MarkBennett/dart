// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Handles version numbers, following the [Semantic Versioning][semver] spec.
///
/// [semver]: http://semver.org/
library version;

import 'dart:math';

import 'utils.dart';


/// Regex that matches a version number at the beginning of a string.
final _START_VERSION = new RegExp(
    r'^'                                        // Start at beginning.
    r'(\d+).(\d+).(\d+)'                        // Version number.
    r'(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?'    // Pre-release.
    r'(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?'); // Build.

/// Like [_START_VERSION] but matches the entire string.
final _COMPLETE_VERSION = new RegExp("${_START_VERSION.pattern}\$");

/// Parses a comparison operator ("<", ">", "<=", or ">=") at the beginning of
/// a string.
final _START_COMPARISON = new RegExp(r"^[<>]=?");

/// A parsed semantic version number.
class Version implements Comparable<Version>, VersionConstraint {
  /// No released version: i.e. "0.0.0".
  static Version get none => new Version(0, 0, 0);
  /// The major version number: "1" in "1.2.3".
  final int major;

  /// The minor version number: "2" in "1.2.3".
  final int minor;

  /// The patch version number: "3" in "1.2.3".
  final int patch;

  /// The pre-release identifier: "foo" in "1.2.3-foo". May be `null`.
  final String preRelease;

  /// The build identifier: "foo" in "1.2.3+foo". May be `null`.
  final String build;

  /// Creates a new [Version] object.
  Version(this.major, this.minor, this.patch, {String pre, this.build})
    : preRelease = pre {
    if (major < 0) throw new ArgumentError(
        'Major version must be non-negative.');
    if (minor < 0) throw new ArgumentError(
        'Minor version must be non-negative.');
    if (patch < 0) throw new ArgumentError(
        'Patch version must be non-negative.');
  }

  /// Creates a new [Version] by parsing [text].
  factory Version.parse(String text) {
    final match = _COMPLETE_VERSION.firstMatch(text);
    if (match == null) {
      throw new FormatException('Could not parse "$text".');
    }

    try {
      int major = int.parse(match[1]);
      int minor = int.parse(match[2]);
      int patch = int.parse(match[3]);

      String preRelease = match[5];
      String build = match[8];

      return new Version(major, minor, patch, pre: preRelease, build: build);
    } on FormatException catch (ex) {
      throw new FormatException('Could not parse "$text".');
    }
  }

  /// Returns the primary version out of a list of candidates. This is the
  /// highest-numbered stable (non-prerelease) version. If there are no stable
  /// versions, it's just the highest-numbered version.
  static Version primary(List<Version> versions) {
    var primary;
    for (var version in versions) {
      if (primary == null || (!version.isPreRelease && primary.isPreRelease) ||
          (version.isPreRelease == primary.isPreRelease && version > primary)) {
        primary = version;
      }
    }
    return primary;
  }

  bool operator ==(other) {
    if (other is! Version) return false;
    return compareTo(other) == 0;
  }

  bool operator <(Version other) => compareTo(other) < 0;
  bool operator >(Version other) => compareTo(other) > 0;
  bool operator <=(Version other) => compareTo(other) <= 0;
  bool operator >=(Version other) => compareTo(other) >= 0;

  bool get isAny => false;
  bool get isEmpty => false;

  /// Whether or not this is a pre-release version.
  bool get isPreRelease => preRelease != null;

  /// Tests if [other] matches this version exactly.
  bool allows(Version other) => this == other;

  VersionConstraint intersect(VersionConstraint other) {
    if (other.isEmpty) return other;

    // Intersect a version and a range.
    if (other is VersionRange) return other.intersect(this);

    // Intersecting two versions only works if they are the same.
    if (other is Version) {
      return this == other ? this : VersionConstraint.empty;
    }

    throw new ArgumentError(
        'Unknown VersionConstraint type $other.');
  }

  int compareTo(Version other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);

    if (preRelease != other.preRelease) {
      // Pre-releases always come before no pre-release string.
      if (preRelease == null) return 1;
      if (other.preRelease == null) return -1;

      return _compareStrings(preRelease, other.preRelease);
    }

    if (build != other.build) {
      // Builds always come after no build string.
      if (build == null) return -1;
      if (other.build == null) return 1;

      return _compareStrings(build, other.build);
    }

    return 0;
  }

  int get hashCode => toString().hashCode;

  String toString() {
    var buffer = new StringBuffer();
    buffer.write('$major.$minor.$patch');
    if (preRelease != null) buffer.write('-$preRelease');
    if (build != null) buffer.write('+$build');
    return buffer.toString();
  }

  /// Compares the string part of two versions. This is used for the pre-release
  /// and build version parts. This follows Rule 12. of the Semantic Versioning
  /// spec.
  int _compareStrings(String a, String b) {
    var aParts = _splitParts(a);
    var bParts = _splitParts(b);

    for (int i = 0; i < max(aParts.length, bParts.length); i++) {
      var aPart = (i < aParts.length) ? aParts[i] : null;
      var bPart = (i < bParts.length) ? bParts[i] : null;

      if (aPart != bPart) {
        // Missing parts come before present ones.
        if (aPart == null) return -1;
        if (bPart == null) return 1;

        if (aPart is int) {
          if (bPart is int) {
            // Compare two numbers.
            return aPart.compareTo(bPart);
          } else {
            // Numbers come before strings.
            return -1;
          }
        } else {
          if (bPart is int) {
            // Strings come after numbers.
            return 1;
          } else {
            // Compare two strings.
            return aPart.compareTo(bPart);
          }
        }
      }
    }
  }

  /// Splits a string of dot-delimited identifiers into their component parts.
  /// Identifiers that are numeric are converted to numbers.
  List _splitParts(String text) {
    return text.split('.').map((part) {
      try {
        return int.parse(part);
      } on FormatException catch (ex) {
        // Not a number.
        return part;
      }
    }).toList();
  }
}

/// A [VersionConstraint] is a predicate that can determine whether a given
/// version is valid or not. For example, a ">= 2.0.0" constraint allows any
/// version that is "2.0.0" or greater. Version objects themselves implement
/// this to match a specific version.
abstract class VersionConstraint {
  /// A [VersionConstraint] that allows all versions.
  static VersionConstraint any = new VersionRange();

  /// A [VersionConstraint] that allows no versions: i.e. the empty set.
  static VersionConstraint empty = const _EmptyVersion();

  /// Parses a version constraint. This string is either "any" or a series of
  /// version parts. Each part can be one of:
  ///
  ///   * A version string like `1.2.3`. In other words, anything that can be
  ///     parsed by [Version.parse()].
  ///   * A comparison operator (`<`, `>`, `<=`, or `>=`) followed by a version
  ///     string.
  ///
  /// Whitespace is ignored.
  ///
  /// Examples:
  ///
  ///     any
  ///     1.2.3-alpha
  ///     <=5.1.4
  ///     >2.0.4 <= 2.4.6
  factory VersionConstraint.parse(String text) {
    // Handle the "any" constraint.
    if (text.trim() == "any") return new VersionRange();

    var originalText = text;
    var constraints = <VersionConstraint>[];

    void skipWhitespace() {
      text = text.trim();
    }

    // Try to parse and consume a version number.
    Version matchVersion() {
      var version = _START_VERSION.firstMatch(text);
      if (version == null) return null;

      text = text.substring(version.end);
      return new Version.parse(version[0]);
    }

    // Try to parse and consume a comparison operator followed by a version.
    VersionConstraint matchComparison() {
      var comparison = _START_COMPARISON.firstMatch(text);
      if (comparison == null) return null;

      var op = comparison[0];
      text = text.substring(comparison.end);
      skipWhitespace();

      var version = matchVersion();
      if (version == null) {
        throw new FormatException('Expected version number after "$op" in '
            '"$originalText", got "$text".');
      }

      switch (op) {
        case '<=':
          return new VersionRange(max: version, includeMax: true);
        case '<':
          return new VersionRange(max: version, includeMax: false);
        case '>=':
          return new VersionRange(min: version, includeMin: true);
        case '>':
          return new VersionRange(min: version, includeMin: false);
      }
    }

    while (true) {
      skipWhitespace();
      if (text.isEmpty) break;

      var version = matchVersion();
      if (version != null) {
        constraints.add(version);
        continue;
      }

      var comparison = matchComparison();
      if (comparison != null) {
        constraints.add(comparison);
        continue;
      }

      // If we got here, we couldn't parse the remaining string.
      throw new FormatException('Could not parse version "$originalText". '
          'Unknown text at "$text".');
    }

    if (constraints.isEmpty) {
      throw new FormatException('Cannot parse an empty string.');
    }

    return new VersionConstraint.intersection(constraints);
  }

  /// Creates a new version constraint that is the intersection of
  /// [constraints]. It will only allow versions that all of those constraints
  /// allow. If constraints is empty, then it returns a VersionConstraint that
  /// allows all versions.
  factory VersionConstraint.intersection(
      Iterable<VersionConstraint> constraints) {
    var constraint = new VersionRange();
    for (var other in constraints) {
      constraint = constraint.intersect(other);
    }
    return constraint;
  }

  /// Returns `true` if this constraint allows no versions.
  bool get isEmpty;

  /// Returns `true` if this constraint allows all versions.
  bool get isAny;

  /// Returns `true` if this constraint allows [version].
  bool allows(Version version);

  /// Creates a new [VersionConstraint] that only allows [Version]s allowed by
  /// both this and [other].
  VersionConstraint intersect(VersionConstraint other);
}

/// Constrains versions to a fall within a given range. If there is a minimum,
/// then this only allows versions that are at that minimum or greater. If there
/// is a maximum, then only versions less than that are allowed. In other words,
/// this allows `>= min, < max`.
class VersionRange implements VersionConstraint {
  final Version min;
  final Version max;
  final bool includeMin;
  final bool includeMax;

  VersionRange({this.min, this.max,
      this.includeMin: false, this.includeMax: false}) {
    if (min != null && max != null && min > max) {
      throw new ArgumentError(
          'Minimum version ("$min") must be less than maximum ("$max").');
    }
  }

  bool operator ==(other) {
    if (other is! VersionRange) return false;

    return min == other.min &&
           max == other.max &&
           includeMin == other.includeMin &&
           includeMax == other.includeMax;
  }

  bool get isEmpty => false;

  bool get isAny => !includeMin && !includeMax;

  /// Tests if [other] matches falls within this version range.
  bool allows(Version other) {
    if (min != null && other < min) return false;
    if (min != null && !includeMin && other == min) return false;
    if (max != null && other > max) return false;
    if (max != null && !includeMax && other == max) return false;
    return true;
  }

  VersionConstraint intersect(VersionConstraint other) {
    if (other.isEmpty) return other;

    // A range and a Version just yields the version if it's in the range.
    if (other is Version) {
      return allows(other) ? other : VersionConstraint.empty;
    }

    if (other is VersionRange) {
      // Intersect the two ranges.
      var intersectMin = min;
      var intersectIncludeMin = includeMin;
      var intersectMax = max;
      var intersectIncludeMax = includeMax;

      if (other.min == null) {
        // Do nothing.
      } else if (intersectMin == null || intersectMin < other.min) {
        intersectMin = other.min;
        intersectIncludeMin = other.includeMin;
      } else if (intersectMin == other.min && !other.includeMin) {
        // The edges are the same, but one is exclusive, make it exclusive.
        intersectIncludeMin = false;
      }

      if (other.max == null) {
        // Do nothing.
      } else if (intersectMax == null || intersectMax > other.max) {
        intersectMax = other.max;
        intersectIncludeMax = other.includeMax;
      } else if (intersectMax == other.max && !other.includeMax) {
        // The edges are the same, but one is exclusive, make it exclusive.
        intersectIncludeMax = false;
      }

      if (intersectMin == null && intersectMax == null) {
        // Open range.
        return new VersionRange();
      }

      // If the range is just a single version.
      if (intersectMin == intersectMax) {
        // If both ends are inclusive, allow that version.
        if (intersectIncludeMin && intersectIncludeMax) return intersectMin;

        // Otherwise, no versions.
        return VersionConstraint.empty;
      }

      if (intersectMin != null && intersectMax != null &&
          intersectMin > intersectMax) {
        // Non-overlapping ranges, so empty.
        return VersionConstraint.empty;
      }

      // If we got here, there is an actual range.
      return new VersionRange(min: intersectMin, max: intersectMax,
          includeMin: intersectIncludeMin, includeMax: intersectIncludeMax);
    }

    throw new ArgumentError(
        'Unknown VersionConstraint type $other.');
  }

  String toString() {
    var buffer = new StringBuffer();

    if (min != null) {
      buffer.write(includeMin ? '>=' : '>');
      buffer.write(min);
    }

    if (max != null) {
      if (min != null) buffer.write(' ');
      buffer.write(includeMax ? '<=' : '<');
      buffer.write(max);
    }

    if (min == null && max == null) buffer.write('any');
    return buffer.toString();
  }
}

class _EmptyVersion implements VersionConstraint {
  const _EmptyVersion();

  bool get isEmpty => true;
  bool get isAny => false;
  bool allows(Version other) => false;
  VersionConstraint intersect(VersionConstraint other) => this;
  String toString() => '<empty>';
}
