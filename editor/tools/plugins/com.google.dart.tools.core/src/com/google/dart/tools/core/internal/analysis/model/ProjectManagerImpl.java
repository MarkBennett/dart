/*
 * Copyright 2013 Dart project authors.
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
package com.google.dart.tools.core.internal.analysis.model;

import com.google.dart.engine.context.AnalysisContext;
import com.google.dart.engine.context.AnalysisErrorInfo;
import com.google.dart.engine.context.ChangeSet;
import com.google.dart.engine.index.Index;
import com.google.dart.engine.index.IndexFactory;
import com.google.dart.engine.sdk.DartSdk;
import com.google.dart.engine.sdk.DirectoryBasedDartSdk;
import com.google.dart.engine.search.SearchEngine;
import com.google.dart.engine.search.SearchEngineFactory;
import com.google.dart.engine.source.DirectoryBasedSourceContainer;
import com.google.dart.engine.source.FileBasedSource;
import com.google.dart.engine.source.Source;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.analysis.model.Project;
import com.google.dart.tools.core.analysis.model.ProjectEvent;
import com.google.dart.tools.core.analysis.model.ProjectListener;
import com.google.dart.tools.core.analysis.model.ProjectManager;
import com.google.dart.tools.core.analysis.model.PubFolder;
import com.google.dart.tools.core.analysis.model.ResourceMap;
import com.google.dart.tools.core.builder.BuildEvent;
import com.google.dart.tools.core.internal.builder.AnalysisEngineParticipant;
import com.google.dart.tools.core.internal.builder.AnalysisMarkerManager;
import com.google.dart.tools.core.internal.builder.AnalysisWorker;
import com.google.dart.tools.core.internal.model.DartIgnoreManager;
import com.google.dart.tools.core.model.DartIgnoreEvent;
import com.google.dart.tools.core.model.DartIgnoreListener;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceProxy;
import org.eclipse.core.resources.IResourceProxyVisitor;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

/**
 * Concrete implementation of {@link ProjectManager}
 */
public class ProjectManagerImpl extends ContextManagerImpl implements ProjectManager {

  private final IWorkspaceRoot resource;
  private final HashMap<IProject, Project> projects = new HashMap<IProject, Project>();
  private final Index index = IndexFactory.newIndex(IndexFactory.newMemoryIndexStore());
  private final DartIgnoreManager ignoreManager;
  private final ArrayList<ProjectListener> listeners = new ArrayList<ProjectListener>();

  /**
   * A listener that updates the manager when a project is closed. In addition, this listener
   * processes changes in packages directory because Eclipse builders do not receive deltas for
   * changes in symlinked folders.
   */
  private IResourceChangeListener resourceChangeListener = new WorkspaceDeltaProcessor(this);

  private DartIgnoreListener ignoreListener = new DartIgnoreListener() {

    @Override
    public void ignoresChanged(DartIgnoreEvent event) {
      String[] ignoresAdded = event.getAdded();
      String[] ignoresRemoved = event.getRemoved();
      if (ignoresAdded.length > 0) {
        processIgnoresAdded(ignoresAdded);
      }
      if (ignoresRemoved.length > 0) {
        processIgnoresRemoved(ignoresRemoved);
      }
    }
  };

  public ProjectManagerImpl(IWorkspaceRoot resource, DartSdk sdk, DartIgnoreManager ignoreManager) {
    super(sdk);
    this.resource = resource;
    this.ignoreManager = ignoreManager;
  }

  @Override
  public void addProjectListener(ProjectListener listener) {
    synchronized (listeners) {
      if (listener != null && !listeners.contains(listener)) {
        listeners.add(listener);
      }
    }
  }

  @Override
  public AnalysisContext getContext(IResource resource) {
    if (resource == null) {
      return null;
    }
    return getProject(resource.getProject()).getContext(resource);
  }

  @Override
  public IResource getHtmlFileForLibrary(Source source) {
    AnalysisContext context = getContext(getResource(source));
    if (context != null) {
      Source[] htmlSource = context.getHtmlFilesReferencing(source);
      if (htmlSource.length > 0) {
        return getResource(htmlSource[0]);
      }
    }
    return null;
  }

  @Override
  public DartIgnoreManager getIgnoreManager() {
    return ignoreManager;
  }

  @Override
  public Index getIndex() {
    return index;
  }

  @Override
  public Source[] getLaunchableClientLibrarySources() {
    List<Source> sources = new ArrayList<Source>();
    for (Project project : getProjects()) {
      sources.addAll(Arrays.asList(project.getLaunchableClientLibrarySources()));
    }
    return sources.toArray(new Source[sources.size()]);
  }

  @Override
  public Source[] getLaunchableServerLibrarySources() {
    List<Source> sources = new ArrayList<Source>();
    for (Project project : getProjects()) {
      sources.addAll(Arrays.asList(project.getLaunchableServerLibrarySources()));
    }
    return sources.toArray(new Source[sources.size()]);
  }

  @Override
  public Source[] getLibrarySources(IFile file) {
    AnalysisContext context = getContext(file);
    Source source = getSource(file);
    return context.getLibrariesContaining(source);
  }

  @Override
  public Source[] getLibrarySources(IProject project) {
    return getProject(project).getLibrarySources();
  }

  @Override
  public Project getProject(IProject resource) {
    synchronized (projects) {
      Project result = projects.get(resource);
      if (result == null) {
        if (resource.getFile("lib/_internal/libraries.dart").exists()) {
          //
          // If this file exists, then the project is assumed to have been opened on the root of an
          // SDK. In such a case we want to use the SDK being edited as the SDK for analysis so that
          // analysis engine can correctly recognize files within dart:core. Failure to do so causes
          // analysis engine to implicitly import (a potentially different version of) dart:core
          // into the dart:core files in the project, which leads to a large number of false
          // positives.
          //
          result = new ProjectImpl(resource, new DirectoryBasedDartSdk(
              resource.getLocation().toFile()));
        } else {
          result = new ProjectImpl(resource, getSdk());
        }
        projects.put(resource, result);
      }
      return result;
    }
  }

  @Override
  public Project[] getProjects() {
    IProject[] childResources = resource.getProjects();
    Project[] result = new Project[childResources.length];
    for (int index = 0; index < result.length; index++) {
      result[index] = getProject(childResources[index]);
    }
    return result;
  }

  @Override
  public PubFolder getPubFolder(IResource resource) {
    return getProject(resource.getProject()).getPubFolder(resource);
  }

  @Override
  public IWorkspaceRoot getResource() {
    return resource;
  }

  @Override
  public IResource getResource(Source source) {
    // TODO (danrubel): revisit and optimize performance
    if (source == null) {
      return null;
    }
    for (Project project : getProjects()) {
      IResource res = project.getResource(source);
      if (res != null) {
        return res;
      }
    }
    return null;
  }

  @Override
  public ResourceMap getResourceMap(IResource resource) {
    return getProject(resource.getProject()).getResourceMap(resource);
  }

  @Override
  public boolean isClientLibrary(Source librarySource) {
    IResource resource = getResource(librarySource);
    if (resource != null) {
      AnalysisContext context = getContext(resource);
      return context.isClientLibrary(librarySource);
    }
    return false;
  }

  @Override
  public boolean isServerLibrary(Source librarySource) {
    IResource resource = getResource(librarySource);
    if (resource != null) {
      AnalysisContext context = getContext(resource);
      return context.isServerLibrary(librarySource);
    }
    return false;
  }

  @Override
  public SearchEngine newSearchEngine() {
    return SearchEngineFactory.createSearchEngine(getIndex());
  }

  @Override
  public void projectAnalyzed(Project project) {
    final ProjectEvent event = new ProjectEvent(project);
    ProjectListener[] currentListeners = listeners.toArray(new ProjectListener[listeners.size()]);
    for (ProjectListener listener : currentListeners) {
      try {
        listener.projectAnalyzed(event);
      } catch (Exception e) {
        DartCore.logError("Exception while notifying listeners project was analyzed", e);
      }
    }
  }

  @Override
  public void projectRemoved(IProject projectResource) {
    Project result;
    synchronized (projects) {
      result = projects.remove(projectResource);
    }
    if (result != null) {
      result.discardContextsIn(projectResource);
    }
  }

  @Override
  public void removeProjectListener(ProjectListener listener) {
    synchronized (listeners) {
      listeners.remove(listener);
    }
  }

  @Override
  public void start() {
    new Thread() {
      @Override
      public void run() {
        index.run();
      }
    }.start();
    resource.getWorkspace().addResourceChangeListener(resourceChangeListener);
    ignoreManager.addListener(ignoreListener);
    analyzeAllProjects();
    new AnalysisWorker(this, getSdkContext()).performAnalysisInBackground();
  }

  @Override
  public void stop() {
    resource.getWorkspace().removeResourceChangeListener(resourceChangeListener);
    ignoreManager.removeListener(ignoreListener);
    index.stop();
  }

  private void analyzeAllProjects() {
    for (Project project : getProjects()) {
      BuildEvent event = new BuildEvent(project.getResource(), null, new NullProgressMonitor());
      AnalysisEngineParticipant participant = new AnalysisEngineParticipant(
          true,
          this,
          AnalysisMarkerManager.getInstance());
      try {
        participant.build(event, new NullProgressMonitor());
      } catch (CoreException e) {
        DartCore.logError(e);
      }
    }
  }

  private IResource getResourceFromPath(String path) {
    IResource resource = null;
    File file = new File(path);
    if (file.isFile()) {
      resource = ResourcesPlugin.getWorkspace().getRoot().getFileForLocation(new Path(path));
    } else {
      resource = ResourcesPlugin.getWorkspace().getRoot().getContainerForLocation(new Path(path));
    }
    return resource;
  }

  private List<Source> getSourcesIn(IResource resource) {

    final List<Source> sources = new ArrayList<Source>();
    final AnalysisContext context = getContext(resource);
    try {
      resource.accept(new IResourceProxyVisitor() {
        @Override
        public boolean visit(IResourceProxy proxy) throws CoreException {
          if (proxy.getType() == IResource.FILE) {
            if (proxy.requestResource().getLocation() != null) {
              Source source = new FileBasedSource(
                  context.getSourceFactory().getContentCache(),
                  proxy.requestResource().getLocation().toFile());
              sources.add(source);
            }
          } else if (proxy.getType() == IResource.FOLDER && proxy.getName().startsWith(".")) {
            return false;
          }
          return true;
        }
      }, 0);
    } catch (CoreException e) {
      DartCore.logError(e);
    }
    return sources;
  }

  private void processIgnoresAdded(String[] paths) {
    for (String path : paths) {
      ChangeSet changeSet = new ChangeSet();
      IResource resource = getResourceFromPath(path);
      if (resource != null) {
        AnalysisContext context = getContext(resource);
        if (resource instanceof IFile) {
          changeSet.removed(getSource((IFile) resource));
        } else {
          changeSet.removedContainer(new DirectoryBasedSourceContainer(new File(path)));
        }
        context.applyChanges(changeSet);
        AnalysisMarkerManager.getInstance().clearMarkers(resource);
      }
    }
  }

  private void processIgnoresRemoved(String[] paths) {
    for (String path : paths) {
      ChangeSet changeSet = new ChangeSet();
      List<Source> sources = new ArrayList<Source>();
      IResource resource = getResourceFromPath(path);

      if (resource != null) {
        AnalysisContext context = getContext(resource);
        if (resource instanceof IFile) {
          Source source = getSource((IFile) resource);
          sources.add(source);
          changeSet.added(source);
        } else {
          sources = getSourcesIn(resource);
          for (Source source : sources) {
            changeSet.added(source);
          }
        }

        context.applyChanges(changeSet);
        for (Source source : sources) {
          AnalysisErrorInfo errorInfo = context.getErrors(source);
          if (errorInfo.getErrors().length > 0) {
            AnalysisMarkerManager.getInstance().queueErrors(
                getResource(source),
                errorInfo.getLineInfo(),
                errorInfo.getErrors());
          }
          new AnalysisWorker(getProject(resource.getProject()), context).performAnalysisInBackground();
        }
      }
    }
  }
}
