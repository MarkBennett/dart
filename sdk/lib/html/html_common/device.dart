// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of html_common;

/**
 * Utils for device detection.
 */
class Device {
  static bool _isOpera;
  static bool _isIE;
  static bool _isFirefox;
  static bool _isWebKit;
  static String _cachedCssPrefix;
  static String _cachedPropertyPrefix;

  /**
   * Gets the browser's user agent. Using this function allows tests to inject
   * the user agent.
 * Returns the user agent.
   */
  static String get userAgent => window.navigator.userAgent;

  /**
   * Determines if the current device is running Opera.
   */
  static bool get isOpera {
    if (_isOpera == null) {
      _isOpera = userAgent.contains("Opera", 0);
    }
    return _isOpera;
  }

  /**
   * Determines if the current device is running Internet Explorer.
   */
  static bool get isIE {
    if (_isIE == null) {
      _isIE = !isOpera && userAgent.contains("MSIE", 0);
    }
    return _isIE;
  }

  /**
   * Determines if the current device is running Firefox.
   */
  static bool get isFirefox {
    if (_isFirefox == null) {
      _isFirefox = userAgent.contains("Firefox", 0);
    }
    return _isFirefox;
  }

  /**
   * Determines if the current device is running WebKit.
   */
  static bool get isWebKit {
    if (_isWebKit == null) {
      _isWebKit = !isOpera && userAgent.contains("WebKit", 0);
    }
    return _isWebKit;
  }

  /**
   * Gets the CSS property prefix for the current platform.
   */
  static String get cssPrefix {
    if (_cachedCssPrefix == null) {
      if (isFirefox) {
        _cachedCssPrefix = '-moz-';
      } else if (isIE) {
        _cachedCssPrefix = '-ms-';
      } else if (isOpera) {
        _cachedCssPrefix = '-o-';
      } else {
        _cachedCssPrefix = '-webkit-';
      }
    }
    return _cachedCssPrefix;
  }

  /**
   * Prefix as used for JS property names.
   */
  static String get propertyPrefix {
    if (_cachedPropertyPrefix == null) {
      if (isFirefox) {
        _cachedPropertyPrefix = 'moz';
      } else if (isIE) {
        _cachedPropertyPrefix = 'ms';
      } else if (isOpera) {
        _cachedPropertyPrefix = 'o';
      } else {
        _cachedPropertyPrefix = 'webkit';
      }
    }
    return _cachedPropertyPrefix;
  }

  /**
   * Checks to see if the event class is supported by the current platform.
   */
  static bool isEventTypeSupported(String eventType) {
    // Browsers throw for unsupported event names.
    try {
      var e = document.$dom_createEvent(eventType);
      return e is Event;
    } catch (_) { }
    return false;
  }
}
