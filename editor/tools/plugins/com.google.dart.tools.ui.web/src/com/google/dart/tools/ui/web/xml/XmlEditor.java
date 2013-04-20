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

import com.google.dart.tools.core.html.XmlDocument;
import com.google.dart.tools.core.html.XmlNode;
import com.google.dart.tools.core.html.XmlParser;
import com.google.dart.tools.ui.web.utils.WebEditor;

import org.eclipse.jface.text.IRegion;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;

/**
 * An editor for xml files.
 */
public class XmlEditor extends WebEditor {
  private XmlContentOutlinePage outlinePage;
  private XmlDocument model;

  public XmlEditor() {
    setRulerContextMenuId("#DartXmlEditorRulerContext");
    setSourceViewerConfiguration(new XmlSourceViewerConfiguration(this));
    setDocumentProvider(new XmlDocumentProvider());
  }

  @SuppressWarnings("rawtypes")
  @Override
  public Object getAdapter(Class required) {
    if (IContentOutlinePage.class.equals(required)) {
      if (outlinePage == null) {
        outlinePage = new XmlContentOutlinePage(this);
      }

      return outlinePage;
    }

    return super.getAdapter(required);
  }

  public void selectAndReveal(XmlNode node) {
    if (node.getEndToken() != null) {
      int length = node.getEndToken().getLocation() - node.getStartToken().getLocation();

      length += node.getEndToken().getValue().length();

      selectAndReveal(node.getStartToken().getLocation(), length);
    } else {
      selectAndReveal(node.getStartToken().getLocation(), 0);
    }
  }

  protected XmlDocument getModel() {
    if (model == null) {
      model = new XmlParser(getDocument().get()).parse();
    }

    return model;
  }

  @Override
  protected void handleDocumentModified() {
    model = null;
  }

  @Override
  protected void handleReconcilation(IRegion partition) {
    if (outlinePage != null) {
      outlinePage.handleEditorReconcilation();
    }
  }

}
