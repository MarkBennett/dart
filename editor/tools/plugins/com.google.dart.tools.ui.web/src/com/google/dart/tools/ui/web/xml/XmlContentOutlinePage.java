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
package com.google.dart.tools.ui.web.xml;

import com.google.dart.tools.core.html.XmlNode;
import com.google.dart.tools.ui.web.DartWebPlugin;

import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.views.contentoutline.ContentOutlinePage;

/**
 * An outline page for the xml editor.
 */
public class XmlContentOutlinePage extends ContentOutlinePage {
  private XmlEditor editor;

  public XmlContentOutlinePage(XmlEditor editor) {
    this.editor = editor;
  }

  @Override
  public void createControl(Composite parent) {
    super.createControl(parent);

    getTreeViewer().setLabelProvider(new XmlLabelProvider());
    getTreeViewer().setContentProvider(new XmlNodeContentProvider());
    getTreeViewer().setInput(editor.getModel());

    getTreeViewer().expandToLevel(3);

    getTreeViewer().addSelectionChangedListener(new ISelectionChangedListener() {
      @Override
      public void selectionChanged(SelectionChangedEvent event) {
        handleTreeViewerSelectionChanged(event.getSelection());
      }
    });
  }

  protected void handleEditorReconcilation() {
    if (!getControl().isDisposed()) {
      refreshAsync();
    }
  }

  protected void handleTreeViewerSelectionChanged(ISelection selection) {
    if (selection instanceof IStructuredSelection) {
      Object sel = ((IStructuredSelection) selection).getFirstElement();

      if (sel instanceof XmlNode) {
        XmlNode node = (XmlNode) sel;

        editor.selectAndReveal(node);
      }
    }
  }

  private void refresh() {
    try {
      if (!getTreeViewer().getControl().isDisposed()) {
        getTreeViewer().refresh(editor.getModel());
      }
    } catch (Throwable exception) {
      DartWebPlugin.logError(exception);

      getTreeViewer().setInput(null);
    }
  }

  private void refreshAsync() {
    Display.getDefault().asyncExec(new Runnable() {
      @Override
      public void run() {
        refresh();
      }
    });
  }

}
