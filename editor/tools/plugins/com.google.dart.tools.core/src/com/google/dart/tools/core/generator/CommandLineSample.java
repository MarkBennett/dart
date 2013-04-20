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

package com.google.dart.tools.core.generator;

import java.util.ArrayList;
import java.util.List;

/**
 * Create a simple command-line Dart application.
 */
public class CommandLineSample extends AbstractSample {

  public CommandLineSample() {
    super("Command-line application", "Create a simple command-line Dart application");

    List<String[]> templates = new ArrayList<String[]>();

    templates.add(new String[] {
        "pubspec.yaml",
        "name: {name}\ndescription: A sample command-line application\n#dependencies:\n#  unittest: any\n"});

    templates.add(new String[] {
        "bin/{name.lower}.dart", "void main() {\n  print(\"Hello, World!\");\n}\n"});

    setTemplates(templates);
    setMainFile("bin/{name.lower}.dart");
  }

}
