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
package com.google.dart.indexer.pagedstorage.filesystem;

import com.google.dart.indexer.pagedstorage.util.FileUtils;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * This class is extends a java.io.RandomAccessFile.
 */
public class DiskFileObject extends RandomAccessFile implements FileObject {
  private final String name;

  DiskFileObject(String fileName, String mode) throws FileNotFoundException {
    super(fileName, mode);
    this.name = fileName;
  }

  @Override
  public String getName() {
    return name;
  }

  @Override
  public void setFileLength(long newLength) throws IOException {
    FileUtils.setLength(this, newLength);
  }

  @Override
  public void sync() throws IOException {
    getFD().sync();
  }
}
