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
package com.google.dart.tools.core.internal.buffer;

import com.google.dart.tools.core.model.OpenableElement;

import org.eclipse.core.resources.IFile;

/**
 * Instances of the class <code>NullBuffer</code> represent a null buffer. This buffer is used to
 * represent a buffer for a file that has no source attached.
 */
public class NullBuffer extends FileBuffer {
  /**
   * Initialize a newly created null buffer on an underlying resource.
   */
  public NullBuffer(IFile file, OpenableElement owner, boolean readOnly) {
    super(file, owner, readOnly);
  }
}
