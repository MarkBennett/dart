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
package com.google.dart.command.analyze;

import com.google.dart.engine.error.ErrorSeverity;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/**
 * Provides a framework to read command line options from stdin and feed them to a callback.
 */
class BatchRunner {

  public interface BatchRunnerInvocation {
    public ErrorSeverity invoke(String[] args) throws Throwable;
  }

  /**
   * Run the tool in 'batch' mode, receiving command lines through stdin and returning pass/fail
   * status through stdout. This feature is intended for use in unit testing.
   * 
   * @param batchArgs command line arguments forwarded from main().
   */
  public static ErrorSeverity runAsBatch(String[] batchArgs, BatchRunnerInvocation toolInvocation)
      throws Throwable {
    System.out.println(">>> BATCH START");

    // Read command lines in from stdin and create a new compiler for each one.
    BufferedReader cmdlineReader = new BufferedReader(new InputStreamReader(System.in));
    long startTime = System.currentTimeMillis();
    int testsFailed = 0;
    int totalTests = 0;
    ErrorSeverity batchResult = ErrorSeverity.NONE;
    String line;
    for (; (line = cmdlineReader.readLine()) != null; totalTests++) {
      long testStart = System.currentTimeMillis();
      String[] args = line.trim().split("\\s+");
      try {
        ErrorSeverity result = toolInvocation.invoke(args);
        boolean resultPass = !result.equals(ErrorSeverity.ERROR);
        if (!resultPass) {
          testsFailed++;
        }
        batchResult = batchResult.max(result);
        // Write stderr end token and flush.
        System.err.println(">>> EOF STDERR");
        System.err.flush();
        System.out.println(">>> TEST " + (resultPass ? "PASS" : "FAIL") + " "
            + (System.currentTimeMillis() - testStart) + "ms");
        System.out.flush();
      } catch (Throwable e) {
        e.printStackTrace();
        System.err.println(">>> EOF STDERR");
        System.err.flush();
        System.out.println(">>> TEST CRASH");
        System.out.flush();
      }
    }

    long elapsed = System.currentTimeMillis() - startTime;
    System.out.println(">>> BATCH END (" + (totalTests - testsFailed) + "/" + totalTests + ") "
        + elapsed + "ms");
    System.out.flush();
    return batchResult;
  }
}
