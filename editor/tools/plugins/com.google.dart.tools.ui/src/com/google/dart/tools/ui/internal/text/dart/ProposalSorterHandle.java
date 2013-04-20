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

import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.Messages;
import com.google.dart.tools.ui.text.dart.AbstractProposalSorter;
import com.google.dart.tools.ui.text.dart.ContentAssistInvocationContext;

import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.InvalidRegistryObjectException;
import org.eclipse.core.runtime.PerformanceStats;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.Status;
import org.osgi.framework.Bundle;

import java.util.Collections;
import java.util.List;

/**
 * The description of an extension to the
 * <code>com.google.dart.tools.ui.javaCompletionProposalSorters</code> extension point. Instances
 * are immutable.
 */
public final class ProposalSorterHandle {
  /** The extension schema name of the id attribute. */
  private static final String ID = "id"; //$NON-NLS-1$
  /** The extension schema name of the name attribute. */
  private static final String NAME = "name"; //$NON-NLS-1$
  /** The extension schema name of the class attribute. */
  private static final String CLASS = "class"; //$NON-NLS-1$
  /** The extension schema name of the activate attribute. */
  private static final String ACTIVATE = "activate"; //$NON-NLS-1$
  /** The name of the performance event used to trace extensions. */
  private static final String PERFORMANCE_EVENT = DartToolsPlugin.getPluginId()
      + "/perf/content_assist_sorters/extensions"; //$NON-NLS-1$
  /**
   * If <code>true</code>, execution time of extensions is measured and extensions may be disabled
   * if execution takes too long.
   */
  private static final boolean MEASURE_PERFORMANCE = PerformanceStats.isEnabled(PERFORMANCE_EVENT);
  /** The one and only operation name. */
  private static final String SORT = "sort"; //$NON-NLS-1$

  /** The identifier of the extension. */
  private final String fId;
  /** The name of the extension. */
  private final String fName;
  /** The class name of the provided <code>AbstractProposalSorter</code>. */
  private final String fClass;
  /** The activate attribute value. */
  private final boolean fActivate;
  /** The configuration element of this extension. */
  private final IConfigurationElement fElement;
  /** The computer, if instantiated, <code>null</code> otherwise. */
  private AbstractProposalSorter fSorter;

  /**
   * Creates a new descriptor.
   * 
   * @param element the configuration element to read
   * @throws InvalidRegistryObjectException if the configuration element is not valid any longer or
   *           does not contain mandatory attributes
   */
  ProposalSorterHandle(IConfigurationElement element) throws InvalidRegistryObjectException {
    Assert.isLegal(element != null);

    fElement = element;
    fId = element.getAttribute(ID);
    checkNotNull(fId, ID);

    String name = element.getAttribute(NAME);
    if (name == null) {
      fName = fId;
    } else {
      fName = name;
    }

    String activateAttribute = element.getAttribute(ACTIVATE);
    fActivate = Boolean.valueOf(activateAttribute).booleanValue();

    fClass = element.getAttribute(CLASS);
    checkNotNull(fClass, CLASS);
  }

  /**
   * Returns the error message from the described extension, <code>null</code> for no error.
   * 
   * @return the error message from the described extension, <code>null</code> for no error
   */
  public String getErrorMessage() {
    return null;
  }

  /**
   * Returns the identifier of the described extension.
   * 
   * @return Returns the id
   */
  public String getId() {
    return fId;
  }

  /**
   * Returns the name of the described extension.
   * 
   * @return Returns the name
   */
  public String getName() {
    return fName;
  }

  /**
   * Safely computes completion proposals through the described extension. If the extension throws
   * an exception or otherwise does not adhere to the contract described in
   * {@link AbstractProposalSorter}, the list is returned as is.
   * 
   * @param context the invocation context passed on to the extension
   * @param proposals the list of computed completion proposals to be sorted (element type:
   *          {@link org.eclipse.jface.text.contentassist.ICompletionProposal}), must be writable
   */
  @SuppressWarnings("unchecked")
  public void sortProposals(ContentAssistInvocationContext context,
      @SuppressWarnings("rawtypes") List proposals) {
    IStatus status;
    try {
      AbstractProposalSorter sorter = getSorter();

      PerformanceStats stats = startMeter(SORT, sorter);

      sorter.beginSorting(context);
      Collections.sort(proposals, sorter);
      sorter.endSorting();

      status = stopMeter(stats, SORT);

      // valid result
      if (status == null) {
        return;
      }

      status = createAPIViolationStatus(SORT);

    } catch (InvalidRegistryObjectException x) {
      status = createExceptionStatus(x);
    } catch (CoreException x) {
      status = createExceptionStatus(x);
    } catch (RuntimeException x) {
      status = createExceptionStatus(x);
    }

    DartToolsPlugin.log(status);
    return;
  }

  /**
   * Checks an element that must be defined according to the extension point schema. Throws an
   * <code>InvalidRegistryObjectException</code> if <code>obj</code> is <code>null</code>.
   */
  private void checkNotNull(Object obj, String attribute) throws InvalidRegistryObjectException {
    if (obj == null) {
      Object[] args = {getId(), fElement.getContributor().getName(), attribute};
      String message = Messages.format(
          DartTextMessages.CompletionProposalComputerDescriptor_illegal_attribute_message,
          args);
      IStatus status = new Status(
          IStatus.WARNING,
          DartToolsPlugin.getPluginId(),
          IStatus.OK,
          message,
          null);
      DartToolsPlugin.log(status);
      throw new InvalidRegistryObjectException();
    }
  }

  private Status createAPIViolationStatus(String operation) {
    String disable = createBlameMessage();
    Object[] args = {operation};
    String reason = Messages.format(
        DartTextMessages.CompletionProposalComputerDescriptor_reason_API,
        args);
    return new Status(IStatus.WARNING, DartToolsPlugin.getPluginId(), IStatus.OK, disable
        + " " + reason, null); //$NON-NLS-1$
  }

  private String createBlameMessage() {
    Object[] args = {getName(), getId()};
    String disable = Messages.format(DartTextMessages.ProposalSorterHandle_blame, args);
    return disable;
  }

  private Status createExceptionStatus(CoreException x) {
    // unable to instantiate the extension - log & disable
    String disable = createBlameMessage();
    String reason = DartTextMessages.CompletionProposalComputerDescriptor_reason_instantiation;
    return new Status(IStatus.ERROR, DartToolsPlugin.getPluginId(), IStatus.OK, disable
        + " " + reason, x); //$NON-NLS-1$
  }

  private Status createExceptionStatus(InvalidRegistryObjectException x) {
    // extension has become invalid - log & disable
    String disable = createBlameMessage();
    String reason = DartTextMessages.CompletionProposalComputerDescriptor_reason_invalid;
    return new Status(IStatus.INFO, DartToolsPlugin.getPluginId(), IStatus.OK, disable
        + " " + reason, x); //$NON-NLS-1$
  }

  private Status createExceptionStatus(RuntimeException x) {
    // misbehaving extension - log & disable
    String disable = createBlameMessage();
    String reason = DartTextMessages.CompletionProposalComputerDescriptor_reason_runtime_ex;
    return new Status(IStatus.WARNING, DartToolsPlugin.getPluginId(), IStatus.OK, disable
        + " " + reason, x); //$NON-NLS-1$
  }

  private Status createPerformanceStatus(String operation) {
    String disable = createBlameMessage();
    Object[] args = {operation};
    String reason = Messages.format(
        DartTextMessages.CompletionProposalComputerDescriptor_reason_performance,
        args);
    return new Status(IStatus.WARNING, DartToolsPlugin.getPluginId(), IStatus.OK, disable
        + " " + reason, null); //$NON-NLS-1$
  }

  /**
   * Returns a new instance of the sorter as described in the extension's xml.
   * 
   * @return a new instance of the completion proposal computer as described by this descriptor
   * @throws CoreException if the creation fails
   * @throws InvalidRegistryObjectException if the extension is not valid any longer (e.g. due to
   *           plug-in unloading)
   */
  private AbstractProposalSorter createSorter() throws CoreException,
      InvalidRegistryObjectException {
    return (AbstractProposalSorter) fElement.createExecutableExtension(CLASS);
  }

  private Bundle getBundle() throws InvalidRegistryObjectException {
    String symbolicName = fElement.getContributor().getName();
    Bundle bundle = Platform.getBundle(symbolicName);
    return bundle;
  }

  /**
   * Returns a cached instance of the sorter as described in the extension's xml. The sorter is
   * {@link #createSorter() created} the first time that this method is called and then cached.
   * 
   * @return a new instance of the proposal sorter as described by this descriptor
   * @throws CoreException if the creation fails
   * @throws InvalidRegistryObjectException if the extension is not valid any longer (e.g. due to
   *           plug-in unloading)
   */
  private synchronized AbstractProposalSorter getSorter() throws CoreException,
      InvalidRegistryObjectException {
    if (fSorter == null && (fActivate || isPluginLoaded())) {
      fSorter = createSorter();
    }
    return fSorter;
  }

  private boolean isPluginLoaded() throws InvalidRegistryObjectException {
    Bundle bundle = getBundle();
    return bundle != null && bundle.getState() == Bundle.ACTIVE;
  }

  private PerformanceStats startMeter(String context, AbstractProposalSorter sorter) {
    final PerformanceStats stats;
    if (MEASURE_PERFORMANCE) {
      stats = PerformanceStats.getStats(PERFORMANCE_EVENT, sorter);
      stats.startRun(context);
    } else {
      stats = null;
    }
    return stats;
  }

  private IStatus stopMeter(final PerformanceStats stats, String operation) {
    if (MEASURE_PERFORMANCE) {
      stats.endRun();
      if (stats.isFailure()) {
        return createPerformanceStatus(operation);
      }
    }
    return null;
  }

}
