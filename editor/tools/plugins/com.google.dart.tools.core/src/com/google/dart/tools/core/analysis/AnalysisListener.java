/*
 * Copyright 2012 Dart project authors.
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
package com.google.dart.tools.core.analysis;

/**
 * Notified when analysis is performed
 * 
 * @see AnalysisServer#addIdleListener(AnalysisListener)
 * @see AnalysisServer#removeIdleListener(AnalysisListener)
 */
public interface AnalysisListener {

  /**
   * Called when the server is no longer analyzing a library
   */
  void discarded(AnalysisEvent event);

  /**
   * Called after files are parsed regardless of whether there were errors.
   */
  void parsed(AnalysisEvent event);

  /**
   * Called after a library has been resolved regardless of whether there were errors.
   */
  void resolved(AnalysisEvent event);
}
