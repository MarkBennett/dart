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
package com.google.dart.tools.debug.ui.internal.dartium;

import com.google.dart.tools.core.model.DartSdkManager;
import com.google.dart.tools.debug.core.DartLaunchConfigWrapper;
import com.google.dart.tools.debug.ui.internal.DartDebugUIPlugin;
import com.google.dart.tools.debug.ui.internal.util.AppSelectionDialog;
import com.google.dart.tools.debug.ui.internal.util.AppSelectionDialog.HtmlResourceFilter;
import com.google.dart.tools.ui.internal.util.ExternalBrowserUtil;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy;
import org.eclipse.debug.ui.AbstractLaunchConfigurationTab;
import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.jface.layout.PixelConverter;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Link;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.dialogs.ContainerSelectionDialog;
import org.eclipse.ui.dialogs.FilteredItemsSelectionDialog;

/**
 * The main launch configuration UI for running Dart applications in Dartium.
 */
public class DartiumMainTab extends AbstractLaunchConfigurationTab {
  private Text htmlText;

  protected ModifyListener textModifyListener = new ModifyListener() {
    @Override
    public void modifyText(ModifyEvent e) {
      notifyPanelChanged();
    }
  };

  private Button htmlButton;

  private Button htmlBrowseButton;

  private Button urlButton;

  private Text urlText;

  private Text sourceDirectoryText;

  private Button projectBrowseButton;

  private Button checkedModeButton;

  private Button showOutputButton;

  private Button useWebComponentsButton;

  protected Text argumentText;

  /**
   * Create a new instance of DartServerMainTab.
   */
  public DartiumMainTab() {

  }

  @Override
  public void createControl(Composite parent) {
    Composite composite = new Composite(parent, SWT.NONE);
    GridLayoutFactory.swtDefaults().spacing(1, 3).applyTo(composite);

    // Project group
    Group group = new Group(composite, SWT.NONE);
    group.setText(DartiumLaunchMessages.DartiumMainTab_LaunchTarget);
    GridDataFactory.fillDefaults().grab(true, false).applyTo(group);
    GridLayoutFactory.swtDefaults().numColumns(3).applyTo(group);

    createHtmlField(group);

    Label filler = new Label(group, SWT.NONE);
    GridDataFactory.swtDefaults().span(3, 1).hint(-1, 4).applyTo(filler);

    createUrlField(group);

    // Dartium settings group
    group = new Group(composite, SWT.NONE);
    group.setText("Dartium settings");
    GridDataFactory.fillDefaults().grab(true, false).applyTo(group);
    GridLayoutFactory.swtDefaults().numColumns(3).applyTo(group);
    ((GridLayout) group.getLayout()).marginBottom = 5;

    checkedModeButton = new Button(group, SWT.CHECK);
    checkedModeButton.setText("Run in checked mode");
    checkedModeButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        notifyPanelChanged();
      }
    });
    GridDataFactory.swtDefaults().span(2, 1).grab(true, false).applyTo(checkedModeButton);

    Link infoLink = new Link(group, SWT.NONE);
    infoLink.setText("<a href=\"" + DartDebugUIPlugin.CHECK_MODE_DESC_URL
        + "\">what is checked mode?</a>");
    infoLink.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        ExternalBrowserUtil.openInExternalBrowser(DartDebugUIPlugin.CHECK_MODE_DESC_URL);
      }
    });

    useWebComponentsButton = new Button(group, SWT.CHECK);
    useWebComponentsButton.setText("Enable experimental browser features (Web Components)");
    useWebComponentsButton.setToolTipText("--enable-experimental-webkit-features"
        + " and --enable-devtools-experiments");
    GridDataFactory.swtDefaults().span(3, 1).applyTo(useWebComponentsButton);
    useWebComponentsButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        notifyPanelChanged();
      }
    });

    showOutputButton = new Button(group, SWT.CHECK);
    showOutputButton.setText("Show browser stdout and stderr output");
    GridDataFactory.swtDefaults().span(3, 1).applyTo(showOutputButton);
    showOutputButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        notifyPanelChanged();
      }
    });

    // additional browser arguments
    Label argsLabel = new Label(group, SWT.NONE);
    argsLabel.setText("Browser arguments:");

    argumentText = new Text(group, SWT.BORDER | SWT.SINGLE);
    GridDataFactory.swtDefaults().align(SWT.FILL, SWT.CENTER).grab(true, false).span(2, 1).applyTo(
        argumentText);

    setControl(composite);
  }

  @Override
  public String getErrorMessage() {
    if (performSdkCheck() != null) {
      return performSdkCheck();
    }

    if (htmlButton.getSelection() && htmlText.getText().length() == 0) {
      return DartiumLaunchMessages.DartiumMainTab_NoHtmlFile;
    }

    if (urlButton.getSelection()) {
      String url = urlText.getText();

      if (url.length() == 0) {
        return DartiumLaunchMessages.DartiumMainTab_NoUrl;
      }

      if (!isValidUrl(url)) {
        return DartiumLaunchMessages.DartiumMainTab_InvalidURL;
      }

      if (sourceDirectoryText.getText().length() == 0) {
        return DartiumLaunchMessages.DartiumMainTab_NoProject;
      }
    }

    return null;
  }

  @Override
  public Image getImage() {
    return DartDebugUIPlugin.getImage("chromium_16.png"); //$NON-NLS-1$
  }

  @Override
  public String getMessage() {
    return DartiumLaunchMessages.DartiumMainTab_Message;
  }

  @Override
  public String getName() {
    return DartiumLaunchMessages.DartiumMainTab_Name;
  }

  @Override
  public void initializeFrom(ILaunchConfiguration configuration) {
    DartLaunchConfigWrapper dartLauncher = new DartLaunchConfigWrapper(configuration);

    htmlText.setText(dartLauncher.appendQueryParams(dartLauncher.getApplicationName()));
    urlText.setText(dartLauncher.getUrl());

    sourceDirectoryText.setText(dartLauncher.getSourceDirectoryName());

    if (dartLauncher.getShouldLaunchFile()) {
      htmlButton.setSelection(true);
      urlButton.setSelection(false);
      updateEnablements(true);
    } else {
      htmlButton.setSelection(false);
      urlButton.setSelection(true);
      updateEnablements(false);
    }

    if (checkedModeButton != null) {
      checkedModeButton.setSelection(dartLauncher.getCheckedMode());
    }

    if (showOutputButton != null) {
      showOutputButton.setSelection(dartLauncher.getShowLaunchOutput());
    }

    if (useWebComponentsButton != null) {
      useWebComponentsButton.setSelection(dartLauncher.getUseWebComponents());
    }

    argumentText.setText(dartLauncher.getArguments());
  }

  @Override
  public boolean isValid(ILaunchConfiguration launchConfig) {
    return getErrorMessage() == null;
  }

  @Override
  public void performApply(ILaunchConfigurationWorkingCopy configuration) {
    DartLaunchConfigWrapper dartLauncher = new DartLaunchConfigWrapper(configuration);
    dartLauncher.setShouldLaunchFile(htmlButton.getSelection());

    String fileUrl = htmlText.getText();

    if (fileUrl.indexOf('?') == -1) {
      dartLauncher.setApplicationName(fileUrl);
      dartLauncher.setUrlQueryParams("");
    } else {
      int index = fileUrl.indexOf('?');

      dartLauncher.setApplicationName(fileUrl.substring(0, index));
      dartLauncher.setUrlQueryParams(fileUrl.substring(index + 1));
    }

    dartLauncher.setUrl(urlText.getText().trim());
    dartLauncher.setSourceDirectoryName(sourceDirectoryText.getText().trim());

    if (checkedModeButton != null) {
      dartLauncher.setCheckedMode(checkedModeButton.getSelection());
    }

    if (showOutputButton != null) {
      dartLauncher.setShowLaunchOutput(showOutputButton.getSelection());
    }

    if (useWebComponentsButton != null) {
      dartLauncher.setUseWebComponents(useWebComponentsButton.getSelection());
    }

    dartLauncher.setArguments(argumentText.getText().trim());
  }

  @Override
  public void setDefaults(ILaunchConfigurationWorkingCopy configuration) {
    DartLaunchConfigWrapper dartLauncher = new DartLaunchConfigWrapper(configuration);
    dartLauncher.setShouldLaunchFile(true);
    dartLauncher.setApplicationName(""); //$NON-NLS-1$
  }

  protected void createHtmlField(Composite composite) {
    htmlButton = new Button(composite, SWT.RADIO);
    htmlButton.setText(DartiumLaunchMessages.DartiumMainTab_HtmlFileLabel);
    htmlButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        updateEnablements(true);
        notifyPanelChanged();
      }
    });

    htmlText = new Text(composite, SWT.BORDER | SWT.SINGLE);
    htmlText.addModifyListener(textModifyListener);
    GridDataFactory.swtDefaults().align(SWT.FILL, SWT.CENTER).hint(400, SWT.DEFAULT).grab(
        true,
        false).applyTo(htmlText);

    htmlBrowseButton = new Button(composite, SWT.PUSH);
    htmlBrowseButton.setText(DartiumLaunchMessages.DartiumMainTab_Browse);
    PixelConverter converter = new PixelConverter(htmlBrowseButton);
    int widthHint = converter.convertHorizontalDLUsToPixels(IDialogConstants.BUTTON_WIDTH);
    GridDataFactory.swtDefaults().align(SWT.FILL, SWT.BEGINNING).hint(widthHint, -1).applyTo(
        htmlBrowseButton);
    htmlBrowseButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        handleApplicationBrowseButton();
      }
    });
  }

  protected void createUrlField(Composite composite) {
    urlButton = new Button(composite, SWT.RADIO);
    urlButton.setText(DartiumLaunchMessages.DartiumMainTab_UrlLabel);
    urlButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        updateEnablements(false);
        notifyPanelChanged();
      }
    });

    urlText = new Text(composite, SWT.BORDER | SWT.SINGLE);
    urlText.addModifyListener(textModifyListener);
    GridDataFactory.swtDefaults().align(SWT.FILL, SWT.CENTER).grab(true, false).applyTo(urlText);

    // spacer
    new Label(composite, SWT.NONE);

    Label projectLabel = new Label(composite, SWT.NONE);
    projectLabel.setText(DartiumLaunchMessages.DartiumMainTab_SourceDirectoryLabel);
    GridDataFactory.swtDefaults().indent(20, 0).applyTo(projectLabel);

    sourceDirectoryText = new Text(composite, SWT.BORDER | SWT.SINGLE);
    sourceDirectoryText.setCursor(composite.getShell().getDisplay().getSystemCursor(
        SWT.CURSOR_ARROW));
    GridDataFactory.swtDefaults().align(SWT.FILL, SWT.CENTER).grab(true, false).applyTo(
        sourceDirectoryText);

    projectBrowseButton = new Button(composite, SWT.PUSH);
    projectBrowseButton.setText(DartiumLaunchMessages.DartiumMainTab_Browse);
    PixelConverter converter = new PixelConverter(htmlBrowseButton);
    int widthHint = converter.convertHorizontalDLUsToPixels(IDialogConstants.BUTTON_WIDTH);
    GridDataFactory.swtDefaults().align(SWT.FILL, SWT.BEGINNING).hint(widthHint, -1).applyTo(
        projectBrowseButton);
    projectBrowseButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        handleSourceDirectoryBrowseButton();
      }
    });
  }

  protected int getLabelColumnWidth() {
    htmlButton.pack();
    return htmlButton.getSize().x;
  }

  protected void handleApplicationBrowseButton() {
    IWorkspace workspace = ResourcesPlugin.getWorkspace();
    AppSelectionDialog dialog = new AppSelectionDialog(
        getShell(),
        workspace.getRoot(),
        new HtmlResourceFilter());
    dialog.setTitle(DartiumLaunchMessages.DartiumMainTab_SelectHtml);
    dialog.setInitialPattern(".", FilteredItemsSelectionDialog.FULL_SELECTION); //$NON-NLS-1$
    IPath path = new Path(htmlText.getText());
    if (workspace.validatePath(path.toString(), IResource.FILE).isOK()) {
      IFile file = workspace.getRoot().getFile(path);
      if (file != null && file.exists()) {
        dialog.setInitialSelections(new Object[] {path});
      }
    }

    dialog.open();

    Object[] results = dialog.getResult();

    if ((results != null) && (results.length > 0) && (results[0] instanceof IFile)) {
      IFile file = (IFile) results[0];
      String pathStr = file.getFullPath().toPortableString();

      htmlText.setText(pathStr);

      notifyPanelChanged();
    }
  }

  protected void handleSourceDirectoryBrowseButton() {
    ContainerSelectionDialog dialog = new ContainerSelectionDialog(
        getShell(),
        null,
        false,
        DartiumLaunchMessages.DartiumMainTab_SelectProject);

    dialog.open();

    Object[] results = dialog.getResult();

    if ((results != null) && (results.length > 0)) {
      String pathStr = ((IPath) results[0]).toString();
      sourceDirectoryText.setText(pathStr);
      notifyPanelChanged();
    }
  }

  protected void notifyPanelChanged() {
    setDirty(true);

    updateLaunchConfigurationDialog();
  }

  protected String performSdkCheck() {
    if (!DartSdkManager.getManager().hasSdk()) {
      return "Dartium is not installed ("
          + DartSdkManager.getManager().getSdk().getDartiumWorkingDirectory() + ")";
    } else {
      return null;
    }
  }

  private boolean isValidUrl(String url) {
    final String[] validSchemes = new String[] {"file:", "http:", "https:"};

    for (String scheme : validSchemes) {
      if (url.startsWith(scheme)) {
        return true;
      }
    }

    return false;
  }

  private void updateEnablements(boolean isFile) {
    if (isFile) {
      htmlText.setEnabled(true);
      htmlBrowseButton.setEnabled(true);
      urlText.setEnabled(false);
      sourceDirectoryText.setEnabled(false);
      projectBrowseButton.setEnabled(false);
    } else {
      htmlText.setEnabled(false);
      htmlBrowseButton.setEnabled(false);
      urlText.setEnabled(true);
      sourceDirectoryText.setEnabled(true);
      projectBrowseButton.setEnabled(true);
    }
  }

}
