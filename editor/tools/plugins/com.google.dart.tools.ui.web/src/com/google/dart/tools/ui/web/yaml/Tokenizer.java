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
package com.google.dart.tools.ui.web.yaml;

import com.google.dart.tools.ui.web.utils.Token;
import com.google.dart.tools.ui.web.utils.WhitespaceDetector;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.rules.EndOfLineRule;
import org.eclipse.jface.text.rules.IRule;
import org.eclipse.jface.text.rules.IToken;
import org.eclipse.jface.text.rules.RuleBasedScanner;
import org.eclipse.jface.text.rules.WhitespaceRule;

import java.io.CharArrayWriter;
import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Stack;

/**
 * Convert yaml content into series of tokens
 */
public class Tokenizer implements Iterator<Token> {
  private static IDocument createDocument(Reader in) throws IOException {
    String content = readContent(in);

    return new Document(content);
  }

  private static String readContent(Reader in) throws IOException {
    CharArrayWriter out = new CharArrayWriter();
    char[] buffer = new char[4096];

    int count = in.read(buffer);

    while (count != -1) {
      out.write(buffer, 0, count);
      count = in.read(buffer);
    }

    in.close();

    return out.toString();
  }

  private RuleBasedScanner scanner;

  private IDocument document;

  private Stack<Token> tokenStack = new Stack<Token>();

  public Tokenizer(IDocument document, String[] comments) {
    this.document = document;

    setupScanner(document, comments);
  }

  public Tokenizer(Reader reader, String[] comments) throws IOException {
    this(createDocument(reader), comments);
  }

  @Override
  public boolean hasNext() {
    if (!tokenStack.isEmpty()) {
      return true;
    }

    if (scanner == null) {
      return false;
    }

    advance();

    return !tokenStack.isEmpty();
  }

  @Override
  public Token next() {
    if (!tokenStack.isEmpty()) {
      return tokenStack.pop();
    }

    advance();

    if (tokenStack.isEmpty()) {
      throw new NoSuchElementException();
    } else {
      return tokenStack.pop();
    }
  }

  public void pushBack(Token token) {
    tokenStack.push(token);
  }

  @Override
  public void remove() {
    throw new UnsupportedOperationException();
  }

  private void advance() {
    if (scanner != null && tokenStack.isEmpty()) {
      IToken t = scanner.nextToken();

      if (t.isEOF()) {
        scanner = null;
      } else {
        try {
          tokenStack.push(new Token(
              document.get(scanner.getTokenOffset(), scanner.getTokenLength()),
              scanner.getTokenOffset(),
              t.isWhitespace()));
        } catch (BadLocationException e) {
          throw new RuntimeException(e);
        }
      }
    }
  }

  private void setupScanner(IDocument document, String[] comments) {
    IToken commentToken = new org.eclipse.jface.text.rules.Token(YamlPartitionScanner.YAML_COMMENT);

    scanner = new RuleBasedScanner();

    List<IRule> rules = new ArrayList<IRule>();

    rules.add(new EndOfLineRule(comments[0], commentToken));
    rules.add(new WhitespaceRule(new WhitespaceDetector()));

    scanner.setRules(rules.toArray(new IRule[rules.size()]));
    scanner.setRange(document, 0, document.getLength());
  }

}
