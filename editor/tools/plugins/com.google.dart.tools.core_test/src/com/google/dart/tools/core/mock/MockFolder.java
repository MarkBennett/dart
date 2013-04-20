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
package com.google.dart.tools.core.mock;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;

import java.net.URI;

public class MockFolder extends MockContainer implements IFolder {
  public MockFolder() {
    this(null, null);
  }

  public MockFolder(IContainer parent, String name) {
    super(parent, name);
  }

  public MockFolder(IContainer parent, String name, boolean exists) {
    super(parent, name, exists);
  }

  @Override
  public void create(boolean force, boolean local, IProgressMonitor monitor) throws CoreException {
  }

  @Override
  public void create(int updateFlags, boolean local, IProgressMonitor monitor) throws CoreException {
  }

  @Override
  public void createLink(IPath localLocation, int updateFlags, IProgressMonitor monitor)
      throws CoreException {
  }

  @Override
  public void createLink(URI location, int updateFlags, IProgressMonitor monitor)
      throws CoreException {
  }

  @Override
  public void delete(boolean force, boolean keepHistory, IProgressMonitor monitor)
      throws CoreException {
  }

  @Override
  public IFile getFile(String name) {
    return getFile(new Path(name));
  }

  @Override
  public IFolder getFolder(String name) {
    return getFolder(new Path(name));
  }

  @Override
  public int getType() {
    return IResource.FOLDER;
  }

  @Override
  public void move(IPath destination, boolean force, boolean keepHistory, IProgressMonitor monitor)
      throws CoreException {
  }
}
