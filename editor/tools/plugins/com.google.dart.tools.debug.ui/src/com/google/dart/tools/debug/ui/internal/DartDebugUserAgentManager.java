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

package com.google.dart.tools.debug.ui.internal;

import com.google.dart.tools.debug.core.DartDebugCorePlugin;
import com.google.dart.tools.debug.core.IUserAgentManager;

import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.PlatformUI;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.List;

/**
 * A class to let the user to choose which user agents are allowed to connect to the embedded
 * server.
 */
public class DartDebugUserAgentManager implements IUserAgentManager {

  private static class AgentData {
    String address;
    String agentName;
    boolean allowed;
  }

  static void install() {
    DartDebugCorePlugin.getPlugin().setUserAgentManager(new DartDebugUserAgentManager());
  }

  private List<AgentData> agents = new ArrayList<AgentData>();

  private DartDebugUserAgentManager() {
    loadSettings();
  }

  @Override
  public boolean allowUserAgent(InetAddress remoteAddress, String agentName) {
    // check if it's an existing agent
    if (agentAllowed(remoteAddress, agentName)) {
      return true;
    }

    // ask the user
    if (askUserAllows(remoteAddress, agentName)) {
      AgentData data = new AgentData();

      data.address = remoteAddress.getHostAddress();
      data.agentName = agentName;
      data.allowed = true;

      agents.add(data);

      saveSettings();

      return true;
    }

    return false;
  }

  private boolean agentAllowed(InetAddress remoteAddress, String agent) {
    if (agent == null) {
      return false;
    }

    String address = remoteAddress.getHostAddress();

    for (AgentData data : agents) {
      if (address.equals(data.address) && agent.equals(data.agentName)) {
        return data.allowed;
      }
    }

    return false;
  }

  private boolean askUserAllows(final InetAddress remoteAddress, final String agent) {
    final boolean[] result = new boolean[1];

    Display.getDefault().syncExec(new Runnable() {
      @Override
      public void run() {
        Shell shell = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell();

        // Move the app to the foreground. Otherwise the dialog can be missed.
        shell.forceActive();

        result[0] = MessageDialog.openConfirm(
            shell,
            "Allow Remote Device Connection",
            "Allow a remote device from " + remoteAddress.getHostAddress()
                + " to connect to and run your Dart applications?\n\n" + agent);
      }
    });

    return result[0];
  }

  private File getDataFile() {
    return DartDebugUIPlugin.getDefault().getStateLocation().append("agentdata.txt").toFile();
  }

  private void loadSettings() {
    File file = getDataFile();

    if (file.exists()) {
      try {
        BufferedReader reader = new BufferedReader(new FileReader(file));

        String line = reader.readLine();

        while (line != null) {
          AgentData agent = new AgentData();

          agent.address = line;
          agent.agentName = reader.readLine();
          agent.allowed = Boolean.valueOf(reader.readLine());

          agents.add(agent);

          line = reader.readLine();
        }
      } catch (IOException ioe) {
        DartUtil.logError(ioe);
      }
    }
  }

  private void saveSettings() {
    File file = getDataFile();

    try {
      PrintWriter out = new PrintWriter(new FileWriter(file));

      for (AgentData data : agents) {
        out.println(data.address);
        out.println(data.agentName);
        out.println(data.allowed);
      }

      out.close();
    } catch (IOException ioe) {
      DartUtil.logError(ioe);
    }
  }

}
