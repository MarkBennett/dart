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
package com.google.dart.tools.ui.internal.text.dart;

import com.google.dart.core.ILocalVariable;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.core.model.Field;
import com.google.dart.tools.core.model.Method;
import com.google.dart.tools.core.model.Type;
import com.google.dart.tools.ui.DartElementImageDescriptor;
import com.google.dart.tools.ui.DartPluginImages;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.internal.util.StringMatcher;
import com.google.dart.tools.ui.internal.viewsupport.DartElementImageProvider;
import com.google.dart.tools.ui.text.dart.PositionBasedCompletionProposal;
import com.google.dart.tools.ui.text.editor.tmp.Signature;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.swt.graphics.Image;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * This class triggers a code-completion that will track all local and member variables for later
 * use as a parameter guessing proposal.
 */
public class ParameterGuesser {

  private static class MatchComparator implements Comparator<Variable> {

    private String fParamName;

    MatchComparator(String paramName) {
      fParamName = paramName;
    }

    @Override
    public int compare(Variable one, Variable two) {
      return score(two) - score(one);
    }

    /**
     * The four order criteria as described below - put already used into bit 10, all others into
     * bits 0-9, 11-20, 21-30; 31 is sign - always 0
     * 
     * @param v the variable
     * @return the score for <code>v</code>
     */
    private int score(Variable v) {
      int variableScore = 100 - v.variableType; // since these are increasing with distance
      int subStringScore = getLongestCommonSubstring(v.name, fParamName).length();
      // substring scores under 60% are not considered
      // this prevents marginal matches like a - ba and false - isBool that will
      // destroy the sort order
      int shorter = Math.min(v.name.length(), fParamName.length());
      if (subStringScore < 0.6 * shorter) {
        subStringScore = 0;
      }

      int positionScore = v.positionScore; // since ???
      int matchedScore = v.alreadyMatched ? 0 : 1;
      int autoboxingScore = v.isAutoboxingMatch ? 0 : 1;

      int score = autoboxingScore << 30 | variableScore << 21 | subStringScore << 11
          | matchedScore << 10 | positionScore;
      return score;
    }

  }

  private final static class Variable {

    /**
     * Variable type. Used to choose the best guess based on scope (Local beats instance beats
     * inherited).
     */
    public static final int LOCAL = 0;
    public static final int FIELD = 1;
    public static final int INHERITED_FIELD = 2;
    public static final int METHOD = 3;
    public static final int INHERITED_METHOD = 4;
    public static final int LITERALS = 5;

    public final String qualifiedTypeName;
    public final String name;
    public final int variableType;
    public final int positionScore;

    public final boolean isAutoboxingMatch;

    public final char[] triggerChars;
    public final ImageDescriptor descriptor;

    public boolean alreadyMatched;

    public Variable(String qualifiedTypeName, String name, int variableType,
        boolean isAutoboxMatch, int positionScore, char[] triggerChars, ImageDescriptor descriptor) {
      this.qualifiedTypeName = qualifiedTypeName;
      this.name = name;
      this.variableType = variableType;
      this.positionScore = positionScore;
      this.triggerChars = triggerChars;
      this.descriptor = descriptor;
      this.isAutoboxingMatch = isAutoboxMatch;
      this.alreadyMatched = false;
    }

    @Override
    public String toString() {

      StringBuffer buffer = new StringBuffer();
      buffer.append(qualifiedTypeName);
      buffer.append(' ');
      buffer.append(name);
      buffer.append(" ("); //$NON-NLS-1$
      buffer.append(variableType);
      buffer.append(')');

      return buffer.toString();
    }
  }

  private static final char[] NO_TRIGGERS = new char[0];

  /**
   * Returns the longest common substring of two strings.
   * 
   * @param first the first string
   * @param second the second string
   * @return the longest common substring
   */
  private static String getLongestCommonSubstring(String first, String second) {

    String shorter = (first.length() <= second.length()) ? first : second;
    String longer = shorter == first ? second : first;

    int minLength = shorter.length();

    StringBuffer pattern = new StringBuffer(shorter.length() + 2);
    String longestCommonSubstring = ""; //$NON-NLS-1$

    for (int i = 0; i < minLength; i++) {
      for (int j = i + 1; j <= minLength; j++) {
        if (j - i < longestCommonSubstring.length()) {
          continue;
        }

        String substring = shorter.substring(i, j);
        pattern.setLength(0);
        pattern.append('*');
        pattern.append(substring);
        pattern.append('*');

        StringMatcher matcher = new StringMatcher(pattern.toString(), true, false);
        if (matcher.match(longer)) {
          longestCommonSubstring = substring;
        }
      }
    }

    return longestCommonSubstring;
  }

  /**
   * Determine the best match of all possible type matches. The input into this method is all
   * possible completions that match the type of the argument. The purpose of this method is to
   * choose among them based on the following simple rules: 1) Local Variables > Instance/Class
   * Variables > Inherited Instance/Class Variables 2) A longer case insensitive substring match
   * will prevail 3) Variables that have not been used already during this completion will prevail
   * over those that have already been used (this avoids the same String/int/char from being passed
   * in for multiple arguments) 4) A better source position score will prevail (the declaration
   * point of the variable, or "how close to the point of completion?"
   * 
   * @param typeMatches the list of type matches
   * @param paramName the parameter name
   */
  private static void orderMatches(List<Variable> typeMatches, String paramName) {
    if (typeMatches != null) {
      Collections.sort(typeMatches, new MatchComparator(paramName));
    }
  }

  private final Set<String> fAlreadyMatchedNames;

  private final DartElement fEnclosingElement;

  /**
   * Creates a parameter guesser
   * 
   * @param enclosingElement the enclosing Java element
   */
  public ParameterGuesser(DartElement enclosingElement) {
    fEnclosingElement = enclosingElement;
    fAlreadyMatchedNames = new HashSet<String>();
  }

  public Variable createVariable(DartElement element, Type enclosingType, String expectedType,
      int positionScore) throws DartModelException {
    int variableType;
    int elementType = element.getElementType();
    String elementName = element.getElementName();

    String typeSignature;
    switch (elementType) {
      case DartElement.FIELD: {
        Field field = (Field) element;
        if (field.getDeclaringType().equals(enclosingType)) {
          variableType = Variable.FIELD;
        } else {
          variableType = Variable.INHERITED_FIELD;
        }
        typeSignature = field.getTypeName();
        break;
      }
      case DartElement.VARIABLE: {
        ILocalVariable locVar = (ILocalVariable) element;
        variableType = Variable.LOCAL;
        typeSignature = locVar.getTypeSignature();
        break;
      }
      case DartElement.METHOD: {
        Method method = (Method) element;
        if (isMethodToSuggest(method)) {
          if (method.getDeclaringType().equals(enclosingType)) {
            variableType = Variable.METHOD;
          } else {
            variableType = Variable.INHERITED_METHOD;
          }
          typeSignature = method.getReturnTypeName();
          elementName = elementName + "()"; //$NON-NLS-1$
        } else {
          return null;
        }
        break;
      }
      default:
        return null;
    }
    String type = Signature.toString(typeSignature);

    boolean isAutoboxMatch = isLiteralType(expectedType) != isLiteralType(type);
    return new Variable(
        type,
        elementName,
        variableType,
        isAutoboxMatch,
        positionScore,
        NO_TRIGGERS,
        getImageDescriptor(element));
  }

  /**
   * Returns the matches for the type and name argument, ordered by match quality.
   * 
   * @param expectedType - the qualified type of the parameter we are trying to match
   * @param paramName - the name of the parameter (used to find similarly named matches)
   * @param pos the position
   * @param suggestions the suggestions or <code>null</code>
   * @param fillBestGuess <code>true</code> if the best guess should be filled in
   * @return returns the name of the best match, or <code>null</code> if no match found
   * @throws DartModelException if it fails
   */
  public ICompletionProposal[] parameterProposals(String expectedType, String paramName,
      Position pos, DartElement[] suggestions, boolean fillBestGuess) throws DartModelException {
    List<Variable> typeMatches = evaluateVisibleMatches(expectedType, suggestions);
    orderMatches(typeMatches, paramName);

    boolean hasVarWithParamName = false;
    ICompletionProposal[] ret = new ICompletionProposal[typeMatches.size()];
    int i = 0;
    int replacementLength = 0;
    for (Iterator<Variable> it = typeMatches.iterator(); it.hasNext();) {
      Variable v = it.next();
      if (i == 0) {
        fAlreadyMatchedNames.add(v.name);
        replacementLength = v.name.length();
      }

      String displayString = v.name;
      hasVarWithParamName |= displayString.equals(paramName);

      final char[] triggers = new char[v.triggerChars.length + 1];
      System.arraycopy(v.triggerChars, 0, triggers, 0, v.triggerChars.length);
      triggers[triggers.length - 1] = ',';

      ret[i++] = new PositionBasedCompletionProposal(
          v.name,
          pos,
          replacementLength,
          getImage(v.descriptor),
          displayString,
          null,
          null,
          triggers);
    }
    if (!fillBestGuess && !hasVarWithParamName) {
      // insert a proposal with the argument name
      ICompletionProposal[] extended = new ICompletionProposal[ret.length + 1];
      System.arraycopy(ret, 0, extended, 1, ret.length);
      extended[0] = new PositionBasedCompletionProposal(
          paramName,
          pos,
          replacementLength,
          null,
          paramName,
          null,
          null,
          NO_TRIGGERS);
      return extended;
    }
    return ret;
  }

  private List<Variable> evaluateVisibleMatches(String expectedType, DartElement[] suggestions)
      throws DartModelException {
    Type currentType = null;
    if (fEnclosingElement != null) {
      currentType = fEnclosingElement.getAncestor(Type.class);
    }

    ArrayList<Variable> res = new ArrayList<Variable>();
    for (int i = 0; i < suggestions.length; i++) {
      Variable variable = createVariable(suggestions[i], currentType, expectedType, i);
      if (variable != null) {
        if (fAlreadyMatchedNames.contains(variable.name)) {
          variable.alreadyMatched = true;
        }
        res.add(variable);
      }
    }

    // add 'this'
    if (currentType != null
        && !(fEnclosingElement instanceof Method && ((Method) fEnclosingElement).isStatic())) {
      @SuppressWarnings("deprecation")
      String fullyQualifiedName = currentType.getTypeQualifiedName('.');
      if (fullyQualifiedName.equals(expectedType)) {
        ImageDescriptor desc = new DartElementImageDescriptor(
            DartPluginImages.DESC_FIELD_PUBLIC,
            DartElementImageDescriptor.FINAL | DartElementImageDescriptor.STATIC,
            DartElementImageProvider.SMALL_SIZE);
        res.add(new Variable(
            fullyQualifiedName,
            "this", Variable.LITERALS, false, res.size(), new char[] {'.'}, desc)); //$NON-NLS-1$
      }
    }

    String literalTypeCode = getLiteralTypeCode(expectedType);
    if (literalTypeCode == null) {
      // add 'null'
      res.add(new Variable(
          expectedType,
          "null", Variable.LITERALS, false, res.size(), NO_TRIGGERS, null)); //$NON-NLS-1$
    } else {
      String typeName = literalTypeCode;
      boolean isAutoboxing = false;
      if (literalTypeCode.equals("bool")) {
        // add 'true', 'false'
        res.add(new Variable(
            typeName,
            "true", Variable.LITERALS, isAutoboxing, res.size(), NO_TRIGGERS, null)); //$NON-NLS-1$
        res.add(new Variable(
            typeName,
            "false", Variable.LITERALS, isAutoboxing, res.size(), NO_TRIGGERS, null)); //$NON-NLS-1$
      } else if (literalTypeCode.equals("int")) {
        // add 0
        res.add(new Variable(
            typeName,
            "0", Variable.LITERALS, isAutoboxing, res.size(), NO_TRIGGERS, null)); //$NON-NLS-1$
      } else if (literalTypeCode.equals("double")) {
        // add 0.0
        res.add(new Variable(
            typeName,
            "0.0", Variable.LITERALS, isAutoboxing, res.size(), NO_TRIGGERS, null)); //$NON-NLS-1$
      } else if (literalTypeCode.equals("num")) {
        // add 0
        res.add(new Variable(
            typeName,
            "0", Variable.LITERALS, isAutoboxing, res.size(), NO_TRIGGERS, null)); //$NON-NLS-1$
      }
    }
    return res;
  }

  private Image getImage(ImageDescriptor descriptor) {
    return (descriptor == null) ? null : DartToolsPlugin.getImageDescriptorRegistry().get(
        descriptor);
  }

  private ImageDescriptor getImageDescriptor(DartElement elem) {
    DartElementImageProvider imageProvider = new DartElementImageProvider();
    ImageDescriptor desc = imageProvider.getBaseImageDescriptor(
        elem,
        DartElementImageProvider.OVERLAY_ICONS);
    imageProvider.dispose();
    return desc;
  }

  private String getLiteralTypeCode(String type) {
    if (type.equals("bool")) {
      return type;
    } else if (type.equals("int")) {
      return type;
    } else if (type.equals("double")) {
      return type;
    } else if (type.equals("num")) {
      return type;
    } else {
      return null;
    }
  }

  private boolean isLiteralType(String type) {
    return getLiteralTypeCode(type) != null;
  }

  private boolean isMethodToSuggest(Method method) {
    try {
      String methodName = method.getElementName();
      return method.getParameterNames().length == 0 && !"void".equals(method.getReturnTypeName()) //$NON-NLS-1$
          && (method.isGetter() || methodName.startsWith("is")); //$NON-NLS-1$
    } catch (DartModelException e) {
      return false;
    }
  }
}
