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
package com.google.dart.tools.ui.internal.text.correction;

import com.google.dart.compiler.ast.DartNode;
import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.tools.core.dom.NodeFinder;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.ui.internal.text.editor.ASTProvider;
import com.google.dart.tools.ui.text.dart.IInvocationContext;

import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.TextInvocationContext;
import org.eclipse.ui.IEditorPart;

/**
 * @coverage dart.editor.ui.correction
 */
public class AssistContext extends TextInvocationContext implements IInvocationContext {

  private final CompilationUnit fCompilationUnit;
  private final IEditorPart fEditor;
  private final ASTProvider.WAIT_FLAG fWaitFlag;

  private DartUnit fASTRoot;
  /**
   * The cached node finder, can be null.
   */
  private NodeFinder fNodeFinder;
  private final com.google.dart.engine.services.assist.AssistContext context;

  /*
   * Constructor for CorrectionContext.
   */
  public AssistContext(CompilationUnit cu, int offset, int length) {
    this(cu, null, offset, length);
  }

  public AssistContext(CompilationUnit cu, ISourceViewer sourceViewer, IEditorPart editor,
      int offset, int length) {
    this(cu, sourceViewer, editor, offset, length, ASTProvider.WAIT_YES);
  }

  public AssistContext(CompilationUnit cu, ISourceViewer sourceViewer, int offset, int length) {
    this(cu, sourceViewer, null, offset, length);
  }

  public AssistContext(CompilationUnit cu, ISourceViewer sourceViewer, int offset, int length,
      ASTProvider.WAIT_FLAG waitFlag) {
    this(cu, sourceViewer, null, offset, length, waitFlag);
  }

  public AssistContext(IEditorPart editor, ISourceViewer sourceViewer,
      com.google.dart.engine.services.assist.AssistContext context) {
    super(sourceViewer, context.getSelectionOffset(), context.getSelectionLength());
    this.fEditor = editor;
    this.context = context;
    this.fCompilationUnit = null;
    this.fWaitFlag = ASTProvider.WAIT_YES;
  }

  private AssistContext(CompilationUnit cu, ISourceViewer sourceViewer, IEditorPart editor,
      int offset, int length, ASTProvider.WAIT_FLAG waitFlag) {
    super(sourceViewer, offset, length);
    Assert.isLegal(cu != null);
    Assert.isLegal(waitFlag != null);
    this.context = null;
    fCompilationUnit = cu;
    fEditor = editor;
    fWaitFlag = waitFlag;
  }

  @Override
  public com.google.dart.engine.services.assist.AssistContext getContext() {
    return context;
  }

  /**
   * Returns the editor or <code>null</code> if none.
   * 
   * @return an <code>IEditorPart</code> or <code>null</code> if none
   * @since 3.5
   */
  public IEditorPart getEditor() {
    return fEditor;
  }

  @Override
  public DartUnit getOldASTRoot() {
    if (fASTRoot == null) {
      fASTRoot = ASTProvider.getASTProvider().getAST(fCompilationUnit, fWaitFlag, null);
    }
    return fASTRoot;
  }

  /**
   * Returns the compilation unit.
   * 
   * @return an <code>CompilationUnit</code>
   */
  @Override
  public CompilationUnit getOldCompilationUnit() {
    return fCompilationUnit;
  }

  @Override
  public DartNode getOldCoveredNode() {
    if (fNodeFinder == null) {
      fNodeFinder = NodeFinder.find(getOldASTRoot(), getOffset(), getLength());
    }
    return fNodeFinder.getCoveredNode();
  }

  @Override
  public DartNode getOldCoveringNode() {
    if (fNodeFinder == null) {
      fNodeFinder = NodeFinder.find(getOldASTRoot(), getOffset(), getLength());
    }
    return fNodeFinder.getCoveringNode();
  }

  /**
   * Returns the length.
   */
  @Override
  public int getSelectionLength() {
    return Math.max(getLength(), 0);
  }

  /**
   * Returns the offset.
   */
  @Override
  public int getSelectionOffset() {
    return getOffset();
  }

  public void setASTRoot(DartUnit root) {
    fASTRoot = root;
  }

}
