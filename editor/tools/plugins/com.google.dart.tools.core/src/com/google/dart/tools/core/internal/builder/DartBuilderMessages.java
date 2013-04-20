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

package com.google.dart.tools.core.internal.builder;

import org.eclipse.osgi.util.NLS;

/**
 * 
 */
public class DartBuilderMessages extends NLS {
  private static final String BUNDLE_NAME = "com.google.dart.tools.core.internal.builder.DartBuilderMessages"; //$NON-NLS-1$
  public static String DartBuilder_console_js_file_description;
  public static String DartBuilder_console_html_file_description;

  public static String CompileOptmized_title;
  public static String CompileOtimized_errorMessage;

  static {
    // initialize resource bundle
    NLS.initializeMessages(BUNDLE_NAME, DartBuilderMessages.class);
  }

  private DartBuilderMessages() {
  }
}
