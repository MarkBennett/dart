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

package com.google.dart.eclipse.preferences;

import com.google.dart.eclipse.core.jobs.DartSdkUpgradeJob;
import com.google.dart.tools.core.model.DartSdk;
import com.google.dart.tools.core.model.DartSdkListener;
import com.google.dart.tools.core.model.DartSdkManager;
import com.google.dart.tools.ui.internal.util.ExternalBrowserUtil;

import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.jface.preference.PreferencePage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import java.io.File;

/**
 * A preference page to view the status of the Dart SDK and upgrade it.
 */
public class SdkPreferencePage extends PreferencePage implements IWorkbenchPreferencePage,
    DartSdkListener {

  private Label sdkVersionlabel;
  private Button upgradeSdkButton;
  private Label sdkInstallLocationLabel;

  private Label dartiumStatuslabel;
  private Label dartiumInstallLocationLabel;

  public SdkPreferencePage() {
    noDefaultAndApplyButton();
  }

  @Override
  public void dispose() {
    DartSdkManager.getManager().removeSdkListener(this);

    super.dispose();
  }

  @Override
  public void init(IWorkbench workbench) {

  }

  @Override
  public void sdkUpdated(DartSdk sdk) {
    Display.getDefault().asyncExec(new Runnable() {
      @Override
      public void run() {
        updateSDKInfo();
        updateDartiumInfo();
      }
    });
  }

  @Override
  public void setVisible(boolean visible) {
    super.setVisible(visible);

    if (visible) {
      updateDartiumInfo();
    }
  }

  @Override
  protected Control createContents(Composite parent) {
    Composite composite = new Composite(parent, SWT.NONE);
    GridDataFactory.fillDefaults().grab(true, false).applyTo(composite);
    GridLayoutFactory.fillDefaults().spacing(0, 10).applyTo(composite);

    // sdk group
    Group sdkGroup = new Group(composite, SWT.NONE);
    sdkGroup.setText("Dart SDK");
    GridDataFactory.swtDefaults().grab(true, false).align(SWT.FILL, SWT.TOP).applyTo(sdkGroup);
    GridLayoutFactory.fillDefaults().numColumns(2).margins(10, 4).applyTo(sdkGroup);

    sdkVersionlabel = new Label(sdkGroup, SWT.NONE);
    GridDataFactory.fillDefaults().align(SWT.LEFT, SWT.CENTER).grab(true, false).applyTo(
        sdkVersionlabel);

    upgradeSdkButton = new Button(sdkGroup, SWT.PUSH);
    upgradeSdkButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        DartSdkUpgradeJob job = new DartSdkUpgradeJob();

        job.schedule();
      }
    });

    sdkInstallLocationLabel = new Label(sdkGroup, SWT.NONE);
    GridDataFactory.fillDefaults().grab(true, false).span(2, 1).applyTo(sdkInstallLocationLabel);

    // dartium group
    Group dartiumGroup = new Group(composite, SWT.NONE);
    dartiumGroup.setText("Dartium");
    GridDataFactory.swtDefaults().grab(true, false).align(SWT.FILL, SWT.TOP).applyTo(dartiumGroup);
    GridLayoutFactory.fillDefaults().numColumns(2).margins(10, 4).applyTo(dartiumGroup);

    dartiumStatuslabel = new Label(dartiumGroup, SWT.NONE);
    GridDataFactory.fillDefaults().align(SWT.LEFT, SWT.CENTER).grab(true, false).applyTo(
        dartiumStatuslabel);

    Button dartiumDownloadButton = new Button(dartiumGroup, SWT.PUSH);
    dartiumDownloadButton.setText("Visit Website");
    dartiumDownloadButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        ExternalBrowserUtil.openInExternalBrowser("http://www.dartlang.org/dartium/");
      }
    });

    dartiumInstallLocationLabel = new Label(dartiumGroup, SWT.NONE);
    GridDataFactory.fillDefaults().grab(true, false).span(2, 1).applyTo(dartiumInstallLocationLabel);

    // update info
    updateSDKInfo();
    updateDartiumInfo();

    DartSdkManager.getManager().addSdkListener(this);

    return composite;
  }

  protected void updateSDKInfo() {
    DartSdk sdk = DartSdkManager.getManager().getSdk();

    if (sdk == null) {
      sdkInstallLocationLabel.setText("");
      sdkVersionlabel.setText("No SDK installed");
      upgradeSdkButton.setText("Download SDK");
    } else {
      sdkInstallLocationLabel.setText("Installed at " + sdk.getDirectory().getPath());
      sdkVersionlabel.setText("Dart SDK version " + sdk.getSdkVersion());
      upgradeSdkButton.setText("Upgrade SDK");
    }

    sdkVersionlabel.getParent().layout();
  }

  private void updateDartiumInfo() {
    File dartiumDir = null;
    File dartiumFile = null;

    DartSdk sdk = DartSdkManager.getManager().getSdk();

    if (sdk != null) {
      dartiumDir = sdk.getDartiumWorkingDirectory();
      dartiumFile = sdk.getDartiumExecutable();
    }

    if (dartiumDir == null) {
      dartiumStatuslabel.setText("Dartium is not installed");
      dartiumInstallLocationLabel.setText("");
    } else if (dartiumFile == null) {
      dartiumStatuslabel.setText("Dartium is not installed");
      dartiumInstallLocationLabel.setText("Dartium should be placed in " + dartiumDir);
    } else {
      dartiumStatuslabel.setText("Dartium is installed.");
      dartiumInstallLocationLabel.setText("Installed at " + dartiumDir);
    }
  }

}
