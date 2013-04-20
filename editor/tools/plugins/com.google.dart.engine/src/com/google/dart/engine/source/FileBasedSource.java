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
package com.google.dart.engine.source;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.net.URI;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;

/**
 * Instances of the class {@code FileBasedSource} implement a source that represents a file.
 * 
 * @coverage dart.engine.source
 */
public class FileBasedSource implements Source {
  /**
   * The content cache used to access the contents of this source if they have been overridden from
   * what is on disk or cached.
   */
  private final ContentCache contentCache;

  /**
   * The file represented by this source.
   */
  private final File file;

  /**
   * The cached URI of the {@link #file}.
   */
  private final String fileUriString;

  /**
   * A flag indicating whether this source is in one of the system libraries.
   */
  private final boolean inSystemLibrary;

  /**
   * The character set used to decode bytes into characters.
   */
  private static final Charset UTF_8_CHARSET = Charset.forName("UTF-8");

  /**
   * Initialize a newly created source object. The source object is assumed to not be in a system
   * library.
   * 
   * @param contentCache the content cache used to access the contents of this source
   * @param file the file represented by this source
   */
  public FileBasedSource(ContentCache contentCache, File file) {
    this(contentCache, file, false);
  }

  /**
   * Initialize a newly created source object.
   * 
   * @param contentCache the content cache used to access the contents of this source
   * @param file the file represented by this source
   * @param inSystemLibrary {@code true} if this source is in one of the system libraries
   */
  public FileBasedSource(ContentCache contentCache, File file, boolean inSystemLibrary) {
    this.contentCache = contentCache;
    this.file = file;
    this.inSystemLibrary = inSystemLibrary;
    this.fileUriString = file.toURI().toString();
  }

  @Override
  public boolean equals(Object object) {
    return object != null && this.getClass() == object.getClass()
        && file.equals(((FileBasedSource) object).file);
  }

  @Override
  public boolean exists() {
    return contentCache.getContents(this) != null || (file.exists() && !file.isDirectory());
  }

  @Override
  public void getContents(ContentReceiver receiver) throws Exception {
    //
    // First check to see whether our factory has an override for our contents.
    //
    String contents = contentCache.getContents(this);
    if (contents != null) {
      receiver.accept(contents, contentCache.getModificationStamp(this));
      return;
    }
    //
    // If not, read the contents from the file.
    //
    long modificationTime = this.file.lastModified();
    RandomAccessFile file = new RandomAccessFile(this.file, "r");
    FileChannel channel = null;
    ByteBuffer byteBuffer = null;
    try {
      channel = file.getChannel();
      long size = channel.size();
      if (size > Integer.MAX_VALUE) {
        throw new IllegalStateException("File is too long to be read");
      }
      int length = (int) size;
      byte[] bytes = new byte[length];
      byteBuffer = ByteBuffer.wrap(bytes);
      byteBuffer.position(0);
      byteBuffer.limit(length);
      channel.read(byteBuffer);
    } finally {
      if (channel != null) {
        try {
          channel.close();
        } catch (IOException exception) {
          // Ignored
        }
      }
    }
    byteBuffer.rewind();
    receiver.accept(UTF_8_CHARSET.decode(byteBuffer), modificationTime);
  }

  @Override
  public String getEncoding() {
    return fileUriString;
  }

  @Override
  public String getFullName() {
    return file.getAbsolutePath();
  }

  @Override
  public long getModificationStamp() {
    Long stamp = contentCache.getModificationStamp(this);
    if (stamp != null) {
      return stamp.longValue();
    }
    return file.lastModified();
  }

  @Override
  public String getShortName() {
    return file.getName();
  }

  @Override
  public int hashCode() {
    return file.hashCode();
  }

  @Override
  public boolean isInSystemLibrary() {
    return inSystemLibrary;
  }

  @Override
  public Source resolveRelative(URI containedUri) {
    try {
      URI resolvedUri = getFile().toURI().resolve(containedUri).normalize();
      return new FileBasedSource(contentCache, new File(resolvedUri), isInSystemLibrary());
    } catch (Exception exception) {
      // Fall through to return null
    }
    return null;
  }

  @Override
  public String toString() {
    if (file == null) {
      return "<unknown source>";
    }
    return file.getAbsolutePath();
  }

  /**
   * Return the file represented by this source. This is an internal method that is only intended to
   * be used by {@link UriResolver}.
   * 
   * @return the file represented by this source
   */
  File getFile() {
    return file;
  }
}
