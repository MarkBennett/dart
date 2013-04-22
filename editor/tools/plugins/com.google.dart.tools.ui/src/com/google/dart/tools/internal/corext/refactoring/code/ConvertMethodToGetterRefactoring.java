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
package com.google.dart.tools.internal.corext.refactoring.code;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.dart.compiler.ast.ASTNodes;
import com.google.dart.compiler.ast.DartInvocation;
import com.google.dart.compiler.ast.DartNode;
import com.google.dart.compiler.util.apache.StringUtils;
import com.google.dart.engine.utilities.source.SourceRange;
import com.google.dart.tools.core.dom.NodeFinder;
import com.google.dart.tools.core.internal.util.SourceRangeUtils;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartFunction;
import com.google.dart.tools.core.model.Method;
import com.google.dart.tools.core.model.TypeMember;
import com.google.dart.tools.core.search.SearchMatch;
import com.google.dart.tools.core.utilities.general.SourceRangeFactory;
import com.google.dart.tools.internal.corext.refactoring.RefactoringCoreMessages;
import com.google.dart.tools.internal.corext.refactoring.changes.TextChangeCompatibility;
import com.google.dart.tools.internal.corext.refactoring.rename.MemberDeclarationsReferences;
import com.google.dart.tools.internal.corext.refactoring.rename.RenameAnalyzeUtil;
import com.google.dart.tools.internal.corext.refactoring.util.TextChangeManager_OLD;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.SubProgressMonitor;
import org.eclipse.ltk.core.refactoring.Change;
import org.eclipse.ltk.core.refactoring.CompositeChange;
import org.eclipse.ltk.core.refactoring.Refactoring;
import org.eclipse.ltk.core.refactoring.RefactoringStatus;
import org.eclipse.ltk.core.refactoring.TextChange;
import org.eclipse.text.edits.ReplaceEdit;
import org.eclipse.text.edits.TextEdit;

import java.util.List;

/**
 * Converts {@link DartFunction} without arguments into getter.
 * 
 * @coverage dart.editor.ui.refactoring.core
 */
public class ConvertMethodToGetterRefactoring extends Refactoring {

  private static void addReplaceEdit(TextChange change, String name, SourceRange range, String text) {
    TextEdit edit = new ReplaceEdit(range.getOffset(), range.getLength(), text);
    TextChangeCompatibility.addTextEdit(change, name, edit);
  }

  private final DartFunction function;
  private final TextChangeManager_OLD changeManager = new TextChangeManager_OLD(true);

  public ConvertMethodToGetterRefactoring(DartFunction function) {
    this.function = function;
  }

  @Override
  public RefactoringStatus checkFinalConditions(IProgressMonitor pm) throws CoreException {
    pm.done();
    return new RefactoringStatus();
  }

  @Override
  public RefactoringStatus checkInitialConditions(IProgressMonitor pm) throws CoreException {
    pm.done();
    return new RefactoringStatus();
  }

  @Override
  public Change createChange(IProgressMonitor pm) throws CoreException {
    pm.beginTask(RefactoringCoreMessages.ConvertMethodToGetterRefactoring_processing, 3);
    pm.subTask(StringUtils.EMPTY);
    try {
      List<DartFunction> declarations;
      List<SearchMatch> references;
      // find references
      SubProgressMonitor pm2 = new SubProgressMonitor(pm, 1);
      if (function instanceof Method) {
        MemberDeclarationsReferences memberInfo = RenameAnalyzeUtil.findDeclarationsReferences(
            (Method) function,
            pm2);
        declarations = Lists.newArrayList();
        for (TypeMember member : memberInfo.declarations) {
          if (member instanceof DartFunction) {
            declarations.add((DartFunction) member);
          }
        }
        references = memberInfo.references;
      } else {
        declarations = ImmutableList.of(function);
        references = RenameAnalyzeUtil.getReferences(function, pm2);
      }
      // convert method declaration(s) to getter
      for (DartFunction function : declarations) {
        CompilationUnit unit = function.getCompilationUnit();
        TextChange change = changeManager.get(unit);
        String changeName = RefactoringCoreMessages.ConvertMethodToGetterRefactoring_make_getter_declaration;
        addReplaceEdit(
            change,
            changeName,
            SourceRangeFactory.forStartLength(function.getNameRange(), 0),
            "get ");
        addReplaceEdit(
            change,
            changeName,
            SourceRangeFactory.forEndEnd(
                function.getNameRange(),
                function.getParametersCloseParen()),
            "");
        pm.worked(1);
      }
      // convert all references
      for (SearchMatch reference : references) {
        CompilationUnit refUnit = reference.getElement().getAncestor(CompilationUnit.class);
        TextChange refChange = changeManager.get(refUnit);
        ExtractUtils utils = new ExtractUtils(refUnit);
        // prepare invocation
        DartNode coveringNode = NodeFinder.find(
            utils.getUnitNode(),
            reference.getSourceRange().getOffset(),
            0).getCoveringNode();
        DartInvocation invocation = ASTNodes.getAncestor(coveringNode, DartInvocation.class);
        // we need invocation
        if (invocation != null) {
          SourceRange range = SourceRangeFactory.forStartEnd(
              SourceRangeUtils.getEnd(reference.getSourceRange()),
              invocation);
          addReplaceEdit(
              refChange,
              RefactoringCoreMessages.ConvertMethodToGetterRefactoring_replace_invocation,
              range,
              "");
        }
      }
      pm.worked(1);
      // done
      return new CompositeChange(getName(), changeManager.getAllChanges());
    } finally {
      pm.done();
    }
  }

  @Override
  public String getName() {
    return RefactoringCoreMessages.ConvertMethodToGetterRefactoring_name;
  }

}
