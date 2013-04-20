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
package com.google.dart.tools.ui.actions;

import com.google.dart.tools.ui.DartPluginImages;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.PreferenceConstants;
import com.google.dart.tools.ui.internal.text.DartHelpContextIds;
import com.google.dart.tools.ui.internal.viewsupport.MemberFilter;
import com.google.dart.tools.ui.internal.viewsupport.MemberFilterAction;

import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.viewers.StructuredViewer;
import org.eclipse.swt.custom.BusyIndicator;
import org.eclipse.ui.IActionBars;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.actions.ActionGroup;

import java.util.ArrayList;

/**
 * Action Group that contributes filter buttons for a view parts showing methods and fields.
 * Contributed filters are: hide fields, hide static members hide non-public members and hide local
 * types.
 * <p>
 * The action group installs a filter on a structured viewer. The filter is connected to the actions
 * installed in the view part's toolbar menu and is updated when the state of the buttons changes.
 * <p>
 * This class may be instantiated; it is not intended to be subclassed.
 * </p>
 * Provisional API: This class/interface is part of an interim API that is still under development
 * and expected to change significantly before reaching stability. It is being made available at
 * this early stage to solicit feedback from pioneering adopters on the understanding that any code
 * that uses this API will almost certainly be broken (repeatedly) as the API evolves.
 */
public class MemberFilterActionGroup extends ActionGroup {

  /*
   * TODO(pquitslund): consider additional filter actions. For example:
   * 
   * 1) filter functions . 2) For an interface with a default implementation, show additional
   * members from the implementation class.
   */

  public static final int FILTER_STATIC = MemberFilter.FILTER_STATIC;
  public static final int FILTER_FIELDS = MemberFilter.FILTER_FIELDS;

//  public static final int FILTER_LOCALTYPES = MemberFilter.FILTER_LOCALTYPES;

  public static final int ALL_FILTERS = FILTER_FIELDS | FILTER_STATIC;// | FILTER_LOCALTYPES;

  private static final String TAG_HIDEFIELDS = "hidefields"; //$NON-NLS-1$
  private static final String TAG_HIDESTATIC = "hidestatic"; //$NON-NLS-1$
//  private static final String TAG_HIDELOCALTYPES = "hidelocaltypes"; //$NON-NLS-1$

  private MemberFilterAction[] fFilterActions;
  private MemberFilter fFilter;

  private StructuredViewer fViewer;
  private String fViewerId;
  private boolean fInViewMenu;

  /**
   * Creates a new <code>MemberFilterActionGroup</code>.
   * 
   * @param viewer the viewer to be filtered
   * @param viewerId a unique id of the viewer. Used as a key to to store the last used filter
   *          settings in the preference store
   */
  public MemberFilterActionGroup(StructuredViewer viewer, String viewerId) {
    this(viewer, viewerId, false);
  }

  /**
   * Creates a new <code>MemberFilterActionGroup</code>.
   * 
   * @param viewer the viewer to be filtered
   * @param viewerId a unique id of the viewer. Used as a key to to store the last used filter
   *          settings in the preference store
   * @param inViewMenu if <code>true</code> the actions are added to the view menu. If
   *          <code>false</code> they are added to the toolbar.
   */
  public MemberFilterActionGroup(StructuredViewer viewer, String viewerId, boolean inViewMenu) {
    this(viewer, viewerId, inViewMenu, ALL_FILTERS);
  }

  /**
   * Creates a new <code>MemberFilterActionGroup</code>.
   * 
   * @param viewer the viewer to be filtered
   * @param viewerId a unique id of the viewer. Used as a key to to store the last used filter
   *          settings in the preference store
   * @param inViewMenu if <code>true</code> the actions are added to the view menu. If
   *          <code>false</code> they are added to the toolbar.
   * @param availableFilters Specifies which filter action should be contained.
   *          <code>FILTER_FIELDS</code> and <code>FILTER_LOCALTYPES</code> or a combination of
   *          these constants are possible values. Use <code>ALL_FILTERS</code> to select all
   *          available filters.
   */
  public MemberFilterActionGroup(StructuredViewer viewer, String viewerId, boolean inViewMenu,
      int availableFilters) {

    fViewer = viewer;
    fViewerId = viewerId;
    fInViewMenu = inViewMenu;

    IPreferenceStore store = PreferenceConstants.getPreferenceStore();
    fFilter = new MemberFilter();

    String title, helpContext;
    ArrayList<MemberFilterAction> actions = new ArrayList<MemberFilterAction>(4);

    // fields
    int filterProperty = FILTER_FIELDS;
    if (isSet(filterProperty, availableFilters)) {
      boolean filterEnabled = store.getBoolean(getPreferenceKey(filterProperty));
      if (filterEnabled) {
        fFilter.addFilter(filterProperty);
      }
      title = ActionMessages.MemberFilterActionGroup_hide_fields_label;
      helpContext = DartHelpContextIds.FILTER_FIELDS_ACTION;
      MemberFilterAction hideFields = new MemberFilterAction(
          this,
          title,
          filterProperty,
          helpContext,
          filterEnabled);
      hideFields.setDescription(ActionMessages.MemberFilterActionGroup_hide_fields_description);
      hideFields.setToolTipText(ActionMessages.MemberFilterActionGroup_hide_fields_tooltip);
      DartPluginImages.setLocalImageDescriptors(hideFields, "fields_co.gif"); //$NON-NLS-1$
      actions.add(hideFields);
    }

    // static
    filterProperty = FILTER_STATIC;
    if (isSet(filterProperty, availableFilters)) {
      boolean filterEnabled = store.getBoolean(getPreferenceKey(filterProperty));
      if (filterEnabled) {
        fFilter.addFilter(filterProperty);
      }
      title = ActionMessages.MemberFilterActionGroup_hide_static_label;
      helpContext = DartHelpContextIds.FILTER_STATIC_ACTION;
      MemberFilterAction hideStatic = new MemberFilterAction(
          this,
          title,
          FILTER_STATIC,
          helpContext,
          filterEnabled);
      hideStatic.setDescription(ActionMessages.MemberFilterActionGroup_hide_static_description);
      hideStatic.setToolTipText(ActionMessages.MemberFilterActionGroup_hide_static_tooltip);
      DartPluginImages.setLocalImageDescriptors(hideStatic, "static_co.gif"); //$NON-NLS-1$
      actions.add(hideStatic);
    }

    // local types
//    filterProperty = FILTER_LOCALTYPES;
//    if (isSet(filterProperty, availableFilters)) {
//      boolean filterEnabled = store.getBoolean(getPreferenceKey(filterProperty));
//      if (filterEnabled) {
//        fFilter.addFilter(filterProperty);
//      }
//      title = ActionMessages.MemberFilterActionGroup_hide_localtypes_label;
//      helpContext = DartHelpContextIds.FILTER_LOCALTYPES_ACTION;
//      MemberFilterAction hideLocalTypes = new MemberFilterAction(this, title,
//          filterProperty, helpContext, filterEnabled);
//      hideLocalTypes.setDescription(ActionMessages.MemberFilterActionGroup_hide_localtypes_description);
//      hideLocalTypes.setToolTipText(ActionMessages.MemberFilterActionGroup_hide_localtypes_tooltip);
//      JavaPluginImages.setLocalImageDescriptors(hideLocalTypes,
//          "localtypes_co.gif"); //$NON-NLS-1$
//      actions.add(hideLocalTypes);
//    }

    // order corresponds to order in toolbar
    fFilterActions = actions.toArray(new MemberFilterAction[actions.size()]);

    fViewer.addFilter(fFilter);
  }

  /**
   * Adds the filter actions to the given tool bar
   * 
   * @param tbm the tool bar to which the actions are added
   */
  public void contributeToToolBar(IToolBarManager tbm) {
    if (fInViewMenu) {
      return;
    }
    for (int i = 0; i < fFilterActions.length; i++) {
      tbm.add(fFilterActions[i]);
    }
  }

  /**
   * Adds the filter actions to the given menu manager.
   * 
   * @param menu the menu manager to which the actions are added
   */
  public void contributeToViewMenu(IMenuManager menu) {
    if (!fInViewMenu) {
      return;
    }
    final String filters = "filters"; //$NON-NLS-1$
    if (menu.find(filters) != null) {
      for (int i = 0; i < fFilterActions.length; i++) {
        menu.prependToGroup(filters, fFilterActions[i]);
      }
    } else {
      for (int i = 0; i < fFilterActions.length; i++) {
        menu.add(fFilterActions[i]);
      }
    }
  }

  /*
   * (non-Javadoc)
   * 
   * @see ActionGroup#dispose()
   */
  @Override
  public void dispose() {
    super.dispose();
  }

  /*
   * (non-Javadoc)
   * 
   * @see ActionGroup#fillActionBars(IActionBars)
   */
  @Override
  public void fillActionBars(IActionBars actionBars) {
    contributeToToolBar(actionBars.getToolBarManager());
  }

  /**
   * Returns <code>true</code> if the given filter is installed.
   * 
   * @param filterProperty the filter to be tested. Valid values are <code>FILTER_FIELDS</code>,
   *          <code>FILTER_PUBLIC</code>, <code>FILTER_PRIVATE</code> and
   *          <code>FILTER_LOCALTYPES</code> as defined by this action group
   */
  public boolean hasMemberFilter(int filterProperty) {
    return fFilter.hasFilter(filterProperty);
  }

  /**
   * Restores the state of the filter actions from a memento.
   * <p>
   * Note: This method does not refresh the viewer.
   * </p>
   * 
   * @param memento the memento from which the state is restored
   */
  public void restoreState(IMemento memento) {
    setMemberFilters(new int[] {FILTER_FIELDS, FILTER_STATIC},// ,
// FILTER_LOCALTYPES},
        new boolean[] {
            Boolean.valueOf(memento.getString(TAG_HIDEFIELDS)).booleanValue(),
            Boolean.valueOf(memento.getString(TAG_HIDESTATIC)).booleanValue(),
//            Boolean.valueOf(memento.getString(TAG_HIDELOCALTYPES)).booleanValue()
        },
        false);
  }

  /**
   * Saves the state of the filter actions in a memento.
   * 
   * @param memento the memento to which the state is saved
   */
  public void saveState(IMemento memento) {
    memento.putString(TAG_HIDEFIELDS, String.valueOf(hasMemberFilter(FILTER_FIELDS)));
    memento.putString(TAG_HIDESTATIC, String.valueOf(hasMemberFilter(FILTER_STATIC)));
//    memento.putString(TAG_HIDELOCALTYPES,
//        String.valueOf(hasMemberFilter(FILTER_LOCALTYPES)));
  }

  /**
   * Sets the member filters.
   * 
   * @param filterProperty the filter to be manipulated. Valid values are <code>FILTER_FIELDS</code>
   *          , <code>FILTER_PUBLIC</code> <code>FILTER_PRIVATE</code> and
   *          <code>FILTER_LOCALTYPES_ACTION</code> as defined by this action group
   * @param set if <code>true</code> the given filter is installed. If <code>false</code> the given
   *          filter is removed .
   */
  public void setMemberFilter(int filterProperty, boolean set) {
    setMemberFilters(new int[] {filterProperty}, new boolean[] {set}, true);
  }

  private String getPreferenceKey(int filterProperty) {
    return "MemberFilterActionGroup." + fViewerId + '.' + String.valueOf(filterProperty); //$NON-NLS-1$
  }

  private boolean isSet(int flag, int set) {
    return (flag & set) != 0;
  }

  private void setMemberFilters(int[] propertyKeys, boolean[] propertyValues, boolean refresh) {
    if (propertyKeys.length == 0) {
      return;
    }
    Assert.isTrue(propertyKeys.length == propertyValues.length);

    for (int i = 0; i < propertyKeys.length; i++) {
      int filterProperty = propertyKeys[i];
      boolean set = propertyValues[i];

      IPreferenceStore store = DartToolsPlugin.getDefault().getPreferenceStore();
      boolean found = false;
      for (int j = 0; j < fFilterActions.length; j++) {
        int currProperty = fFilterActions[j].getFilterProperty();
        if (currProperty == filterProperty) {
          fFilterActions[j].setChecked(set);
          found = true;
          store.setValue(getPreferenceKey(filterProperty), set);
        }
      }
      if (found) {
        if (set) {
          fFilter.addFilter(filterProperty);
        } else {
          fFilter.removeFilter(filterProperty);
        }
      }
    }
    if (refresh) {
      fViewer.getControl().setRedraw(false);
      BusyIndicator.showWhile(fViewer.getControl().getDisplay(), new Runnable() {
        @Override
        public void run() {
          fViewer.refresh();
        }
      });
      fViewer.getControl().setRedraw(true);
    }
  }

}
