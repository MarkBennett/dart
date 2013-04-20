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
package com.google.dart.tools.ui.internal.intro;

import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.internal.handlers.OpenFolderHandler;
import com.google.dart.tools.ui.internal.projects.OpenNewApplicationWizardAction;
import com.google.dart.tools.ui.internal.util.ExternalBrowserUtil;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.MouseAdapter;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.IPersistableElement;
import org.eclipse.ui.forms.events.HyperlinkAdapter;
import org.eclipse.ui.forms.events.HyperlinkEvent;
import org.eclipse.ui.forms.widgets.FormText;
import org.eclipse.ui.forms.widgets.FormToolkit;
import org.eclipse.ui.forms.widgets.Hyperlink;
import org.eclipse.ui.forms.widgets.ScrolledForm;
import org.eclipse.ui.forms.widgets.Section;
import org.eclipse.ui.forms.widgets.TableWrapData;
import org.eclipse.ui.forms.widgets.TableWrapLayout;
import org.eclipse.ui.part.EditorPart;

import java.util.HashMap;
import java.util.Map;

/**
 * A "fake" editor for showing intro content to first time users.
 */
public class IntroEditor extends EditorPart {
  public static final String ID = "com.google.dart.tools.ui.intro.editor"; //$NON-NLS-1$

  public static final IEditorInput INPUT = new IEditorInput() {
    @Override
    public boolean exists() {
      return false;
    }

    @Override
    public Object getAdapter(@SuppressWarnings("rawtypes") Class adapter) {
      return null;
    }

    @Override
    public ImageDescriptor getImageDescriptor() {
      return null;
    }

    @Override
    public String getName() {
      return IntroMessages.IntroEditor_name;
    }

    @Override
    public IPersistableElement getPersistable() {
      return null;
    }

    @Override
    public String getToolTipText() {
      return IntroMessages.IntroEditor_tooltip;
    }
  };

  private ScrolledForm form;

  private FormToolkit toolkit;

  private Map<Font, Font> fontMap = new HashMap<Font, Font>();

  public IntroEditor() {

  }

  @Override
  public void createPartControl(Composite parent) {
    toolkit = new FormToolkit(parent.getDisplay());

    // Create the form and header.
    form = toolkit.createScrolledForm(parent);
    form.setText("Welcome to Dart Editor!");
    form.setImage(DartToolsPlugin.getImage("icons/dart_16_16.gif"));
    toolkit.decorateFormHeading(form.getForm());
    form.getToolBarManager().update(true);

    TableWrapLayout layout = new TableWrapLayout();
    layout.numColumns = 2;
    layout.verticalSpacing = 10;
    layout.topMargin = 12;
    form.getBody().setLayout(layout);

    // Create the actions area.
    Section section = toolkit.createSection(form.getBody(), Section.TITLE_BAR | Section.DESCRIPTION);
    section.setLayoutData(new TableWrapData(TableWrapData.FILL, TableWrapData.TOP, 1, 1));
    section.setText("Getting Started");
    section.setDescription("Get started using the editor!");
    Composite client = toolkit.createComposite(section);
    GridLayoutFactory.swtDefaults().spacing(0, 0).applyTo(client);

    Button createButton = new Button(client, SWT.PUSH);
    createButton.setText("Create an application...");
    createButton.setImage(DartToolsPlugin.getImage("icons/full/dart16/package_obj_new.png"));
    createButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        OpenNewApplicationWizardAction action = new OpenNewApplicationWizardAction();

        action.run();
      }
    });
    GridDataFactory.fillDefaults().align(SWT.FILL, SWT.CENTER).applyTo(createButton);

    Button openButton = new Button(client, SWT.PUSH | SWT.LEFT);
    openButton.setText("Open existing code...");
    openButton.setImage(DartToolsPlugin.getImage("icons/full/obj16/fldr_obj.gif"));
    openButton.addSelectionListener(new SelectionAdapter() {
      @Override
      public void widgetSelected(SelectionEvent e) {
        IAction action = OpenFolderHandler.createCommandAction(getSite().getWorkbenchWindow());

        action.run();
      }
    });
    GridDataFactory.fillDefaults().align(SWT.FILL, SWT.CENTER).applyTo(openButton);

    section.setClient(client);

    // Create the info area.
    section = toolkit.createSection(form.getBody(), Section.TITLE_BAR | Section.DESCRIPTION);
    section.setLayoutData(new TableWrapData(TableWrapData.FILL, TableWrapData.TOP, 1, 1));
    section.setText("About Dart");
    section.setDescription("Build HTML5 apps for the modern web! Dart brings structure to web app engineering with a new language, libraries, and tools.");
    client = toolkit.createComposite(section);
    client.setLayout(new TableWrapLayout());

    Composite links = new Composite(client, SWT.NONE);

    GridLayoutFactory.fillDefaults().numColumns(2).spacing(15, 0).applyTo(links);

    createExternalLink(links, "Visit dartlang.org", "http://www.dartlang.org/");

    createExternalLink(links, "Explore the Pub repository", "http://pub.dartlang.org/");

    createExternalLink(links, "View Editor documentation", "http://www.dartlang.org/editor/");

    createExternalLink(
        links,
        "Additional HTML5 samples",
        "https://github.com/dart-lang/dart-html5-samples/");

    createExternalLink(links, "Try the Dart tutorial", "http://www.dartlang.org/docs/tutorials/");

    createExternalLink(
        links,
        "Read the O'Reilly book",
        "http://www.dartlang.org/docs/dart-up-and-running/");

    section.setClient(client);

    // Create the samples area.
    if (DartCore.isWindowsXp()) {
      section = toolkit.createSection(form.getBody(), Section.DESCRIPTION | Section.TITLE_BAR);
      section.setDescription("The samples require the dart.js file to run. In the sample's HTML file, "
          + "change src=\"packages/browser/dart.js\" to point to the local copy of dart.js, "
          + "located in the Editor's samples directory.");
    } else {
      section = toolkit.createSection(form.getBody(), /*Section.DESCRIPTION |*/Section.TITLE_BAR);
    }

    section.setLayoutData(new TableWrapData(TableWrapData.FILL_GRAB, TableWrapData.FILL_GRAB, 1, 2));
    section.setText("Sample Applications");
    //section.setDescription("Open and run several Dart sample applications.");
    client = toolkit.createComposite(section);
    TableWrapLayout l = new TableWrapLayout();
    l.numColumns = 4;
    l.verticalSpacing = 10;
    client.setLayout(l);

    for (final SampleDescription description : SampleDescriptionHelper.getDescriptions()) {
      Label label = toolkit.createLabel(client, "", SWT.BORDER);
      label.setImage(DartToolsPlugin.getImage(description.logoPath));
      label.setCursor(getSite().getShell().getDisplay().getSystemCursor(SWT.CURSOR_HAND));
      label.addMouseListener(new MouseAdapter() {
        @Override
        public void mouseUp(MouseEvent e) {
          SampleHelper.openSample(description, getSite());
        }
      });

      FormText formText = toolkit.createFormText(client, true);
      formText.setText("<form><p><a href=\"open:woot\">" + description.name + "</a><br></br>"
          + description.description + "</p></form>", true, false);
      formText.setLayoutData(new TableWrapData(TableWrapData.FILL_GRAB, TableWrapData.TOP, 1, 1));
      formText.addHyperlinkListener(new HyperlinkAdapter() {
        @Override
        public void linkActivated(HyperlinkEvent e) {
          SampleHelper.openSample(description, getSite());
        }
      });
    }

    section.setClient(client);

    form.reflow(true);
  }

  @Override
  public void dispose() {
    toolkit.dispose();

    super.dispose();

    for (Font font : fontMap.values()) {
      font.dispose();
    }

    fontMap.clear();
  }

  @Override
  public void doSave(IProgressMonitor monitor) {

  }

  @Override
  public void doSaveAs() {

  }

  @Override
  public void init(IEditorSite site, IEditorInput input) {
    setSite(site);
    setInput(input);
    setTitleToolTip(input.getToolTipText());
  }

  @Override
  public boolean isDirty() {
    return false;
  }

  @Override
  public boolean isSaveAsAllowed() {
    return false;
  }

  @Override
  public void setFocus() {

  }

  private void createExternalLink(Composite client, String text, final String href) {

    Hyperlink link = toolkit.createHyperlink(client, text, SWT.NONE);
    link.addHyperlinkListener(new HyperlinkAdapter() {
      @Override
      public void linkActivated(HyperlinkEvent e) {
        ExternalBrowserUtil.openInExternalBrowser(href);
      }
    });

  }

}
