/*
 * Copyright (c) 2012, the Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.dart.tools.core.internal.model;

import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.internal.model.info.DartFunctionInfo;
import com.google.dart.tools.core.internal.util.MementoTokenizer;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartFunction;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.core.model.DartModifiers;
import com.google.dart.tools.core.model.DartVariableDeclaration;
import com.google.dart.tools.core.model.SourceRange;
import com.google.dart.tools.core.workingcopy.WorkingCopyOwner;

import java.util.ArrayList;
import java.util.List;

/**
 * Instances of the class <code>DartFunctionImpl</code> represent a Dart function definition.
 */
public class DartFunctionImpl extends SourceReferenceImpl implements DartFunction {

  private String name;

  protected DartFunctionImpl(DartElementImpl parent, String name) {
    super(parent);
    this.name = name;
  }

  @Override
  public boolean equals(Object o) {
    if (!(o instanceof DartFunctionImpl)) {
      return false;
    }
    return super.equals(o);
  }

  @Override
  public String getElementName() {
    return name == null ? "" : name;
  }

  @Override
  public int getElementType() {
    return FUNCTION;
  }

  @Override
  public String[] getFullParameterTypeNames() throws DartModelException {
    ArrayList<String> typeNames = new ArrayList<String>();
    for (DartVariableDeclaration variable : getChildrenOfType(DartVariableDeclaration.class)) {
      if (variable.isParameter()) {
        typeNames.add(variable.getFullTypeName());
      }
    }
    return typeNames.toArray(new String[typeNames.size()]);
  }

  @Override
  public DartVariableDeclaration[] getLocalVariables() throws DartModelException {
    List<DartVariableDeclaration> variables = getChildrenOfType(DartVariableDeclaration.class);
    return variables.toArray(new DartVariableDeclaration[variables.size()]);
  }

  public DartModifiers getModifiers() {
    try {
      DartFunctionInfo info = (DartFunctionInfo) getElementInfo();
      return new DartModifiers(info.getModifiers());
    } catch (DartModelException exception) {
      throw new IllegalStateException(exception);
    }
  }

  @Override
  public SourceRange getNameRange() throws DartModelException {
    return ((DartFunctionInfo) getElementInfo()).getNameRange();
  }

  @Override
  public SourceRange getOptionalParametersClosingGroupChar() throws DartModelException {
    DartFunctionInfo info = (DartFunctionInfo) getElementInfo();
    int offset = info.getOptionalParametersClosingGroupChar();
    return offset == -1 ? null : new SourceRangeImpl(offset, 1);
  }

  @Override
  public SourceRange getOptionalParametersOpeningGroupChar() throws DartModelException {
    DartFunctionInfo info = (DartFunctionInfo) getElementInfo();
    int offset = info.getOptionalParametersOpeningGroupChar();
    return offset == -1 ? null : new SourceRangeImpl(offset, 1);
  }

  @Override
  public String[] getParameterNames() throws DartModelException {
    ArrayList<String> names = new ArrayList<String>();
    for (DartVariableDeclaration variable : getChildrenOfType(DartVariableDeclaration.class)) {
      if (variable.isParameter()) {
        names.add(variable.getElementName());
      }
    }
    return names.toArray(new String[names.size()]);
  }

  @Override
  public SourceRange getParametersCloseParen() throws DartModelException {
    DartFunctionInfo info = (DartFunctionInfo) getElementInfo();
    return new SourceRangeImpl(info.getParametersCloseParen(), 1);
  }

  @Override
  public SourceRange getParametersOpenParen() throws DartModelException {
    DartFunctionInfo info = (DartFunctionInfo) getElementInfo();
    return new SourceRangeImpl(info.getParametersOpenParen(), 1);
  }

  @Override
  public String[] getParameterTypeNames() throws DartModelException {
    ArrayList<String> typeNames = new ArrayList<String>();
    for (DartVariableDeclaration variable : getChildrenOfType(DartVariableDeclaration.class)) {
      if (variable.isParameter()) {
        typeNames.add(variable.getTypeName());
      }
    }
    return typeNames.toArray(new String[typeNames.size()]);
  }

  @Override
  public String getReturnTypeName() throws DartModelException {
    DartFunctionInfo info = (DartFunctionInfo) getElementInfo();
    char[] name = info.getReturnTypeName();
    if (name == null) {
      return null;
    }
    return new String(name);
  }

  @Override
  public SourceRange getVisibleRange() throws DartModelException {
    DartFunctionInfo info = (DartFunctionInfo) getElementInfo();
    return info.getVisibleRange();
  }

  @Override
  public boolean isGetter() {
    return getModifiers().isGetter();
  }

  @Override
  public boolean isGlobal() {
    return getParent() instanceof CompilationUnit;
  }

  @Override
  public boolean isLocal() {
    return !isGlobal();
  }

  @Override
  public boolean isMain() {
    return MAIN.equals(getElementName());
  }

  @Override
  public boolean isSetter() {
    return getModifiers().isSetter();
  }

  @Override
  protected DartElement getHandleFromMemento(String token, MementoTokenizer tokenizer,
      WorkingCopyOwner owner) {
    DartCore.notYetImplemented();
    // TODO(brianwilkerson) This doesn't handle unnamed functions.
    switch (token.charAt(0)) {
      case MEMENTO_DELIMITER_FUNCTION:
        if (!tokenizer.hasMoreTokens()) {
          return this;
        }
        DartFunctionImpl function = new DartFunctionImpl(this, tokenizer.nextToken());
        return function.getHandleFromMemento(tokenizer, owner);
      case MEMENTO_DELIMITER_VARIABLE:
        if (!tokenizer.hasMoreTokens()) {
          return this;
        }
        DartVariableImpl variable = new DartVariableImpl(this, tokenizer.nextToken());
        return variable.getHandleFromMemento(tokenizer, owner);
    }
    return null;
  }

  @Override
  protected char getHandleMementoDelimiter() {
    return MEMENTO_DELIMITER_FUNCTION;
  }
}
