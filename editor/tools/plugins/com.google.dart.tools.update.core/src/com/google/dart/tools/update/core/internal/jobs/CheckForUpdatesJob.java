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

import com.google.dart.tools.update.core.Revision;
import com.google.dart.tools.update.core.UpdateCore;
import com.google.dart.tools.update.core.internal.DownloadManager;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;

import java.io.IOException;
import java.net.UnknownHostException;

/**
 * A job that checks for updates.
 */
public class CheckForUpdatesJob extends Job {

  private final DownloadManager downloadManager;
  private Revision latest;
  private String message;

  /**
   * Create an instance.
   * 
   * @param downloadManager the download manager
   */
  public CheckForUpdatesJob(DownloadManager downloadManager) {
    super(UpdateJobMessages.CheckForUpdatesJob_job_label);
    this.downloadManager = downloadManager;
  }

  /**
   * Get details in case an error occurred during check for updates.
   * 
   * @return the message a displayable error message (or <code>null</code> if none was recorded)
   */
  public String getErrorMessage() {
    return message;
  }

  /**
   * Get the latest available update.
   * 
   * @return the latest update, or <code>null</code> if it has not been retrieved yet
   */
  public Revision getLatest() {
    return latest;
  }

  @Override
  protected IStatus run(IProgressMonitor monitor) {
    try {
      latest = downloadManager.getLatestRevision();
    } catch (UnknownHostException e) {
      // These exceptions are expected when the user is off-line; we don't need to log them.

    } catch (IOException e) {
      message = "Unable to get latest revision"; //$NON-NLS-1$
      UpdateCore.logError(message + " : " + e.toString()); //$NON-NLS-1$
    }

    return Status.OK_STATUS;
  }
}
