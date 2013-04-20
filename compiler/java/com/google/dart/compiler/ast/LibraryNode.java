// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

package com.google.dart.compiler.ast;

import com.google.common.collect.ImmutableList;
import com.google.dart.compiler.common.AbstractNode;
import com.google.dart.compiler.util.apache.StringUtils;

import java.util.List;

/**
 * An element in a library.
 */
public class LibraryNode extends AbstractNode {

  private final String text;
  private final String prefix;
  private final List<ImportCombinator> combinators;
  private final boolean exported;

  /**
   * Construct a new library node instance
   *
   * @param manifest the library manifest declaration (not <code>null</code>)
   * @param text the text comprising the node (not <code>null</code>)
   */
  public LibraryNode(String text) {
    this.text = StringUtils.trim(text);
    this.prefix = null;
    this.combinators = ImmutableList.<ImportCombinator>of();
    this.exported = false;
  }

  public LibraryNode(DartImportDirective importDirective) {
    setSourceInfo(importDirective.getSourceInfo());
    this.text = StringUtils.trim(importDirective.getLibraryUri().getValue());
    this.prefix = importDirective.getPrefixValue();
    this.combinators = importDirective.getCombinators();
    this.exported = importDirective.isExported();
  }

  public LibraryNode(DartExportDirective exportDirective) {
    setSourceInfo(exportDirective.getSourceInfo());
    this.text = StringUtils.trim(exportDirective.getLibraryUri().getValue());
    this.prefix = null;
    this.combinators = exportDirective.getCombinators();
    this.exported = false;
  }
  
  public String getText() {
    return text;
  }

  public String getPrefix() {
    return prefix;
  }
  
  public List<ImportCombinator> getCombinators() {
    return combinators;
  }
  
  public boolean isExported() {
    return exported;
  }
}
