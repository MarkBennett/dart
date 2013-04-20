/*
 * Copyright (c) 2011, the Dart project authors.
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
package com.google.dart.tools.ui.internal.dialogs.fields;

import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;

public class LayoutUtil {

  /**
   * Creates a composite and fills in the given editors.
   * 
   * @param labelOnTop Defines if the label of all fields should be on top of the fields
   */
  public static void doDefaultLayout(Composite parent, DialogField[] editors, boolean labelOnTop) {
    doDefaultLayout(parent, editors, labelOnTop, 0, 0);
  }

  /**
   * Creates a composite and fills in the given editors.
   * 
   * @param labelOnTop Defines if the label of all fields should be on top of the fields
   * @param marginWidth The margin width to be used by the composite
   * @param marginHeight The margin height to be used by the composite
   */
  public static void doDefaultLayout(Composite parent, DialogField[] editors, boolean labelOnTop,
      int marginWidth, int marginHeight) {
    int nCulumns = getNumberOfColumns(editors);
    Control[][] controls = new Control[editors.length][];
    for (int i = 0; i < editors.length; i++) {
      controls[i] = editors[i].doFillIntoGrid(parent, nCulumns);
    }
    if (labelOnTop) {
      nCulumns--;
      modifyLabelSpans(controls, nCulumns);
    }
    GridLayout layout = null;
    if (parent.getLayout() instanceof GridLayout) {
      layout = (GridLayout) parent.getLayout();
    } else {
      layout = new GridLayout();
    }
    if (marginWidth != SWT.DEFAULT) {
      layout.marginWidth = marginWidth;
    }
    if (marginHeight != SWT.DEFAULT) {
      layout.marginHeight = marginHeight;
    }
    layout.numColumns = nCulumns;
    parent.setLayout(layout);
  }

  /**
   * Calculates the number of columns needed by field editors
   */
  public static int getNumberOfColumns(DialogField[] editors) {
    int nCulumns = 0;
    for (int i = 0; i < editors.length; i++) {
      nCulumns = Math.max(editors[i].getNumberOfControls(), nCulumns);
    }
    return nCulumns;
  }

  /**
   * Sets the heightHint hint of a control. Assumes that GridData is used.
   */
  public static void setHeightHint(Control control, int heightHint) {
    Object ld = control.getLayoutData();
    if (ld instanceof GridData) {
      ((GridData) ld).heightHint = heightHint;
    }
  }

  /**
   * Sets the horizontal grabbing of a control to true. Assumes that GridData is used.
   */
  public static void setHorizontalGrabbing(Control control) {
    Object ld = control.getLayoutData();
    if (ld instanceof GridData) {
      ((GridData) ld).grabExcessHorizontalSpace = true;
    }
  }

  /**
   * Sets the horizontal indent of a control. Assumes that GridData is used.
   */
  public static void setHorizontalIndent(Control control, int horizontalIndent) {
    Object ld = control.getLayoutData();
    if (ld instanceof GridData) {
      ((GridData) ld).horizontalIndent = horizontalIndent;
    }
  }

  /**
   * Sets the span of a control. Assumes that GridData is used.
   */
  public static void setHorizontalSpan(Control control, int span) {
    Object ld = control.getLayoutData();
    if (ld instanceof GridData) {
      ((GridData) ld).horizontalSpan = span;
    } else if (span != 1) {
      GridData gd = new GridData();
      gd.horizontalSpan = span;
      control.setLayoutData(gd);
    }
  }

  /**
   * Sets the width hint of a control. Assumes that GridData is used.
   */
  public static void setWidthHint(Control control, int widthHint) {
    Object ld = control.getLayoutData();
    if (ld instanceof GridData) {
      ((GridData) ld).widthHint = widthHint;
    }
  }

  private static void modifyLabelSpans(Control[][] controls, int nCulumns) {
    for (int i = 0; i < controls.length; i++) {
      setHorizontalSpan(controls[i][0], nCulumns);
    }
  }

}
