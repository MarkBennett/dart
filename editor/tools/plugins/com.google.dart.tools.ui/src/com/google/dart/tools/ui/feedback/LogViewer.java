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
package com.google.dart.tools.ui.feedback;

import com.google.dart.tools.ui.actions.CopyDetailsToClipboardAction;
import com.google.dart.tools.ui.actions.CopyDetailsToClipboardAction.DetailsProvider;

import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.ScrolledComposite;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Shell;

/**
 * A lightweight FeedbackReport log previewer.
 */
public class LogViewer extends Shell implements DetailsProvider {

  private StyledText logText;

  public LogViewer(Shell parent, String logContents) {
    super(parent, SWT.CLOSE | SWT.RESIZE | SWT.TITLE);
    setLayout(GridLayoutFactory.fillDefaults().spacing(0, 0).margins(0, 0).create());

    ScrolledComposite scrolledComposite = new ScrolledComposite(this, SWT.BORDER | SWT.H_SCROLL
        | SWT.V_SCROLL);
    scrolledComposite.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true, 1, 1));
    scrolledComposite.setExpandHorizontal(true);
    scrolledComposite.setExpandVertical(true);

    logText = new StyledText(scrolledComposite, SWT.BORDER | SWT.READ_ONLY | SWT.WRAP);
    logText.setBottomMargin(5);
    logText.setTopMargin(5);
    logText.setRightMargin(5);
    logText.setLeftMargin(5);
    logText.setDoubleClickEnabled(false);
    logText.setEditable(false);
    logText.setText(logContents);

    scrolledComposite.setContent(logText);
    scrolledComposite.setMinSize(logText.computeSize(SWT.DEFAULT, SWT.DEFAULT));

    createContents();

    centerShell(parent);
  }

  @Override
  public String getDetails() {
    if (logText != null) {
      return logText.getText();
    }
    return "";
  }

  @Override
  protected void checkSubclass() {
    // Disable the check that prevents subclassing of SWT components
  }

  protected void createContents() {
    setText(FeedbackMessages.LogViewer_LogViewer_title);
    setSize(750, 350);
    addCopyDetailsPopup(this);
    addCopyDetailsPopup(logText);
  }

  private void addCopyDetailsPopup(Control control) {
    CopyDetailsToClipboardAction.addCopyDetailsPopup(control, this);
  }

  private void centerShell(Shell parent) {
    Point parentSize = parent.getSize();
    Point size = getSize();

    Point location = parent.getLocation();

    setLocation(location.x + (parentSize.x - size.x) / 2, location.y + 50 + (parentSize.y - size.y)
        / 2);
  }

}
