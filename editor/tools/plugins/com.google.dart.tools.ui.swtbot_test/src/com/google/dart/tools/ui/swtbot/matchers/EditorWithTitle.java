/*
 * Copyright 2012 Dart project authors.
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
package com.google.dart.tools.ui.swtbot.matchers;

import org.eclipse.ui.IEditorReference;
import org.hamcrest.BaseMatcher;
import org.hamcrest.Description;

import java.util.regex.Pattern;

/**
 * Matches an editor that has a title matching the specified regular expression.
 */
public class EditorWithTitle extends BaseMatcher<IEditorReference> {
  private final String regex;
  private final Pattern pattern;

  public EditorWithTitle(String regex) {
    if (regex == null || regex.length() == 0) {
      throw new IllegalArgumentException();
    }
    this.regex = regex;
    this.pattern = Pattern.compile(regex);
  }

  @Override
  public void describeTo(Description description) {
    description.appendText("editor with title matching ").appendText(regex);
  }

  @Override
  public boolean matches(Object item) {
    if (item instanceof IEditorReference) {
      String title = ((IEditorReference) item).getTitle();
      if (title != null) {
        return pattern.matcher(title).matches();
      }
    }
    return false;
  }
}
