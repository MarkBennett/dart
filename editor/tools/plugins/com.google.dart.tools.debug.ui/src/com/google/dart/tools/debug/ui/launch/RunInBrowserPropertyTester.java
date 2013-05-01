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
package com.google.dart.tools.debug.ui.launch;

import com.google.dart.engine.source.SourceKind;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.analysis.model.ProjectManager;

import org.eclipse.core.expressions.PropertyTester;
import org.eclipse.core.resources.IFile;
import org.eclipse.jface.viewers.IStructuredSelection;

/**
 * A {@link PropertyTester} for checking whether the resource can be launched in the browser. It is
 * used to contribute the Run in Dartium and Run as JavaScript context menus in the Files view.
 * Defines the property "canLaunchBrowser"
 */
public class RunInBrowserPropertyTester extends PropertyTester {

  public RunInBrowserPropertyTester() {

  }

  @Override
  public boolean test(Object receiver, String property, Object[] args, Object expectedValue) {

    if ("canLaunchBrowser".equalsIgnoreCase(property)) {
      if (receiver instanceof IStructuredSelection) {
        Object o = ((IStructuredSelection) receiver).getFirstElement();
        if (o instanceof IFile) {
          IFile file = (IFile) o;
          if (DartCore.isHTMLLikeFileName(((IFile) o).getName())) {
            return true;
          }

          ProjectManager manager = DartCore.getProjectManager();
          if (manager.getSourceKind(file) == SourceKind.LIBRARY
              && manager.isClientLibrary(manager.getSource(file))) {
            return true;
          }
        }
      }
    }

    return false;
  }

}
