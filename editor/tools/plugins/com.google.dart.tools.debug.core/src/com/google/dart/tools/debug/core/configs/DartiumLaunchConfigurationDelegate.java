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
package com.google.dart.tools.debug.core.configs;

import com.google.dart.engine.utilities.instrumentation.InstrumentationBuilder;
import com.google.dart.tools.core.DartCoreDebug;
import com.google.dart.tools.debug.core.DartDebugCorePlugin;
import com.google.dart.tools.debug.core.DartLaunchConfigWrapper;
import com.google.dart.tools.debug.core.DartLaunchConfigurationDelegate;
import com.google.dart.tools.debug.core.util.BrowserManager;
import com.google.dart.tools.debug.core.util.IRemoteConnectionDelegate;
import com.google.dart.tools.debug.core.webkit.DefaultChromiumTabChooser;
import com.google.dart.tools.debug.core.webkit.IChromiumTabChooser;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.debug.core.ILaunch;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchManager;
import org.eclipse.debug.core.model.IDebugTarget;

import java.util.concurrent.Semaphore;

/**
 * The launch configuration delegate for the com.google.dart.tools.debug.core.dartiumLaunchConfig
 * launch config.
 */
public class DartiumLaunchConfigurationDelegate extends DartLaunchConfigurationDelegate implements
    IRemoteConnectionDelegate {
  private static Semaphore launchSemaphore = new Semaphore(1);

  private IChromiumTabChooser tabChooser;

  /**
   * Create a new DartChromiumLaunchConfigurationDelegate.
   */
  public DartiumLaunchConfigurationDelegate() {
    this(new DefaultChromiumTabChooser());
  }

  public DartiumLaunchConfigurationDelegate(IChromiumTabChooser tabChooser) {
    this.tabChooser = tabChooser;
  }

  @Override
  public void doLaunch(ILaunchConfiguration configuration, String mode, ILaunch launch,
      IProgressMonitor monitor, InstrumentationBuilder instrumentation) throws CoreException {

    if (!ILaunchManager.RUN_MODE.equals(mode) && !ILaunchManager.DEBUG_MODE.equals(mode)) {
      throw new CoreException(DartDebugCorePlugin.createErrorStatus("Execution mode '" + mode
          + "' is not supported."));
    }

    DartLaunchConfigWrapper launchConfig = new DartLaunchConfigWrapper(configuration);

    // If we're in the process of launching Dartium, don't allow a second launch to occur.
    if (launchSemaphore.tryAcquire()) {
      try {
        launchImpl(launchConfig, mode, launch, monitor);
      } finally {
        launchSemaphore.release();
      }
    }
  }

  @Override
  public IDebugTarget performRemoteConnection(String host, int port, IProgressMonitor monitor)
      throws CoreException {
    BrowserManager browserManager = new BrowserManager();

    return browserManager.performRemoteConnection(tabChooser, host, port, monitor);
  }

  private void launchImpl(DartLaunchConfigWrapper launchConfig, String mode, ILaunch launch,
      IProgressMonitor monitor) throws CoreException {
    launchConfig.markAsLaunched();

    boolean enableDebugging = ILaunchManager.DEBUG_MODE.equals(mode)
        && !DartCoreDebug.DISABLE_DARTIUM_DEBUGGER;

    // Launch the browser - show errors if we couldn't.
    IResource resource = null;
    String url;

    if (launchConfig.getShouldLaunchFile()) {
      resource = launchConfig.getApplicationResource();
      if (resource == null) {
        throw new CoreException(new Status(
            IStatus.ERROR,
            DartDebugCorePlugin.PLUGIN_ID,
            "HTML file could not be found"));
      }
      url = resource.getLocationURI().toString();
    } else {
      url = launchConfig.getUrl();
    }

    BrowserManager manager = BrowserManager.getManager();

    if (resource instanceof IFile) {
      manager.launchBrowser(launch, launchConfig, (IFile) resource, monitor, enableDebugging);
    } else {
      manager.launchBrowser(launch, launchConfig, url, monitor, enableDebugging);
    }
  }

}
