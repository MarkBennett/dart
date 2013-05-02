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
package com.google.dart.tools.core.analysis.model;

import com.google.dart.engine.context.AnalysisContext;
import com.google.dart.engine.element.LibraryElement;
import com.google.dart.engine.sdk.DartSdk;
import com.google.dart.engine.source.Source;
import com.google.dart.engine.source.SourceKind;
import com.google.dart.tools.core.internal.builder.AnalysisWorker;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;

/**
 * Instances of {@code ContextManager} manage and provide access to multiple instances of
 * {@link AnalysisContext}.
 */
public interface ContextManager {

  /**
   * Add the given {@link AnalysisWorker} to the context's list of active workers.
   * 
   * @param worker the analysis worker
   */
  void addWorker(AnalysisWorker worker);

  /**
   * Answer the {@link AnalysisContext} used to analyze the specified resource.
   * 
   * @param resource a resource (not {@code null})
   * @return the context used for analysis or {@code null} if the context was not cached and could
   *         not be created because the container's location could not be determined
   */
  AnalysisContext getContext(IResource resource);

  /**
   * Answer with all the library sources that can be launched on the browser
   * 
   * @return library sources that can be launched on the browser
   */
  Source[] getLaunchableClientLibrarySources();

  /**
   * Answer with all the library sources that can be launched on the VM
   * 
   * @return library sources that can be launched on the VM
   */
  Source[] getLaunchableServerLibrarySources();

  /**
   * Answer the LibraryElement associated with the specified file
   * 
   * @param file the file (not {@code null})
   * @return the {@link LibraryElement} associated with the file or {@code null} if it could not be
   *         determined because the location is {@code null}
   */
  LibraryElement getLibraryElement(IFile file);

  /**
   * Answer the LibraryElement associated with the specified file
   * 
   * @return the {@link LibraryElement} or {@code null} if file has not been resolved yet or the
   *         location is {@code null}
   */
  LibraryElement getLibraryElementOrNull(IFile file);

  /**
   * Answer the {@link PubFolder} containing the specified resource.
   * 
   * @param resource the resource (not {@code null})
   * @return the pub folder or {@code null} if no pub folder contains this resource
   */
  PubFolder getPubFolder(IResource resource);

  /**
   * Answer the resource associated with the specified source.
   * 
   * @param source the source
   * @return the resource or {@code null} if it could not be determined
   */
  IResource getResource(Source source);

  /**
   * Answer the bi-directional map for translating between sources and resources for the specified
   * analysis context.
   * 
   * @param context the analysis context (not {@code null})
   * @return the resource map (not {@code null})
   */
  ResourceMap getResourceMap(AnalysisContext context);

  /**
   * Answer the bi-directional map for translating between sources and resources for the specified
   * resource.
   * 
   * @param resource the resource (not {@code null})
   * @return the resource map (not {@code null})
   */
  ResourceMap getResourceMap(IResource resource);

  /**
   * Answer the {@link DartSdk} associated with this manager.
   * 
   * @return the sdk (not {@code null})
   */
  DartSdk getSdk();

  /**
   * Answer the context containing analysis of sources in the SDK.
   * 
   * @return the context (not {@code null})
   */
  AnalysisContext getSdkContext();

  /**
   * Answer the source for the specified file
   * 
   * @param file the file (not {@code null})
   * @return the source or {@code null} if the source could not be determned because the location is
   *         {@code null}
   */
  Source getSource(IFile file);

  /**
   * Answer the source kind for the given file.
   * 
   * @return the {@link SourceKind} of the given file, may be {@link SourceKind#UNKNOWN} if not
   *         analyzed yet.
   */
  SourceKind getSourceKind(IFile file);

  /**
   * Answer the context's list of active workers.
   * 
   * @return the list (not {@code null}, contains no {@code null}s)
   */
  AnalysisWorker[] getWorkers();

  /**
   * Remove the {@link AnalysisWorker} from the project's active workers list.
   * 
   * @param analysisWorker
   */
  void removeWorker(AnalysisWorker analysisWorker);

  /**
   * Stop workers for the specified context.
   * 
   * @param context the context
   */
  void stopWorkers(AnalysisContext context);
}
