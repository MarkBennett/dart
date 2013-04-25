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
package com.google.dart.tools.ui.internal.text.correction;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.google.dart.compiler.DartCompilerErrorCode;
import com.google.dart.compiler.ErrorCode;
import com.google.dart.compiler.PackageLibraryManager;
import com.google.dart.compiler.Source;
import com.google.dart.compiler.ast.ASTNodes;
import com.google.dart.compiler.ast.DartBinaryExpression;
import com.google.dart.compiler.ast.DartClass;
import com.google.dart.compiler.ast.DartClassMember;
import com.google.dart.compiler.ast.DartDirective;
import com.google.dart.compiler.ast.DartExpression;
import com.google.dart.compiler.ast.DartIdentifier;
import com.google.dart.compiler.ast.DartImportDirective;
import com.google.dart.compiler.ast.DartInvocation;
import com.google.dart.compiler.ast.DartLibraryDirective;
import com.google.dart.compiler.ast.DartMethodInvocation;
import com.google.dart.compiler.ast.DartNewExpression;
import com.google.dart.compiler.ast.DartNode;
import com.google.dart.compiler.ast.DartParenthesizedExpression;
import com.google.dart.compiler.ast.DartPropertyAccess;
import com.google.dart.compiler.ast.DartSourceDirective;
import com.google.dart.compiler.ast.DartTypeNode;
import com.google.dart.compiler.ast.DartUnit;
import com.google.dart.compiler.ast.DartUnqualifiedInvocation;
import com.google.dart.compiler.ast.DartVariable;
import com.google.dart.compiler.common.SourceInfo;
import com.google.dart.compiler.resolver.ClassElement;
import com.google.dart.compiler.resolver.Element;
import com.google.dart.compiler.resolver.ElementKind;
import com.google.dart.compiler.resolver.Elements;
import com.google.dart.compiler.resolver.LibraryElement;
import com.google.dart.compiler.resolver.MethodElement;
import com.google.dart.compiler.resolver.ResolverErrorCode;
import com.google.dart.compiler.resolver.TypeErrorCode;
import com.google.dart.compiler.type.InterfaceType;
import com.google.dart.compiler.type.Type;
import com.google.dart.compiler.type.TypeKind;
import com.google.dart.compiler.util.apache.StringUtils;
import com.google.dart.engine.utilities.source.SourceRange;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.dom.StructuralPropertyDescriptor;
import com.google.dart.tools.core.dom.rewrite.TrackedNodePosition;
import com.google.dart.tools.core.internal.model.PackageLibraryManagerProvider;
import com.google.dart.tools.core.internal.util.ResourceUtil;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartImport;
import com.google.dart.tools.core.model.DartLibrary;
import com.google.dart.tools.core.model.DartModel;
import com.google.dart.tools.core.model.DartProject;
import com.google.dart.tools.core.refactoring.CompilationUnitChange;
import com.google.dart.tools.core.utilities.general.SourceRangeFactory;
import com.google.dart.tools.internal.corext.codemanipulation.StubUtility;
import com.google.dart.tools.internal.corext.refactoring.code.ExtractUtils;
import com.google.dart.tools.internal.corext.refactoring.code.ExtractUtils.TopInsertDesc;
import com.google.dart.tools.internal.corext.refactoring.util.ExecutionUtils;
import com.google.dart.tools.internal.corext.refactoring.util.Messages;
import com.google.dart.tools.internal.corext.refactoring.util.RunnableEx;
import com.google.dart.tools.ui.DartElementImageDescriptor;
import com.google.dart.tools.ui.DartPluginImages;
import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.DartUI;
import com.google.dart.tools.ui.ISharedImages;
import com.google.dart.tools.ui.internal.cleanup.migration.Migrate_1M1_library_CleanUp;
import com.google.dart.tools.ui.internal.text.correction.proposals.CUCorrectionProposal_OLD;
import com.google.dart.tools.ui.internal.text.correction.proposals.CreateFileCorrectionProposal_OLD;
import com.google.dart.tools.ui.internal.text.correction.proposals.LinkedCorrectionProposal_OLD;
import com.google.dart.tools.ui.internal.text.correction.proposals.SourceBuilder;
import com.google.dart.tools.ui.internal.text.correction.proposals.TrackedNodeProposal;
import com.google.dart.tools.ui.internal.viewsupport.DartElementImageProvider;
import com.google.dart.tools.ui.text.dart.IDartCompletionProposal;
import com.google.dart.tools.ui.text.dart.IInvocationContext;
import com.google.dart.tools.ui.text.dart.IProblemLocation;
import com.google.dart.tools.ui.text.dart.IQuickFixProcessor;

import static com.google.dart.tools.core.dom.PropertyDescriptorHelper.DART_METHOD_INVOCATION_FUNCTION_NAME;
import static com.google.dart.tools.core.dom.PropertyDescriptorHelper.DART_METHOD_INVOCATION_TARGET;
import static com.google.dart.tools.core.dom.PropertyDescriptorHelper.DART_VARIABLE_VALUE;
import static com.google.dart.tools.core.dom.PropertyDescriptorHelper.getLocationInParent;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.ltk.core.refactoring.TextFileChange;
import org.eclipse.swt.graphics.Image;
import org.eclipse.text.edits.MultiTextEdit;
import org.eclipse.text.edits.ReplaceEdit;
import org.eclipse.text.edits.TextEdit;

import java.net.URI;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

/**
 * Standard {@link IQuickFixProcessor} for Dart.
 * <p>
 * Method {@link #getCorrections()} calls corresponding "addFix_" methods for each supported
 * {@link ErrorCode}. These methods may throw any {@link Exception}, we don't try to recover from
 * them, instead we just silently ignore them. No dialog for user.
 * 
 * @coverage dart.editor.ui.correction
 */
public class QuickFixProcessor_OLD implements IQuickFixProcessor {
  /**
   * Helper for finding {@link Element} with name closest to the given.
   */
  private static class ClosestElementFinder {
    private final Class<?> targetClass;
    private final String targetName;
    Element element = null;
    int distance = Integer.MAX_VALUE;

    public ClosestElementFinder(Class<?> targetClass, String targetName) {
      this.targetClass = targetClass;
      this.targetName = targetName;
    }

    void update(Element member) {
      if (targetClass.isInstance(member)) {
        int memberDistance = StringUtils.getLevenshteinDistance(member.getName(), targetName);
        if (memberDistance < distance) {
          element = member;
          distance = memberDistance;
        }
      }
    }

    void update(Iterable<? extends Element> members) {
      for (Element member : members) {
        update(member);
      }
    }
  }

  private static final int DEFAULT_RELEVANCE = 50;
  private static final DartElementImageDescriptor OBJ_CONSTRUCTOR_DESC = new DartElementImageDescriptor(
      DartPluginImages.DESC_MISC_PUBLIC,
      DartElementImageDescriptor.CONSTRUCTOR,
      DartElementImageProvider.SMALL_SIZE);

  private static final Image OBJ_CONSTRUCTOR_IMG = DartToolsPlugin.getImageDescriptorRegistry().get(
      OBJ_CONSTRUCTOR_DESC);

  private static void addSuperTypeProposals(SourceBuilder sb, Set<Type> alreadyAdded, Type type) {
    if (type != null && !alreadyAdded.contains(type) && type.getElement() instanceof ClassElement) {
      alreadyAdded.add(type);
      ClassElement element = (ClassElement) type.getElement();
      sb.addProposal(
          DartUI.getSharedImages().getImage(ISharedImages.IMG_OBJS_CLASS),
          element.getName());
      addSuperTypeProposals(sb, alreadyAdded, element.getSupertype());
      for (InterfaceType interfaceType : element.getInterfaces()) {
        addSuperTypeProposals(sb, alreadyAdded, interfaceType);
      }
    }
  }

//  private static ReplaceEdit createInsertEdit(int offset, String text) {
//    return new ReplaceEdit(offset, 0, text);
//  }

  private static ReplaceEdit createRemoveEdit(SourceRange range) {
    return createReplaceEdit(range, "");
  }

  private static ReplaceEdit createReplaceEdit(SourceRange range, String text) {
    return new ReplaceEdit(range.getOffset(), range.getLength(), text);
  }

  /**
   * @return the suggestions for given {@link Type} and {@link DartExpression}, not empty.
   */
  private static String[] getArgumentNameSuggestions(Set<String> excluded, Type type,
      DartExpression expression, int index) {
    String[] suggestions = StubUtility.getVariableNameSuggestions(type, expression, excluded);
    if (suggestions.length != 0) {
      return suggestions;
    }
    return new String[] {"arg" + index};
  }

  /**
   * @param node the expression of some {@link Type} or {@link DartTypeNode}.
   * @return the {@link Element} of the type of given node.
   */
  private static Element getTypeElement(DartNode node) {
    if (node.getType() != null) {
      return node.getType().getElement();
    }
    return node.getElement();
  }

  /**
   * @return <code>true</code> if given {@link DartNode} could be type name.
   */
  private static boolean mayBeTypeIdentifier(DartNode node) {
    if (node instanceof DartIdentifier) {
      return node.getParent() instanceof DartTypeNode
          || getLocationInParent(node) == DART_METHOD_INVOCATION_TARGET;
    }
    return false;
  }

  private CompilationUnit unit;
  private ExtractUtils utils;

  private DartNode node;
  private final List<ICommandAccess> proposals = Lists.newArrayList();
  private int proposalRelevance = DEFAULT_RELEVANCE;
  private final List<TextEdit> textEdits = Lists.newArrayList();
  private final Map<String, List<TrackedNodePosition>> linkedPositions = Maps.newHashMap();
  private final Map<String, List<TrackedNodeProposal>> linkedPositionProposals = Maps.newHashMap();
  private LinkedCorrectionProposal_OLD proposal;

  @Override
  public IDartCompletionProposal[] getCorrections(IInvocationContext context,
      IProblemLocation[] locations) throws CoreException {
    if (context.getContext() != null) {
      return new IDartCompletionProposal[0];
    }
    proposals.clear();
    unit = context.getOldCompilationUnit();
    utils = new ExtractUtils(unit, context.getOldASTRoot());
    for (final IProblemLocation location : locations) {
      resetProposalElements();
      final ErrorCode errorCode = location.getProblemId();
      // proposals without node
      ExecutionUtils.runIgnore(new RunnableEx() {
        @Override
        public void run() throws Exception {
          if (errorCode == DartCompilerErrorCode.MISSING_PART_OF_DIRECTIVE) {
            addFix_addPartOf();
          }
        }
      });
      // prepare and use node
      node = location.getCoveringNode(utils.getUnitNode());
      if (node != null) {
        ExecutionUtils.runIgnore(new RunnableEx() {
          @Override
          public void run() throws Exception {
            if (errorCode == ResolverErrorCode.CANNOT_RESOLVE_METHOD
                || errorCode == ResolverErrorCode.CANNOT_RESOLVE_METHOD_IN_CLASS
                || errorCode == TypeErrorCode.INTERFACE_HAS_NO_METHOD_NAMED) {
              addFix_unresolvedMethodSimilar(location);
              addFix_unresolvedMethodCreate(location);
            }
            if (errorCode == TypeErrorCode.IS_STATIC_METHOD_IN) {
              addFix_useStaticAccess_method(location);
            }
            if (errorCode == TypeErrorCode.NO_SUCH_TYPE
                || errorCode == TypeErrorCode.CANNOT_BE_RESOLVED) {
              addFix_importLibrary_withType(location);
              addFix_unresolvedClass_useSimilar(location);
              addFix_unresolvedClass_create(location);
            }
            if (errorCode == ResolverErrorCode.CANNOT_RESOLVE_METHOD) {
              addFix_importLibrary_withFunction(location);
            }
            if (errorCode == ResolverErrorCode.CANNOT_BE_RESOLVED
                || errorCode == TypeErrorCode.CANNOT_BE_RESOLVED) {
              addFix_importLibrary_withField(location);
            }
            if (errorCode == TypeErrorCode.NEW_EXPRESSION_NOT_CONSTRUCTOR) {
              addFix_createConstructor();
            }
            if (errorCode == TypeErrorCode.USE_INTEGER_DIVISION) {
              addFix_useEffectiveIntegerDivision(location);
            }
            if (errorCode == TypeErrorCode.NOT_A_FUNCTION_TYPE_FIELD) {
              addFix_removeParentheses_inGetterInvocation();
            }
            if (errorCode == DartCompilerErrorCode.MISSING_SOURCE) {
              addFix_createMissingPart();
            }
          }

        });
      }
    }
    return proposals.toArray(new IDartCompletionProposal[proposals.size()]);
  }

  @Override
  public boolean hasCorrections(CompilationUnit unit, ErrorCode errorCode) {
    return errorCode == ResolverErrorCode.CANNOT_BE_RESOLVED
        || errorCode == TypeErrorCode.CANNOT_BE_RESOLVED
        || errorCode == ResolverErrorCode.CANNOT_RESOLVE_METHOD
        || errorCode == ResolverErrorCode.CANNOT_RESOLVE_METHOD_IN_CLASS
        || errorCode == TypeErrorCode.INTERFACE_HAS_NO_METHOD_NAMED
        || errorCode == TypeErrorCode.IS_STATIC_METHOD_IN
        || errorCode == TypeErrorCode.NO_SUCH_TYPE
        || errorCode == TypeErrorCode.NEW_EXPRESSION_NOT_CONSTRUCTOR
        || errorCode == TypeErrorCode.USE_INTEGER_DIVISION
        || errorCode == TypeErrorCode.NOT_A_FUNCTION_TYPE_FIELD
        || errorCode == DartCompilerErrorCode.MISSING_PART_OF_DIRECTIVE
        || errorCode == DartCompilerErrorCode.MISSING_SOURCE;
  }

  private void addFix_addPartOf() throws Exception {
    TextEdit textEdit = Migrate_1M1_library_CleanUp.createEditInsertPartOf(utils);
    if (textEdit != null) {
      textEdits.add(textEdit);
      // add proposal
      addUnitCorrectionProposal(
          CorrectionMessages.QuickFixProcessor_addPartOf,
          DartPluginImages.get(DartPluginImages.IMG_CORRECTION_CHANGE));
    }
  }

  private void addFix_createConstructor() {
    DartNewExpression newExpression = null;
    DartNode nameNode = null;
    String namePrefix = null;
    String name = null;
    // prepare "new X()"
    if (node instanceof DartIdentifier && node.getParent().getParent() instanceof DartNewExpression) {
      newExpression = (DartNewExpression) node.getParent().getParent();
      // default constructor
      if (node.getParent() instanceof DartTypeNode) {
        namePrefix = ((DartIdentifier) node).getName();
        name = "";
      }
      // named constructor
      if (node.getParent() instanceof DartPropertyAccess) {
        DartPropertyAccess constructorNameNode = (DartPropertyAccess) node.getParent();
        nameNode = constructorNameNode.getName();
        namePrefix = constructorNameNode.getQualifier().toSource() + ".";
        name = constructorNameNode.getName().getName();
      }
    }
    // prepare environment
    String eol = utils.getEndOfLine();
    String prefix = "  ";
    CompilationUnit targetUnit;
    SourceRange range;
    {
      ClassElement targetElement = (ClassElement) newExpression.getType().getElement();
      {
        SourceInfo targetSourceInfo = targetElement.getSourceInfo();
        Source targetSource = targetSourceInfo.getSource();
        IResource targetResource = ResourceUtil.getResource(targetSource);
        targetUnit = (CompilationUnit) DartCore.create(targetResource);
      }
      range = SourceRangeFactory.forStartLength(
          targetElement.getOpenBraceOffset() + "{".length(),
          0);
    }
    // build source
    SourceBuilder sb = new SourceBuilder(range);
    {
      sb.append(eol);
      sb.append(prefix);
      // append name
      {
        sb.append(namePrefix);
        if (name != null) {
          sb.startPosition("NAME");
          sb.append(name);
          sb.endPosition();
        }
      }
      addFix_unresolvedMethodCreate_parameters(sb, newExpression);
      sb.append(") {" + eol + prefix + "}");
      sb.append(eol);
    }
    // insert source
    addReplaceEdit(range, sb.toString());
    // add linked positions
    // TODO(scheglov) disabled, caused exception in old model, don't know why
//    if (Objects.equal(targetUnit, unit) && nameNode != null) {
//      addLinkedPosition("NAME", TrackedPositions.forNode(nameNode));
//    }
    addLinkedPositions(sb);
    // add proposal
    {
      String msg = Messages.format(
          CorrectionMessages.QuickFixProcessor_createConstructor,
          namePrefix + name);
      addUnitCorrectionProposal(targetUnit, TextFileChange.FORCE_SAVE, msg, OBJ_CONSTRUCTOR_IMG);
    }
  }

  private void addFix_createMissingPart() throws Exception {
    if (node instanceof DartSourceDirective) {
      DartSourceDirective directive = (DartSourceDirective) node;
      String uriString = directive.getSourceUri().getValue();
      URI uri = URI.create(uriString);
      if (uri.getScheme() == null) {
        IContainer unitContainer = unit.getResource().getParent();
        IFile newFile = unitContainer.getFile(new Path(uriString));
        if (!newFile.exists()) {
          // prepare new source
          String source;
          {
            String eol = utils.getEndOfLine();
            String libraryName = unit.getLibrary().getLibraryDirectiveName();
            libraryName = Migrate_1M1_library_CleanUp.mapLibraryName(libraryName);
            source = "part of " + libraryName + ";" + eol + eol;
          }
          // add proposal
          String label = "Create file \"" + newFile.getFullPath() + "\"";
          proposals.add(new CreateFileCorrectionProposal_OLD(proposalRelevance, label, newFile, source));
        }
      }
    }
  }

  private void addFix_importLibrary(String importPath) throws Exception {
    CompilationUnit libraryUnit = unit.getLibrary().getDefiningCompilationUnit();
    // prepare new import location
    SourceRange range;
    String prefix;
    String suffix;
    {
      String eol = utils.getEndOfLine();
      // if no directives
      range = SourceRangeFactory.forStartEnd(0, 0);
      prefix = "";
      suffix = eol;
      ExtractUtils libraryUtils = new ExtractUtils(libraryUnit);
      // after last directive in library
      for (DartDirective directive : libraryUtils.getUnitNode().getDirectives()) {
        if (directive instanceof DartLibraryDirective || directive instanceof DartImportDirective) {
          range = SourceRangeFactory.forEndLength(directive, 0);
          prefix = eol;
          suffix = "";
        }
      }
      // if still beginning of file, skip shebang and line comments
      if (range.getOffset() == 0) {
        TopInsertDesc desc = libraryUtils.getTopInsertDesc();
        range = SourceRangeFactory.forStartLength(desc.offset, 0);
        prefix = desc.insertEmptyLineBefore ? eol : "";
        suffix = eol + (desc.insertEmptyLineAfter ? eol : "");
      }
    }
    // insert new import
    String importSource = prefix + "import '" + importPath + "';" + suffix;
    addReplaceEdit(range, importSource);
    // add proposal
    proposalRelevance += 1;
    addUnitCorrectionProposal(
        libraryUnit,
        TextFileChange.FORCE_SAVE,
        Messages.format(CorrectionMessages.QuickFixProcessor_importLibrary, importPath),
        DartPluginImages.get(DartPluginImages.IMG_CORRECTION_CHANGE));
  }

  private void addFix_importLibrary_withElement(String name, int elementType) throws Exception {
    // ignore if private
    if (name.startsWith("_")) {
      return;
    }
    // add only unique libraries
    Set<DartLibrary> proposedLibraries = Sets.newHashSet();
    // prepare base URI
    CompilationUnit libraryUnit = unit.getLibrary().getDefiningCompilationUnit();
    URI unitNormalizedUri;
    {
      URI unitUri = libraryUnit.getUnderlyingResource().getLocationURI();
      unitNormalizedUri = unitUri.resolve(".").normalize();
    }
    // may be there is existing import, but it is with prefix and we don't use this prefix
    for (DartImport imp : unit.getLibrary().getImports()) {
      String prefix = imp.getPrefix();
      DartLibrary library = imp.getLibrary();
      DartElement foundElement = library.findTopLevelElement(name);
      if (!StringUtils.isEmpty(prefix) && foundElement != null
          && foundElement.getElementType() == elementType) {
        SourceRange range = SourceRangeFactory.forStartLength(node, 0);
        addReplaceEdit(range, prefix + ".");
        // add proposal
        proposalRelevance += 2;
        addUnitCorrectionProposal(
            libraryUnit,
            TextFileChange.FORCE_SAVE,
            Messages.format(
                CorrectionMessages.QuickFixProcessor_importLibrary_addPrefix,
                new Object[] {getSource(imp.getUriRange()), prefix}),
            DartPluginImages.get(DartPluginImages.IMG_CORRECTION_CHANGE));
        // remember as already proposed
        proposedLibraries.add(library);
      }
    }
    // prepare Dart model
    DartModel model = DartCore.create(ResourcesPlugin.getWorkspace().getRoot());
    // check workspace libraries
    for (DartProject project : model.getDartProjects()) {
      for (DartLibrary library : project.getDartLibraries()) {
        DartElement foundElement = library.findTopLevelElement(name);
        if (foundElement != null && foundElement.getElementType() == elementType) {
          if (!proposedLibraries.add(library)) {
            continue;
          }
          URI libraryUri = library.getUri();
          URI libraryRelativeUri = unitNormalizedUri.relativize(libraryUri);
          if (StringUtils.isEmpty(libraryRelativeUri.getScheme())) {
            String importPath = libraryRelativeUri.toString();
            addFix_importLibrary(importPath);
          }
        }
      }
    }
    // check SDK libraries
    PackageLibraryManager libraryManager = PackageLibraryManagerProvider.getPackageLibraryManager();
    for (DartLibrary library : model.getBundledLibraries()) {
      DartElement foundElement = library.findTopLevelElement(name);
      if (foundElement != null && foundElement.getElementType() == elementType) {
        if (!proposedLibraries.add(library)) {
          continue;
        }
        URI libraryUri = library.getUri();
        URI libraryShortUri = libraryManager.getShortUri(libraryUri);
        if (libraryShortUri != null) {
          String importPath = libraryShortUri.toString();
          addFix_importLibrary(importPath);
        }
      }
    }
  }

  private void addFix_importLibrary_withField(IProblemLocation location) throws Exception {
    if (node instanceof DartIdentifier) {
      String name = ((DartIdentifier) node).getName();
      addFix_importLibrary_withElement(name, DartElement.VARIABLE);
    }
  }

  private void addFix_importLibrary_withFunction(IProblemLocation location) throws Exception {
    if (node instanceof DartIdentifier
        && getLocationInParent(node) == DART_METHOD_INVOCATION_TARGET) {
      String name = ((DartIdentifier) node).getName();
      addFix_importLibrary_withElement(name, DartElement.FUNCTION);
    }
  }

  private void addFix_importLibrary_withType(IProblemLocation location) throws Exception {
    if (mayBeTypeIdentifier(node)) {
      String typeName = ((DartIdentifier) node).getName();
      addFix_importLibrary_withElement(typeName, DartElement.TYPE);
    }
  }

  private void addFix_removeParentheses_inGetterInvocation() throws Exception {
    if (getLocationInParent(node) == DART_METHOD_INVOCATION_FUNCTION_NAME) {
      DartNode invocation = node.getParent();
      addRemoveEdit(SourceRangeFactory.forEndEnd(node, invocation));
      // add proposal
      addUnitCorrectionProposal(
          CorrectionMessages.QuickFixProcessor_removeParentheses_inGetterInvocation,
          DartPluginImages.get(DartPluginImages.IMG_CORRECTION_CHANGE));
    }
  }

  private void addFix_unresolvedClass_create(IProblemLocation location) {
    if (mayBeTypeIdentifier(node)) {
      String name = ((DartIdentifier) node).getName();
      // prepare environment
      String eol = utils.getEndOfLine();
      DartClassMember<?> enclosingMember = ASTNodes.getAncestor(node, DartClassMember.class);
      String prefix = utils.getNodePrefix(enclosingMember);
      SourceRange range = SourceRangeFactory.forEndLength(enclosingMember, 0);
      //
      SourceBuilder sb = new SourceBuilder(range);
      {
        sb.append(eol + eol);
        sb.append(prefix);
        // "class"
        sb.append("class ");
        // append name
        {
          sb.startPosition("NAME");
          sb.append(name);
          sb.endPosition();
        }
        // no members
        sb.append(" {");
        sb.append(eol);
        sb.append("}");
      }
      // insert source
      addReplaceEdit(range, sb.toString());
      // add linked positions
      // TODO(scheglov) disabled, caused exception in old model, don't know why
//      addLinkedPosition("NAME", TrackedPositions.forNode(node));
      addLinkedPositions(sb);
      // add proposal
      addUnitCorrectionProposal(
          unit,
          TextFileChange.FORCE_SAVE,
          Messages.format(CorrectionMessages.QuickFixProcessor_createClass, name),
          DartPluginImages.get(DartPluginImages.IMG_OBJS_CLASS));
    }
  }

  private void addFix_unresolvedClass_useSimilar(IProblemLocation location) {
    if (mayBeTypeIdentifier(node)) {
      String name = ((DartIdentifier) node).getName();
      ClosestElementFinder finder = new ClosestElementFinder(ClassElement.class, name);
      // find closest element
      {
        DartUnit enclosingUnit = ASTNodes.getAncestor(node, DartUnit.class);
        LibraryElement enclosingLibrary = enclosingUnit.getLibrary().getElement();
        finder.update(enclosingLibrary.getImportScope().getElements().values());
        finder.update(enclosingLibrary.getScope().getElements().values());
      }
      // if we have close enough element, suggest to use it
      if (finder != null && finder.distance < 5) {
        String closestName = finder.element.getName();
        addReplaceEdit(SourceRangeFactory.create(node), closestName);
        // add proposal
        if (closestName != null) {
          proposalRelevance += 1;
          addUnitCorrectionProposal(
              Messages.format(CorrectionMessages.QuickFixProcessor_changeTo, closestName),
              DartPluginImages.get(DartPluginImages.IMG_CORRECTION_CHANGE));
        }
      }
    }
  }

  private void addFix_unresolvedMethodCreate(IProblemLocation location) throws Exception {
    if (node instanceof DartIdentifier && node.getParent() instanceof DartInvocation) {
      String name = ((DartIdentifier) node).getName();
      DartInvocation invocation = (DartInvocation) node.getParent();
      // prepare environment
      String eol = utils.getEndOfLine();
      CompilationUnit targetUnit;
      String prefix;
      SourceRange range;
      String sourcePrefix;
      String sourceSuffix;
      boolean staticModifier = false;
      if (invocation instanceof DartUnqualifiedInvocation) {
        targetUnit = unit;
        DartClassMember<?> enclosingMember = ASTNodes.getAncestor(node, DartClassMember.class);
        staticModifier = enclosingMember.getModifiers().isStatic();
        prefix = utils.getNodePrefix(enclosingMember);
        range = SourceRangeFactory.forEndLength(enclosingMember, 0);
        sourcePrefix = eol + eol;
        sourceSuffix = "";
      } else {
        SourceInfo targetSourceInfo;
        {
          DartExpression targetExpression = ((DartMethodInvocation) invocation).getRealTarget();
          staticModifier = ElementKind.of(targetExpression.getElement()) == ElementKind.CLASS;
          Element targetElement = getTypeElement(targetExpression);
          targetSourceInfo = targetElement.getSourceInfo();
          Source targetSource = targetSourceInfo.getSource();
          IResource targetResource = ResourceUtil.getResource(targetSource);
          targetUnit = (CompilationUnit) DartCore.create(targetResource);
        }
        prefix = "  ";
        range = SourceRangeFactory.forStartLength(targetSourceInfo.getEnd() - 1, 0);
        sourcePrefix = eol;
        sourceSuffix = eol;
      }
      //
      SourceBuilder sb = new SourceBuilder(range);
      {
        sb.append(sourcePrefix);
        sb.append(prefix);
        // may be "static"
        if (staticModifier) {
          sb.append("static ");
        }
        // may be return type
        {
          Type type = addFix_unresolvedMethodCreate_getReturnType(invocation);
          if (type != null) {
            sb.startPosition("RETURN_TYPE");
            sb.append(ExtractUtils.getTypeSource(type));
            sb.endPosition();
            sb.append(" ");
          }
        }
        // append name
        {
          sb.startPosition("NAME");
          sb.append(name);
          sb.endPosition();
        }
        addFix_unresolvedMethodCreate_parameters(sb, invocation);
        sb.append(") {" + eol + prefix + "}");
        sb.append(sourceSuffix);
      }
      // insert source
      addReplaceEdit(range, sb.toString());
      // add linked positions
      // TODO(scheglov) disabled, caused exception in old model, don't know why
//      if (Objects.equal(targetUnit, unit)) {
//        addLinkedPosition("NAME", TrackedPositions.forNode(node));
//      }
      addLinkedPositions(sb);
      // add proposal
      addUnitCorrectionProposal(
          targetUnit,
          TextFileChange.FORCE_SAVE,
          Messages.format(CorrectionMessages.QuickFixProcessor_createMethod, name),
          DartPluginImages.get(DartPluginImages.IMG_CORRECTION_CHANGE));
    }
  }

  /**
   * @return the possible return {@link Type}, may be <code>null</code> if can not be identified.
   *         {@link TypeKind#DYNAMIC} also returned as <code>null</code>.
   */
  private Type addFix_unresolvedMethodCreate_getReturnType(DartInvocation invocation) {
    Type type = null;
    StructuralPropertyDescriptor invocationLocation = getLocationInParent(invocation);
    if (invocationLocation == DART_VARIABLE_VALUE) {
      DartVariable variable = (DartVariable) invocation.getParent();
      type = variable.getElement().getType();
    }
    if (TypeKind.of(type) == TypeKind.DYNAMIC) {
      type = null;
    }
    return type;
  }

  private void addFix_unresolvedMethodCreate_parameters(SourceBuilder sb, DartInvocation invocation) {
    // append parameters
    sb.append("(");
    Set<String> excluded = Sets.newHashSet();
    List<DartExpression> arguments = invocation.getArguments();
    for (int i = 0; i < arguments.size(); i++) {
      DartExpression argument = arguments.get(i);
      // append separator
      if (i != 0) {
        sb.append(", ");
      }
      // append type name
      Type type = argument.getType();
      if (type != null) {
        String typeSource = ExtractUtils.getTypeSource(type);
        {
          sb.startPosition("TYPE" + i);
          sb.append(typeSource);
          addSuperTypeProposals(sb, Sets.<Type> newHashSet(), type);
          sb.endPosition();
        }
        sb.append(" ");
      }
      // append parameter name
      {
        String[] suggestions = getArgumentNameSuggestions(excluded, type, argument, i);
        String favorite = suggestions[0];
        excluded.add(favorite);
        sb.startPosition("ARG" + i);
        sb.append(favorite);
        sb.setProposals(suggestions);
        sb.endPosition();
      }
    }
  }

  private void addFix_unresolvedMethodSimilar(IProblemLocation location) throws Exception {
    if (node instanceof DartIdentifier && node.getParent() instanceof DartInvocation) {
      DartInvocation invocation = (DartInvocation) node.getParent();
      String name = ((DartIdentifier) node).getName();
      String closestName = null;
      ClosestElementFinder finder = new ClosestElementFinder(MethodElement.class, name);
      // unqualified invocation
      if (invocation instanceof DartUnqualifiedInvocation
          && ((DartUnqualifiedInvocation) invocation).getTarget() == node) {
        // may be invocation of method
        {
          DartClass enclosingClass = ASTNodes.getAncestor(invocation, DartClass.class);
          if (enclosingClass != null) {
            List<Element> allMembers = Elements.getAllMembers(enclosingClass.getElement());
            finder.update(allMembers);
          }
        }
        // may be invocation of top-level function
        {
          DartUnit enclosingUnit = ASTNodes.getAncestor(invocation, DartUnit.class);
          LibraryElement enclosingLibrary = enclosingUnit.getLibrary().getElement();
          finder.update(enclosingLibrary.getImportScope().getElements().values());
          finder.update(enclosingLibrary.getScope().getElements().values());
        }
      }
      // qualified invocation
      if (invocation instanceof DartMethodInvocation
          && ((DartMethodInvocation) invocation).getFunctionName() == node) {
        DartExpression targetExpression = ((DartMethodInvocation) invocation).getRealTarget();
        Element targetElement = getTypeElement(targetExpression);
        if (targetElement instanceof ClassElement) {
          ClassElement targetClassElement = (ClassElement) targetElement;
          List<Element> allMembers = Elements.getAllMembers(targetClassElement);
          finder.update(allMembers);
        }
      }
      // if we have close enough element, suggest to use it
      if (finder != null && finder.distance < 5) {
        closestName = finder.element.getName();
        addReplaceEdit(SourceRangeFactory.create(node), closestName);
      }
      // add proposal
      if (closestName != null) {
        proposalRelevance += 1;
        addUnitCorrectionProposal(
            Messages.format(CorrectionMessages.QuickFixProcessor_changeTo, closestName),
            DartPluginImages.get(DartPluginImages.IMG_CORRECTION_CHANGE));
      }
    }
  }

  private void addFix_useEffectiveIntegerDivision(IProblemLocation location) throws Exception {
    for (DartNode n = node; n != null; n = n.getParent()) {
      if (n instanceof DartMethodInvocation
          && n.getSourceInfo().getOffset() == location.getOffset()
          && n.getSourceInfo().getLength() == location.getLength()) {
        DartMethodInvocation invocation = (DartMethodInvocation) n;
        DartExpression target = invocation.getTarget();
        while (target instanceof DartParenthesizedExpression) {
          target = ((DartParenthesizedExpression) target).getExpression();
        }
        // replace "/" with "~/"
        DartBinaryExpression binary = (DartBinaryExpression) target;
        addReplaceEdit(
            SourceRangeFactory.forStartLength(binary.getOperatorOffset(), "/".length()),
            "~/");
        // remove everything before and after
        addRemoveEdit(SourceRangeFactory.forStartStart(invocation, binary.getArg1()));
        addRemoveEdit(SourceRangeFactory.forEndEnd(binary.getArg2(), invocation));
        // add proposal
        addUnitCorrectionProposal(
            CorrectionMessages.QuickFixProcessor_useEffectiveIntegerDivision,
            DartPluginImages.get(DartPluginImages.IMG_CORRECTION_CHANGE));
        // done
        break;
      }
    }
  }

  private void addFix_useStaticAccess_method(IProblemLocation location) throws Exception {
    if (getLocationInParent(node) == DART_METHOD_INVOCATION_FUNCTION_NAME) {
      DartMethodInvocation invocation = (DartMethodInvocation) node.getParent();
      Element methodElement = node.getElement();
      if (methodElement instanceof MethodElement
          && methodElement.getEnclosingElement() instanceof ClassElement) {
        ClassElement classElement = (ClassElement) methodElement.getEnclosingElement();
        String className = classElement.getName();
        // if has this class in current library, use name as is
        if (unit.getLibrary().findType(className) != null) {
          addFix_useStaticAccess_method_proposal(invocation, className);
          return;
        }
        // class from other library, may be use prefix
        for (DartImport imp : unit.getLibrary().getImports()) {
          if (imp.getLibrary().findType(className) != null) {
            className = imp.getPrefix() + "." + className;
            addFix_useStaticAccess_method_proposal(invocation, className);
          }
        }
      }
    }
  }

  private void addFix_useStaticAccess_method_proposal(DartMethodInvocation invocation,
      String className) {
    DartExpression target = invocation.getTarget();
    if (target == null) {
      return;
    }
    // replace "target" with class name
    SourceRange range = SourceRangeFactory.create(target);
    addReplaceEdit(range, className);
    // add proposal
    addUnitCorrectionProposal(
        Messages.format(CorrectionMessages.QuickFixProcessor_useStaticAccess_method, className),
        DartPluginImages.get(DartPluginImages.IMG_CORRECTION_CHANGE));
  }

//  private void addInsertEdit(int offset, String text) {
//    textEdits.add(createInsertEdit(offset, text));
//  }

  private void addLinkedPosition(String group, TrackedNodePosition position) {
    List<TrackedNodePosition> positions = linkedPositions.get(group);
    if (positions == null) {
      positions = Lists.newArrayList();
      linkedPositions.put(group, positions);
    }
    positions.add(position);
  }

  private void addLinkedPositionProposal(String group, Image icon, String text) {
    List<TrackedNodeProposal> nodeProposals = linkedPositionProposals.get(group);
    if (nodeProposals == null) {
      nodeProposals = Lists.newArrayList();
      linkedPositionProposals.put(group, nodeProposals);
    }
    nodeProposals.add(new TrackedNodeProposal(icon, text));
  }

  /**
   * Adds positions from the given {@link SourceBuilder} to the {@link #linkedPositions}.
   */
  private void addLinkedPositions(SourceBuilder builder) {
    // positions
    Map<String, List<TrackedNodePosition>> builderPositions = builder.getTrackedPositions();
    for (Entry<String, List<TrackedNodePosition>> entry : builderPositions.entrySet()) {
      String groupId = entry.getKey();
      for (TrackedNodePosition position : entry.getValue()) {
        addLinkedPosition(groupId, position);
      }
    }
    // proposals for positions
    Map<String, List<TrackedNodeProposal>> builderProposals = builder.getTrackedProposals();
    for (Entry<String, List<TrackedNodeProposal>> entry : builderProposals.entrySet()) {
      String groupId = entry.getKey();
      for (TrackedNodeProposal nodeProposal : entry.getValue()) {
        addLinkedPositionProposal(groupId, nodeProposal.getIcon(), nodeProposal.getText());
      }
    }
  }

  /**
   * Adds {@link #linkedPositions} to the current {@link #proposal}.
   */
  private void addLinkedPositionsToProposal() {
    // positions
    for (Entry<String, List<TrackedNodePosition>> entry : linkedPositions.entrySet()) {
      String groupId = entry.getKey();
      for (TrackedNodePosition position : entry.getValue()) {
        proposal.addLinkedPosition(position, false, groupId);
      }
    }
    // proposals for positions
    for (Entry<String, List<TrackedNodeProposal>> entry : linkedPositionProposals.entrySet()) {
      String groupId = entry.getKey();
      for (TrackedNodeProposal nodeProposal : entry.getValue()) {
        proposal.addLinkedPositionProposal(groupId, nodeProposal.getText(), nodeProposal.getIcon());
      }
    }
  }

  private void addRemoveEdit(SourceRange range) {
    textEdits.add(createRemoveEdit(range));
  }

  private void addReplaceEdit(SourceRange range, String text) {
    textEdits.add(createReplaceEdit(range, text));
  }

  /**
   * Adds new {@link CUCorrectionProposal_OLD} using given "unit" and {@link #textEdits}.
   */
  private void addUnitCorrectionProposal(CompilationUnit unit, int saveMode, String label,
      Image image) {
    // prepare change
    CompilationUnitChange change = new CompilationUnitChange(label, unit);
    change.setSaveMode(saveMode);
    change.setEdit(new MultiTextEdit());
    // add edits
    for (TextEdit textEdit : textEdits) {
      change.addEdit(textEdit);
    }
    // add proposal
    if (!textEdits.isEmpty()) {
      proposal = new LinkedCorrectionProposal_OLD(label, unit, change, proposalRelevance, image);
      addLinkedPositionsToProposal();
      proposals.add(proposal);
    }
    // done
    resetProposalElements();
  }

  /**
   * Adds new {@link CUCorrectionProposal_OLD} using {@link #unit} and {@link #textEdits}.
   */
  private void addUnitCorrectionProposal(String label, Image image) {
    addUnitCorrectionProposal(unit, TextFileChange.LEAVE_DIRTY, label, image);
  }

  /**
   * @return the part of {@link #unit} source.
   */
  private String getSource(int offset, int length) throws Exception {
    return unit.getBuffer().getText(offset, length);
  }

  /**
   * @return the part of {@link #unit} source.
   */
  private String getSource(SourceRange range) throws Exception {
    return getSource(range.getOffset(), range.getLength());
  }

  /**
   * Sets default values for fields used to create proposal in
   * {@link #addUnitCorrectionProposal(String, Image)}.
   */
  private void resetProposalElements() {
    textEdits.clear();
    linkedPositions.clear();
    linkedPositionProposals.clear();
    proposalRelevance = DEFAULT_RELEVANCE;
  }
}
