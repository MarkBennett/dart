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
package com.google.dart.eclipse.ui.internal.jobs;

import org.eclipse.osgi.util.NLS;

/**
 *
 */
public class UIJobMessages extends NLS {
  private static final String BUNDLE_NAME = "com.google.dart.eclipse.ui.internal.jobs.UIJobMessages"; //$NON-NLS-1$
  public static String ValidateSDKJob_name;
  public static String ValidateSDKJob_missing_sdk_popup_title;
  public static String ValidateSDKJob_missing_sdk_desc;
  static {
    // initialize resource bundle
    NLS.initializeMessages(BUNDLE_NAME, UIJobMessages.class);
  }

  private UIJobMessages() {
  }
}
