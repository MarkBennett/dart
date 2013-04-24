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

import org.eclipse.core.resources.FileInfoMatcherDescription;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceFilterDescription;
import org.eclipse.core.resources.IResourceProxyVisitor;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;

import java.util.ArrayList;

public abstract class MockContainer extends MockResource implements IContainer {
  private ArrayList<MockResource> children;

  public MockContainer(IContainer parent, String name) {
    super(parent, name);
  }

  public MockContainer(IContainer parent, String name, boolean exists) {
    super(parent, name, exists);
  }

  @Override
  public void accept(IResourceProxyVisitor visitor, int memberFlags) throws CoreException {
    if (visitor.visit(new MockProxy(this))) {
      if (children != null) {
        for (MockResource child : children) {
          child.accept(visitor, memberFlags);
        }
      }
    }
  }

  @Override
  public void accept(IResourceVisitor visitor) throws CoreException {
    if (visitor.visit(this)) {
      if (children != null) {
        for (MockResource child : children) {
          child.accept(visitor);
        }
      }
    }
  }

  /**
   * Add the specified child to the receiver.
   * 
   * @param child the child to be added (not <code>null</code>)
   * @return the child added
   */
  public <R extends MockResource> R add(R child) {
    if (child == null) {
      throw new IllegalArgumentException();
    }
    if (children == null) {
      children = new ArrayList<MockResource>();
    }
    children.add(child);
    return child;
  }

  /**
   * Create a {@link MockFile} and add it to the receiver as a child
   */
  public MockFile addFile(String name) {
    return addFile(name, "");
  }

  /**
   * Create a {@link MockFile} with contents and add it to the receiver as a child
   */
  public MockFile addFile(String name, String contents) {
    return add(new MockFile(this, name, contents));
  }

  /**
   * Create a {@link MockFolder} and add it to the receiver as a child
   */
  public MockFolder addFolder(String name) {
    MockFolder folder = new MockFolder(this, name);
    add(folder);
    return folder;
  }

  @Override
  public IResourceFilterDescription createFilter(int type,
      FileInfoMatcherDescription matcherDescription, int updateFlags, IProgressMonitor monitor)
      throws CoreException {
    return null;
  }

  @Override
  public boolean exists(IPath path) {
    return false;
  }

  @Override
  public IFile[] findDeletedMembersWithHistory(int depth, IProgressMonitor monitor)
      throws CoreException {
    return null;
  }

  @Override
  public IResource findMember(IPath path) {
    return null;
  }

  @Override
  public IResource findMember(IPath path, boolean includePhantoms) {
    return null;
  }

  @Override
  public IResource findMember(String name) {
    for (IResource child : children) {
      if (child.getName().equals(name)) {
        return child;
      }
    }
    return null;
  }

  @Override
  public IResource findMember(String name, boolean includePhantoms) {
    return null;
  }

  @Override
  public String getDefaultCharset() throws CoreException {
    return null;
  }

  @Override
  public String getDefaultCharset(boolean checkImplicit) throws CoreException {
    return null;
  }

  /**
   * Answer an existing child resource with the specified name or {@code null} if none
   * 
   * @param name the name (not {@code null})
   * @return the child resource
   */
  public MockResource getExistingChild(String name) {
    if (children != null) {
      for (MockResource child : children) {
        if (child.getName().equals(name)) {
          return child;
        }
      }
    }
    return null;
  }

  @Override
  public IFile getFile(IPath path) {
    if (path == null || path.segmentCount() == 0) {
      return null;
    }
    String firstSegment = path.segment(0);
    MockResource child = getExistingChild(firstSegment);
    if (path.segmentCount() == 1) {
      if (child instanceof MockFile) {
        return (IFile) child;
      }
      return new MockFile(this, firstSegment, false);
    }
    MockContainer container = child != null && child instanceof MockContainer
        ? (MockContainer) child : new MockFolder(this, firstSegment, false);
    return container.getFile(path.removeFirstSegments(1));
  }

  @Override
  public IResourceFilterDescription[] getFilters() throws CoreException {
    return null;
  }

  @Override
  public IFolder getFolder(IPath path) {
    if (path == null || path.segmentCount() == 0) {
      return null;
    }
    String firstSegment = path.segment(0);
    MockResource child = getExistingChild(firstSegment);
    if (path.segmentCount() == 1) {
      if (child instanceof MockFolder) {
        return (IFolder) child;
      }
      return new MockFolder(this, firstSegment, false);
    }
    MockContainer container = child != null && child instanceof MockContainer
        ? (MockContainer) child : new MockFolder(this, firstSegment, false);
    return container.getFolder(path.removeFirstSegments(1));
  }

  public MockFile getMockFile(IPath path) {
    MockResource child = getExistingChild(path.segment(0));
    if (child == null) {
      throw new RuntimeException("Child named " + path.segment(0) + " not found in " + this);
    }
    if (path.segmentCount() == 1) {
      return (MockFile) child;
    }
    return ((MockContainer) child).getMockFile(path.removeFirstSegments(1));
  }

  public MockFile getMockFile(String path) {
    return getMockFile(new Path(path));
  }

  public MockFolder getMockFolder(IPath path) {
    MockResource child = getExistingChild(path.segment(0));
    if (child == null) {
      throw new RuntimeException("Child named " + path.segment(0) + " not found in " + this);
    }
    if (path.segmentCount() == 1) {
      return (MockFolder) child;
    }
    return ((MockContainer) child).getMockFolder(path.removeFirstSegments(1));
  }

  public MockFolder getMockFolder(String path) {
    return getMockFolder(new Path(path));
  }

  @Override
  public IResource[] members() throws CoreException {
    if (children == null) {
      return new IResource[] {};
    }
    return children.toArray(new IResource[children.size()]);
  }

  @Override
  public IResource[] members(boolean includePhantoms) throws CoreException {
    return null;
  }

  @Override
  public IResource[] members(int memberFlags) throws CoreException {
    return null;
  }

  public MockResource remove(IPath path) {
    MockResource child = getExistingChild(path.segment(0));
    if (child == null) {
      throw new RuntimeException("Not found: " + path.segment(0));
    }
    if (path.segmentCount() == 1) {
      children.remove(child);
      return child;
    } else {
      return ((MockContainer) child).remove(path.removeFirstSegments(1));
    }
  }

  public MockResource remove(String path) {
    return remove(new Path(path));
  }

  @Override
  public void setDefaultCharset(String charset) throws CoreException {
  }

  @Override
  public void setDefaultCharset(String charset, IProgressMonitor monitor) throws CoreException {
  }
}
