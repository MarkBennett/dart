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
package com.google.dart.tools.internal.corext.refactoring.rename;

import com.google.common.base.Objects;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartFunctionTypeAlias;
import com.google.dart.tools.internal.corext.refactoring.Checks;
import com.google.dart.tools.internal.corext.refactoring.RefactoringAvailabilityTester;
import com.google.dart.tools.internal.corext.refactoring.RefactoringCoreMessages;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.ltk.core.refactoring.RefactoringStatus;

/**
 * {@link DartRenameProcessor} for {@link DartFunctionTypeAlias}.
 * 
 * @coverage dart.editor.ui.refactoring.core
 */
public class RenameFunctionTypeAliasProcessor extends RenameTopLevelProcessor {

  public static final String IDENTIFIER = "com.google.dart.tools.ui.renameFunctionTypeAliasProcessor"; //$NON-NLS-1$

  private final DartFunctionTypeAlias type;

  /**
   * @param type the {@link DartFunctionTypeAlias} to rename, not <code>null</code>.
   */
  public RenameFunctionTypeAliasProcessor(DartFunctionTypeAlias type) {
    super(type);
    this.type = type;
  }

  @Override
  public RefactoringStatus checkNewElementName(String newName) throws CoreException {
    RefactoringStatus result = Checks.checkFunctionTypeAliasName(newName);
    result.merge(super.checkNewElementName(newName));
    return result;
  }

  @Override
  public String getIdentifier() {
    return IDENTIFIER;
  }

  @Override
  public Object getNewElement() throws CoreException {
    DartFunctionTypeAlias result = null;
    DartElement[] topLevelElements = type.getCompilationUnit().getChildren();
    for (DartElement element : topLevelElements) {
      if (element instanceof DartFunctionTypeAlias
          && Objects.equal(element.getElementName(), getNewElementName())) {
        result = (DartFunctionTypeAlias) element;
      }
    }
    return result;
  }

  @Override
  public String getProcessorName() {
    return RefactoringCoreMessages.RenameFunctionTypeAliasProcessor_name;
  }

  @Override
  public boolean isApplicable() throws CoreException {
    return RefactoringAvailabilityTester.isRenameAvailable(type);
  }
}
