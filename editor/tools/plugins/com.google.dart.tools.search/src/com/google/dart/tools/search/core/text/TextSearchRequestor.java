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
package com.google.dart.tools.search.core.text;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;

import java.io.File;

/**
 * Collects the results from a search engine query. Clients implement a subclass to pass to
 * {@link TextSearchEngine#search(TextSearchScope, TextSearchRequestor, java.util.regex.Pattern, org.eclipse.core.runtime.IProgressMonitor)}
 * and implement the {@link #acceptPatternMatch(TextSearchMatchAccess)} method, and possibly
 * override other life cycle methods.
 * <p>
 * The search engine calls {@link #beginReporting()} when a search starts, then calls
 * {@link #acceptFile(IFile)} for a file visited. If {@link #acceptFile(IFile)} returns
 * <code>true</code> {@link #reportBinaryFile(IFile)} is called if the file could be binary followed
 * by {@link #acceptPatternMatch(TextSearchMatchAccess)} for each pattern match found in this file.
 * The end of the search is signaled with a call to {@link #endReporting()}. Note that
 * {@link #acceptFile(IFile)} is called for all files in the search scope, even if no match can be
 * found.
 * </p>
 * <p>
 * The order of the search results is unspecified and may vary from request to request; when
 * displaying results, clients should not rely on the order but should instead arrange the results
 * in an order that would be more meaningful to the user.
 * </p>
 * 
 * @see TextSearchEngine
 */
public abstract class TextSearchRequestor {

  /**
   * Notification sent before search starts in the given file. This method is called for all files
   * that are contained in the search scope. Implementors can decide if the file content should be
   * searched for search matches or not.
   * <p>
   * The default behaviour is to search the file for matches.
   * </p>
   * 
   * @param file the file resource to be searched.
   * @return If false, no pattern matches will be reported for the content of this file.
   * @throws CoreException implementors can throw a {@link CoreException} if accessing the resource
   *           fails or another problem prevented the processing of the search match.
   */
  public boolean acceptExternalFile(File file) throws CoreException {
    return true;
  }

  /**
   * Notification sent before search starts in the given file. This method is called for all files
   * that are contained in the search scope. Implementors can decide if the file content should be
   * searched for search matches or not.
   * <p>
   * The default behaviour is to search the file for matches.
   * </p>
   * 
   * @param file the file resource to be searched.
   * @return If false, no pattern matches will be reported for the content of this file.
   * @throws CoreException implementors can throw a {@link CoreException} if accessing the resource
   *           fails or another problem prevented the processing of the search match.
   */
  public boolean acceptFile(IFile file) throws CoreException {
    return true;
  }

  /**
   * Accepts the given search match and decides if the search should continue for this file.
   * 
   * @param matchAccess gives access to information of the match found. The matchAccess is not a
   *          value object. Its value might change after this method is finished, and the element
   *          might be reused.
   * @return If false is returned no further matches will be reported for this file.
   * @throws CoreException implementors can throw a {@link CoreException} if accessing the resource
   *           fails or another problem prevented the processing of the search match.
   */
  public boolean acceptPatternMatch(TextSearchMatchAccess matchAccess) throws CoreException {
    return true;
  }

  /**
   * Notification sent before starting the search action. Typically, this would tell a search
   * requestor to clear previously recorded search results.
   * <p>
   * The default implementation of this method does nothing. Subclasses may override.
   * </p>
   */
  public void beginReporting() {
    // do nothing
  }

  /**
   * Notification sent after having completed the search action. Typically, this would tell a search
   * requestor collector that no more results will be forthcoming in this search.
   * <p>
   * The default implementation of this method does nothing. Subclasses may override.
   * </p>
   */
  public void endReporting() {
    // do nothing
  }

  /**
   * Notification sent that a file might contain binary context. It is the choice of the search
   * engine to report binary files and it is the heuristic of the search engine to decide that a
   * file could be binary. Implementors can decide if the file content should be searched for search
   * matches or not.
   * <p>
   * This call is sent after calls {link {@link #acceptExternalFile(File)} that return
   * <code>true</code> and before any matches reported for this file with
   * {@link #acceptPatternMatch(TextSearchMatchAccess)}.
   * </p>
   * <p>
   * The default behaviour is to skip binary files
   * </p>
   * 
   * @param file the file that might be binary
   * @return If false, no pattern matches will be reported for the content of this file.
   */
  public boolean reportBinaryExternalFile(File file) {
    return false;
  }

  /**
   * Notification sent that a file might contain binary context. It is the choice of the search
   * engine to report binary files and it is the heuristic of the search engine to decide that a
   * file could be binary. Implementors can decide if the file content should be searched for search
   * matches or not.
   * <p>
   * This call is sent after calls {link {@link #acceptFile(IFile)} that return <code>true</code>
   * and before any matches reported for this file with
   * {@link #acceptPatternMatch(TextSearchMatchAccess)}.
   * </p>
   * <p>
   * The default behaviour is to skip binary files
   * </p>
   * 
   * @param file the file that might be binary
   * @return If false, no pattern matches will be reported for the content of this file.
   */
  public boolean reportBinaryFile(IFile file) {
    return false;
  }

}
