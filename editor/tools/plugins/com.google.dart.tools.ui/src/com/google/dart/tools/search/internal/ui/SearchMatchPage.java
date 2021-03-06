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

package com.google.dart.tools.search.internal.ui;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.google.dart.engine.element.Element;
import com.google.dart.engine.element.ExecutableElement;
import com.google.dart.engine.search.SearchEngine;
import com.google.dart.engine.search.SearchMatch;
import com.google.dart.engine.source.Source;
import com.google.dart.engine.utilities.source.SourceRange;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.analysis.model.ResourceMap;
import com.google.dart.tools.ui.DartPluginImages;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.DartUI;
import com.google.dart.tools.ui.internal.text.editor.DartEditor;
import com.google.dart.tools.ui.internal.text.editor.EditorUtility;
import com.google.dart.tools.ui.internal.text.editor.NewDartElementLabelProvider;
import com.google.dart.tools.ui.internal.util.ExceptionHandler;
import com.google.dart.tools.ui.internal.util.SWTUtil;

import org.apache.commons.lang3.ObjectUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRunnable;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IStatusLineManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.viewers.DelegatingStyledCellLabelProvider;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IBaseLabelProvider;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.progress.UIJob;

import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Abstract {@link SearchPage} for displaying {@link SearchMatch}s.
 */
public abstract class SearchMatchPage extends SearchPage {
  /**
   * Helper for navigating {@link ResultItem} hierarchy.
   */
  private static class ResultCursor {
    ResultItem item;
    int positionIndex;

    ResultCursor(ResultItem item) {
      this(item, -1);
    }

    ResultCursor(ResultItem item, int positionIndex) {
      this.item = item;
      this.positionIndex = positionIndex;
    }

    Position getPosition() {
      if (item == null) {
        return null;
      }
      if (positionIndex < 0 || positionIndex > item.positions.size() - 1) {
        return null;
      }
      return item.positions.get(positionIndex);
    }

    /**
     * Moves this {@link ResultCursor} to the next {@link Position} in the same or next
     * {@link ResultItem}.
     * 
     * @return {@code true} if was moved, or {@code false} if cursor is at the last position.
     */
    boolean next() {
      ResultItem _item = item;
      int _positionIndex = positionIndex;
      // try to go to next
      if (_next()) {
        return true;
      }
      // rollback
      item = _item;
      positionIndex = _positionIndex;
      return false;
    }

    /**
     * Moves this {@link ResultCursor} to the previous {@link Position} in the same or previous
     * {@link ResultItem}.
     * 
     * @return {@code true} if was moved, or {@code false} if cursor is at the first position.
     */
    boolean prev() {
      ResultItem _item = item;
      int _positionIndex = positionIndex;
      // try to go to previous
      if (_prev()) {
        return true;
      }
      // rollback
      item = _item;
      positionIndex = _positionIndex;
      return false;
    }

    private boolean _next() {
      if (item == null) {
        return false;
      }
      // in the same leaf
      if (positionIndex < item.positions.size() - 1) {
        positionIndex++;
        return true;
      }
      // next leaf
      while (true) {
        item = item.next;
        if (item == null) {
          return false;
        }
        if (!item.positions.isEmpty()) {
          positionIndex = 0;
          break;
        }
      }
      return true;
    }

    private boolean _prev() {
      if (item == null) {
        return false;
      }
      // in the same leaf
      if (positionIndex > 0) {
        positionIndex--;
        return true;
      }
      // previous leaf
      while (true) {
        item = item.prev;
        if (item == null) {
          return false;
        }
        if (!item.positions.isEmpty()) {
          positionIndex = item.positions.size() - 1;
          break;
        }
      }
      return true;
    }
  }

  /**
   * Item in search results tree.
   */
  private static class ResultItem {
    private final Element element;
    private final List<Position> positions = Lists.newArrayList();
    private final List<ResultItem> children = Lists.newArrayList();
    private ResultItem parent;
    private ResultItem prev;
    private ResultItem next;
    private int numMatches;

    public ResultItem(Element element, Position position) {
      this.element = element;
      if (position != null) {
        positions.add(position);
      }
      numMatches = position != null ? 1 : 0;
    }

    @Override
    public boolean equals(Object obj) {
      if (!(obj instanceof ResultItem)) {
        return false;
      }
      return ObjectUtils.equals(((ResultItem) obj).element, element);
    }

    @Override
    public int hashCode() {
      return element != null ? element.hashCode() : 0;
    }

    public void merge(ResultItem item) {
      numMatches += item.numMatches;
      positions.addAll(item.positions);
    }

    void addChild(ResultItem child) {
      if (child.parent == null) {
        child.parent = this;
        children.add(child);
      }
    }
  }
  /**
   * {@link ITreeContentProvider} for {@link ResultItem}s.
   */
  private static class SearchContentProvider implements ITreeContentProvider {
    @Override
    public void dispose() {
    }

    @Override
    public Object[] getChildren(Object parentElement) {
      ResultItem item = (ResultItem) parentElement;
      List<ResultItem> rootChildren = item.children;
      return rootChildren.toArray(new ResultItem[rootChildren.size()]);
    }

    @Override
    public Object[] getElements(Object inputElement) {
      return getChildren(inputElement);
    }

    @Override
    public Object getParent(Object element) {
      return ((ResultItem) element).parent;
    }

    @Override
    public boolean hasChildren(Object element) {
      return getChildren(element).length != 0;
    }

    @Override
    public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
    }
  }

  /**
   * {@link ILabelProvider} for {@link ResultItem}s.
   */
  private static class SearchLabelProvider extends NewDartElementLabelProvider {
    @Override
    public Image getImage(Object elem) {
      ResultItem item = (ResultItem) elem;
      return super.getImage(item.element);
    }

    @Override
    public StyledString getStyledText(Object elem) {
      ResultItem item = (ResultItem) elem;
      StyledString styledText = super.getStyledText(item.element);
      if (item.numMatches == 1) {
        styledText.append(" (1 match)", StyledString.COUNTER_STYLER);
      } else if (item.numMatches > 1) {
        styledText.append(" (" + item.numMatches + " matches)", StyledString.COUNTER_STYLER);
      }
      return styledText;
    }
  }

  private static final ITreeContentProvider CONTENT_PROVIDER = new SearchContentProvider();
  private static final IBaseLabelProvider LABEL_PROVIDER = new DelegatingStyledCellLabelProvider(
      new SearchLabelProvider());

  /**
   * Adds new {@link ResultItem} to the tree.
   */
  private static ResultItem addResultItem(Map<Element, ResultItem> itemMap, ResultItem child) {
    // put child
    Element childElement = child.element;
    {
      ResultItem existingChild = itemMap.get(childElement);
      if (existingChild == null) {
        itemMap.put(childElement, child);
      } else {
        existingChild.merge(child);
        child = existingChild;
      }
    }
    // bind child to parent
    if (childElement != null) {
      Element parentElement = childElement.getEnclosingElement();
      ResultItem parent = new ResultItem(parentElement, null);
      parent = addResultItem(itemMap, parent);
      parent.addChild(child);
    }
    // done
    return child;
  }

  /**
   * Builds {@link ResultItem} tree out of the given {@link SearchMatch}s.
   */
  private static ResultItem buildResultItemTree(List<SearchMatch> matches) {
    ResultItem rootItem = new ResultItem(null, null);
    Map<Element, ResultItem> itemMap = Maps.newHashMap();
    itemMap.put(null, rootItem);
    for (SearchMatch match : matches) {
      Element element = getResultItemElement(match.getElement());
      SourceRange matchRange = match.getSourceRange();
      ResultItem child = new ResultItem(element, new Position(
          matchRange.getOffset(),
          matchRange.getLength()));
      addResultItem(itemMap, child);
    }
    calculateNumMatches(rootItem);
    sortPositions(rootItem);
    linkLeaves(rootItem, null);
    return rootItem;
  }

  /**
   * Recursively calculates {@link ResultItem#numMatches} fields.
   */
  private static int calculateNumMatches(ResultItem item) {
    int result = item.positions.size();
    for (ResultItem child : item.children) {
      result += calculateNumMatches(child);
    }
    item.numMatches = result;
    return result;
  }

  /**
   * @return the {@link Element} to use as enclosing in {@link ResultItem} tree.
   */
  private static Element getResultItemElement(Element element) {
    while (element != null) {
      Element executable = element.getAncestor(ExecutableElement.class);
      if (executable == null) {
        break;
      }
      element = executable;
    }
    return element;
  }

  /**
   * Recursively visits {@link ResultItem} and links leaves.
   * 
   * @return the last {@link ResultItem} leaf in the sub-tree.
   */
  private static ResultItem linkLeaves(ResultItem item, ResultItem prev) {
    // leaf
    if (item.children.isEmpty()) {
      if (prev != null) {
        prev.next = item;
      }
      item.prev = prev;
      prev = item;
      return item;
    }
    // container
    ResultItem lastLeaf = prev;
    item.next = item.children.get(0);
    for (ResultItem child : item.children) {
      lastLeaf = linkLeaves(child, lastLeaf);
    }
    return lastLeaf;
  }

  /**
   * Reveals the given {@link Position} in the {@link IEditorPart}.
   */
  private static void revealInEditor(IEditorPart editor, Position position) {
    SourceRange sourceRange = new SourceRange(position.offset, position.length);
    EditorUtility.revealInEditor(editor, sourceRange);
  }

  /**
   * Recursively visits {@link ResultItem} and sorts all {@link Position}s.
   */
  private static void sortPositions(ResultItem item) {
    Collections.sort(item.positions, new Comparator<Position>() {
      @Override
      public int compare(Position o1, Position o2) {
        return o1.getOffset() - o2.getOffset();
      }
    });
    Collections.sort(item.children, new Comparator<ResultItem>() {
      @Override
      public int compare(ResultItem o1, ResultItem o2) {
        return o1.element.getNameOffset() - o2.element.getNameOffset();
      }
    });
    for (ResultItem child : item.children) {
      sortPositions(child);
    }
  }

  private IAction removeAction = new Action() {
    {
      setToolTipText("Remove Selected Matches");
      DartPluginImages.setLocalImageDescriptors(this, "search_rem.gif");
    }

    @Override
    public void run() {
      IStructuredSelection selection = (IStructuredSelection) viewer.getSelection();
      for (Iterator<?> iter = selection.toList().iterator(); iter.hasNext();) {
        ResultItem item = (ResultItem) iter.next();
        while (item != null && item.element != null) {
          ResultItem parent = item.parent;
          parent.children.remove(item);
          if (!parent.children.isEmpty()) {
            break;
          }
          item = parent;
        }
      }
      calculateNumMatches(rootItem);
      // update viewer
      viewer.refresh();
      // update markers
      addMarkers();
    }
  };

  private IAction removeAllAction = new Action() {
    {
      setToolTipText("Remove All Matches");
      DartPluginImages.setLocalImageDescriptors(this, "search_remall.gif");
    }

    @Override
    public void run() {
      searchView.showPage(null);
    }
  };

  private IAction refreshAction = new Action() {
    {
      setToolTipText("Refresh the Current Search");
      DartPluginImages.setLocalImageDescriptors(this, "refresh.gif");
    }

    @Override
    public void run() {
      refresh();
    }
  };

  private IAction expandAllAction = new Action() {
    {
      setToolTipText("Expand All");
      DartPluginImages.setLocalImageDescriptors(this, "expandall.gif");
    }

    @Override
    public void run() {
      viewer.expandAll();
    }
  };

  private IAction collapseAllAction = new Action() {
    {
      setToolTipText("Collapse All");
      DartPluginImages.setLocalImageDescriptors(this, "collapseall.gif");
    }

    @Override
    public void run() {
      viewer.collapseAll();
    }
  };

  private IAction nextAction = new Action() {
    {
      setToolTipText("Show Next Match");
      DartPluginImages.setLocalImageDescriptors(this, "search_next.gif");
    }

    @Override
    public void run() {
      openItemNext();
    }
  };

  private IAction prevAction = new Action() {
    {
      setToolTipText("Show Previous Match");
      DartPluginImages.setLocalImageDescriptors(this, "search_prev.gif");
    }

    @Override
    public void run() {
      openItemPrev();
    }
  };

  private final SearchView searchView;
  private final IFile context;
  private final String taskName;
  private final Set<IResource> markerResources = Sets.newHashSet();
  private TreeViewer viewer;
  private ResultItem rootItem;
  private ResultCursor itemCursor;

  private PositionTracker positionTracker;

  public SearchMatchPage(SearchView searchView, IFile context, String taskName) {
    this.searchView = searchView;
    this.context = context;
    this.taskName = taskName;
  }

  @Override
  public void createControl(Composite parent) {
    viewer = new TreeViewer(parent, SWT.FULL_SELECTION);
    viewer.setContentProvider(CONTENT_PROVIDER);
    viewer.setLabelProvider(LABEL_PROVIDER);
    viewer.addDoubleClickListener(new IDoubleClickListener() {
      @Override
      public void doubleClick(DoubleClickEvent event) {
        ISelection selection = event.getSelection();
        openSelectedElement(selection);
      }
    });
    SearchView.updateColors(viewer.getControl());
    SWTUtil.bindJFaceResourcesFontToControl(viewer.getControl());
  }

  @Override
  public void dispose() {
    super.dispose();
    removeMarkers();
    disposePositionTracker();
  }

  @Override
  public Control getControl() {
    return viewer.getControl();
  }

  @Override
  public void makeContributions(IMenuManager menuManager, IToolBarManager toolBarManager,
      IStatusLineManager statusLineManager) {
    toolBarManager.add(nextAction);
    toolBarManager.add(prevAction);
    toolBarManager.add(new Separator());
    toolBarManager.add(removeAction);
    toolBarManager.add(removeAllAction);
    toolBarManager.add(new Separator());
    toolBarManager.add(expandAllAction);
    toolBarManager.add(collapseAllAction);
    toolBarManager.add(new Separator());
    toolBarManager.add(refreshAction);
  }

  @Override
  public void setFocus() {
    viewer.getControl().setFocus();
  }

  @Override
  public void show() {
    refresh();
  }

  /**
   * Runs a {@link SearchEngine} request.
   * 
   * @return the {@link SearchMatch}s to display.
   */
  protected abstract List<SearchMatch> runQuery();

  /**
   * Adds markers for all {@link ResultItem}s starting from {@link #rootItem}.
   */
  private void addMarkers() {
    try {
      ResourcesPlugin.getWorkspace().run(new IWorkspaceRunnable() {
        @Override
        public void run(IProgressMonitor monitor) throws CoreException {
          removeMarkers();
          markerResources.clear();
          addMarkers(rootItem);
        }
      }, null);
    } catch (Throwable e) {
      DartToolsPlugin.log(e);
    }
  }

  /**
   * Adds markers for the given {@link ResultItem} and its children.
   */
  private void addMarkers(ResultItem item) throws CoreException {
    // add marker if leaf
    if (!item.positions.isEmpty()) {
      Source source = item.element.getSource();
      ResourceMap resourceMap = DartCore.getProjectManager().getResourceMap(context);
      IResource resource = resourceMap.getResource(source);
      if (resource != null && resource.exists()) {
        markerResources.add(resource);
        try {
          List<Position> positions = item.positions;
          for (Position position : positions) {
            IMarker marker = resource.createMarker(SearchView.SEARCH_MARKER);
            marker.setAttribute(IMarker.CHAR_START, position.getOffset());
            marker.setAttribute(IMarker.CHAR_END, position.getOffset() + position.getLength());
          }
        } catch (Throwable e) {
        }
      }
    }
    // process children
    for (ResultItem child : item.children) {
      addMarkers(child);
    }
  }

  /**
   * Disposes {@link #positionTracker}.
   */
  private void disposePositionTracker() {
    if (positionTracker == null) {
      return;
    }
    positionTracker.dispose();
    positionTracker = null;
  }

  /**
   * Analyzes each {@link ResultItem} and expends it in {@link #viewer} only if it has not too much
   * children. So, user will see enough information, but not too much.
   */
  private void expandWhileSmallNumberOfChildren(List<ResultItem> items) {
    for (ResultItem item : items) {
      if (item.children.size() <= 5) {
        viewer.setExpandedState(item, true);
        expandWhileSmallNumberOfChildren(item.children);
      }
    }
  }

  /**
   * Opens {@link DartEditor} with the next {@link Position} in the same of the next
   * {@link ResultItem}.
   */
  private void openItemNext() {
    boolean changed = itemCursor.next();
    if (changed) {
      showCursor();
    }
  }

  /**
   * Opens {@link DartEditor} with the previous {@link Position} in the same of the previous
   * {@link ResultItem}.
   */
  private void openItemPrev() {
    boolean changed = itemCursor.prev();
    if (changed) {
      showCursor();
    }
  }

  /**
   * Opens selected {@link ResultItem} in the editor.
   */
  private void openSelectedElement(ISelection selection) {
    // need IStructuredSelection
    if (!(selection instanceof IStructuredSelection)) {
      return;
    }
    IStructuredSelection structuredSelection = (IStructuredSelection) selection;
    // only single element
    if (structuredSelection.size() != 1) {
      return;
    }
    Object firstElement = structuredSelection.getFirstElement();
    // prepare ResultItem
    if (!(firstElement instanceof ResultItem)) {
      return;
    }
    ResultItem item = (ResultItem) firstElement;
    // use ResultCursor to find first occurrence in the requested subtree
    itemCursor = new ResultCursor(item);
    boolean found = itemCursor.next();
    if (!found) {
      return;
    }
    Element element = itemCursor.item.element;
    Position position = itemCursor.getPosition();
    // show Element and Position
    try {
      IEditorPart editor = DartUI.openInEditor(context, element, true);
      revealInEditor(editor, position);
    } catch (Throwable e) {
      ExceptionHandler.handle(e, "Search", "Exception during open.");
    }
  }

  /**
   * Runs background {@link Job} to fetch {@link SearchMatch}s and then displays them in the
   * {@link #viewer}.
   */
  private void refresh() {
    try {
      new Job(taskName) {
        @Override
        protected IStatus run(IProgressMonitor monitor) {
          List<SearchMatch> matches = runQuery();
          rootItem = buildResultItemTree(matches);
          itemCursor = new ResultCursor(rootItem);
          trackPositions();
          // add markers
          addMarkers();
          // schedule UI update
          new UIJob("Displaying search results...") {
            @Override
            public IStatus runInUIThread(IProgressMonitor monitor) {
              Object[] expandedElements = viewer.getExpandedElements();
              viewer.setInput(rootItem);
              viewer.setExpandedElements(expandedElements);
              expandWhileSmallNumberOfChildren(rootItem.children);
              return Status.OK_STATUS;
            }
          }.schedule();
          // done
          return Status.OK_STATUS;
        }
      }.schedule();
    } catch (Throwable e) {
      ExceptionHandler.handle(e, "Search", "Exception during search.");
    }
  }

  /**
   * Removes all search markers from {@link #markerResources}.
   */
  private void removeMarkers() {
    try {
      ResourcesPlugin.getWorkspace().run(new IWorkspaceRunnable() {
        @Override
        public void run(IProgressMonitor monitor) throws CoreException {
          for (IResource resource : markerResources) {
            if (resource.exists()) {
              try {
                resource.deleteMarkers(SearchView.SEARCH_MARKER, false, IResource.DEPTH_ZERO);
              } catch (Throwable e) {
              }
            }
          }
        }
      }, null);
    } catch (Throwable e) {
      DartToolsPlugin.log(e);
    }
  }

  /**
   * Shows current {@link #itemCursor} state.
   */
  private void showCursor() {
    try {
      viewer.setSelection(new StructuredSelection(itemCursor.item), true);
      // open editor with Element
      Element element = itemCursor.item.element;
      IEditorPart editor = DartUI.openInEditor(context, element, false);
      // show Position
      Position position = itemCursor.getPosition();
      if (position != null) {
        revealInEditor(editor, position);
      }
    } catch (Throwable e) {
      ExceptionHandler.handle(e, "Search", "Exception during open.");
    }
  }

  /**
   * Starts tracking all search result positions in {@link #positionTracker}.
   */
  private void trackPositions() {
    disposePositionTracker();
    positionTracker = new PositionTracker();
    trackPositions(rootItem);
  }

  /**
   * Recursively visits {@link ResultItem} and tracks all {@link Position}s.
   */
  private void trackPositions(ResultItem item) {
    // do track positions
    if (item.element != null) {
      IFile file = DartUI.getElementFile(item.element);
      if (file != null) {
        for (Position position : item.positions) {
          positionTracker.trackPosition(file, position);
        }
      }
    }
    // process children
    for (ResultItem child : item.children) {
      trackPositions(child);
    }
  }
}
