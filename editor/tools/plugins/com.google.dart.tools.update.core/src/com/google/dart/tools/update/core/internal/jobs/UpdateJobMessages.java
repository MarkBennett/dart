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
package com.google.dart.tools.update.core.internal.jobs;

import org.eclipse.osgi.util.NLS;

/**
 * Update Job Messages.
 */
public class UpdateJobMessages extends NLS {
  private static final String BUNDLE_NAME = "com.google.dart.tools.update.core.internal.jobs.UpdateJobMessages"; //$NON-NLS-1$
  public static String CheckForUpdatesJob_job_label;
  public static String CleanupInstallationJob_label;
  public static String DownloadUpdatesJob_editor_rev_label;
  public static String DownloadUpdatesJob_job_label;
  public static String DownloadUpdatesJob_progress_label;
  public static String InstallUpdateAction_bad_zip_dialog_cancel;
  public static String InstallUpdateAction_bad_zip_dialog_msg;
  public static String InstallUpdateAction_bad_zip_dialog_title;
  public static String InstallUpdateAction_bad_zip_retry_confirm;
  public static String InstallUpdateAction_cleanup_task;
  public static String InstallUpdateAction_confirm_save_msg;
  public static String InstallUpdateAction_confirm_save_title;
  public static String InstallUpdateAction_error_in_save;
  public static String InstallUpdateAction_errorMessage;
  public static String InstallUpdateAction_errorTitle;
  public static String InstallUpdateAction_extract_task;
  public static String InstallUpdateAction_install_task;
  public static String InstallUpdateAction_preparing_task;
  public static String InstallUpdateAction_progress_mon_title;
  static {
    // initialize resource bundle
    NLS.initializeMessages(BUNDLE_NAME, UpdateJobMessages.class);
  }

  private UpdateJobMessages() {
  }
}
