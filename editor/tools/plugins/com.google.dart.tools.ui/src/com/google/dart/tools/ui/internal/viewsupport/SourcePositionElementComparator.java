/*
 * Copyright (c) 2013, the Dart project authors.
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
package com.google.dart.tools.ui.internal.viewsupport;

import com.google.dart.engine.element.Element;

import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerComparator;

/**
 * {@link ViewerComparator} which sorts the {@link Element}s like they appear in the source.
 */
public class SourcePositionElementComparator extends ViewerComparator {
  public static final ViewerComparator INSTANCE = new SourcePositionElementComparator();

  private SourcePositionElementComparator() {
  }

  @Override
  public int compare(Viewer viewer, Object e1, Object e2) {
    if (!(e1 instanceof Element)) {
      return 0;
    }
    if (!(e2 instanceof Element)) {
      return 0;
    }
    return ((Element) e1).getNameOffset() - ((Element) e2).getNameOffset();
  }
}
