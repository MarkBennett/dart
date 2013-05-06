// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of html;

/** A Set that stores the CSS class names for an element. */
abstract class CssClassSet implements Set<String> {

  /**
   * Adds the class [value] to the element if it is not on it, removes it if it
   * is.
   */
  bool toggle(String value);

  /**
   * Returns [:true:] if classes cannot be added or removed from this
   * [:CssClassSet:].
   */
  bool get frozen;

  /**
   * Determine if this element contains the class [value].
   *
   * This is the Dart equivalent of jQuery's
   * [hasClass](http://api.jquery.com/hasClass/).
   */
  bool contains(String value);

  /**
   * Add the class [value] to element.
   *
   * This is the Dart equivalent of jQuery's
   * [addClass](http://api.jquery.com/addClass/).
   */
  void add(String value);

  /**
   * Remove the class [value] from element, and return true on successful
   * removal.
   *
   * This is the Dart equivalent of jQuery's
   * [removeClass](http://api.jquery.com/removeClass/).
   */
  bool remove(Object value);

  /**
   * Add all classes specified in [iterable] to element.
   *
   * This is the Dart equivalent of jQuery's
   * [addClass](http://api.jquery.com/addClass/).
   */
  void addAll(Iterable<String> iterable);

  /**
   * Remove all classes specified in [iterable] from element.
   *
   * This is the Dart equivalent of jQuery's
   * [removeClass](http://api.jquery.com/removeClass/).
   */
  void removeAll(Iterable<String> iterable);

  /**
   * Toggles all classes specified in [iterable] on element.
   *
   * Iterate through [iterable]'s items, and add it if it is not on it, or
   * remove it if it is. This is the Dart equivalent of jQuery's
   * [toggleClass](http://api.jquery.com/toggleClass/).
   */
  void toggleAll(Iterable<String> iterable);
}

/**
 * A set (union) of the CSS classes that are present in a set of elements.
 * Implemented separately from _ElementCssClassSet for performance.
 */
class _MultiElementCssClassSet extends CssClassSetImpl {
  final Iterable<Element> _elementIterable;
  Iterable<_ElementCssClassSet> _elementCssClassSetIterable;

  _MultiElementCssClassSet(this._elementIterable) {
    _elementCssClassSetIterable = new List.from(_elementIterable).map(
        (e) => new _ElementCssClassSet(e));
  }

  Set<String> readClasses() {
    var s = new LinkedHashSet<String>();
    _elementCssClassSetIterable.forEach((e) => s.addAll(e.readClasses()));
    return s;
  }

  void writeClasses(Set<String> s) {
    var classes = new List.from(s).join(' ');
    for (Element e in _elementIterable) {
      e.$dom_className = classes;
    }
  }

  /**
   * Helper method used to modify the set of css classes on this element.
   *
   *   f - callback with:
   *   s - a Set of all the css class name currently on this element.
   *
   *   After f returns, the modified set is written to the
   *       className property of this element.
   */
  void modify( f(Set<String> s)) {
    _elementCssClassSetIterable.forEach((e) => e.modify(f));
  }

  /**
   * Adds the class [value] to the element if it is not on it, removes it if it
   * is.
   */
  bool toggle(String value) =>
      _modifyWithReturnValue((e) => e.toggle(value));

  /**
   * Remove the class [value] from element, and return true on successful
   * removal.
   *
   * This is the Dart equivalent of jQuery's
   * [removeClass](http://api.jquery.com/removeClass/).
   */
  bool remove(Object value) => _modifyWithReturnValue((e) => e.remove(value));

  bool _modifyWithReturnValue(f) => _elementCssClassSetIterable.fold(
      false, (prevValue, element) => f(element) || prevValue);
}

class _ElementCssClassSet extends CssClassSetImpl {

  final Element _element;

  _ElementCssClassSet(this._element);

  Set<String> readClasses() {
    var s = new LinkedHashSet<String>();
    var classname = _element.$dom_className;

    for (String name in classname.split(' ')) {
      String trimmed = name.trim();
      if (!trimmed.isEmpty) {
        s.add(trimmed);
      }
    }
    return s;
  }

  void writeClasses(Set<String> s) {
    List list = new List.from(s);
    _element.$dom_className = s.join(' ');
  }
}
