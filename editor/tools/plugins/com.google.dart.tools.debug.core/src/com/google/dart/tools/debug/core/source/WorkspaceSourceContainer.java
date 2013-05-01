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

package com.google.dart.tools.debug.core.source;

import com.google.dart.tools.core.internal.util.ResourceUtil2;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.debug.core.DebugPlugin;
import org.eclipse.debug.core.sourcelookup.ISourceContainerType;
import org.eclipse.debug.core.sourcelookup.containers.AbstractSourceContainer;

import java.io.File;

/**
 * A source container that expects its input path to be a workspace relative path.
 */
public class WorkspaceSourceContainer extends AbstractSourceContainer {
  public static final String TYPE_ID = DebugPlugin.getUniqueIdentifier()
      + ".containerType.workspace"; //$NON-NLS-1$

  private static final Object[] EMPTY_COLLECTION = new Object[0];

  public static IFile locatePathAsFile(String path) {
    IResource resource = locatePathAsResource(path);

    if (resource instanceof IFile) {
      return (IFile) resource;
    } else {
      return null;
    }
  }

  public static IResource locatePathAsResource(String path) {
    if (path == null) {
      return null;
    }

    // Look for a resource reference (/project/directory/file.dart).
    IResource resource = ResourcesPlugin.getWorkspace().getRoot().findMember(path);

    if (resource != null) {
      return resource;
    }

    // Look for a file system reference.
    File file = new File(path);

    if (file.exists() && !file.isDirectory()) {
      IFile[] files = ResourcesPlugin.getWorkspace().getRoot().findFilesForLocationURI(file.toURI());

      if (files.length > 0) {
        return files[0];
      }

      // look for file among all resources, no filtering
      resource = ResourceUtil2.getFile(file);

      if (resource != null) {
        return resource;
      }
    }

    return null;
  }

  public WorkspaceSourceContainer() {

  }

  @Override
  public Object[] findSourceElements(String path) throws CoreException {
    IResource resource = locatePathAsResource(path);

    if (resource != null) {
      return new Object[] {resource};
    } else {
      return EMPTY_COLLECTION;
    }
  }

  @Override
  public String getName() {
    return "Workspace";
  }

  @Override
  public ISourceContainerType getType() {
    return getSourceContainerType(TYPE_ID);
  }

}
