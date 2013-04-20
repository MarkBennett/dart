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
package com.google.dart.indexer.workspace.driver;

import com.google.dart.indexer.IndexerPlugin;
import com.google.dart.indexer.debug.IndexerDebugOptions;
import com.google.dart.indexer.exceptions.IndexIsStillBuilding;
import com.google.dart.indexer.exceptions.IndexRequiresFullRebuild;
import com.google.dart.indexer.exceptions.IndexTemporarilyNonOperational;
import com.google.dart.indexer.index.IndexSessionStats;
import com.google.dart.indexer.index.configuration.IndexConfigurationInstance;
import com.google.dart.indexer.index.queries.Query;
import com.google.dart.indexer.workspace.index.IndexingTarget;
import com.google.dart.indexer.workspace.index.WorkspaceIndexer;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.ISavedState;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.OperationCanceledException;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;

import java.io.IOException;

public class WorkspaceIndexingDriver {
  private final class IndexingJob extends Job {
    private long indexingDuration = 0;

    public IndexingJob() {
      super("Dart Indexer");
      setPriority(Job.BUILD);
    }

    @Override
    protected IStatus run(IProgressMonitor monitor) {
      int startSize = indexer.getQueueSize();
      monitor.beginTask("Indexing", startSize);
      try {
        long start = System.currentTimeMillis();
        boolean moreWork = indexer.indexPendingFiles(-1, monitor);
        long finish = System.currentTimeMillis();
        if (moreWork && !monitor.isCanceled()) {
          schedule();
        }
        indexingDuration += finish - start;
        if (!moreWork) {
          if (TRACE_INDEXING_TIME) {
            IndexerPlugin.getLogger().logError("Indexing took " + indexingDuration + " ms");
          }
          indexingDuration = 0;
        } else {
          // monitor.setTaskName("Indexing for " + (int) (indexingDuration /
          // 1000.0 + 0.5) + " seconds");
        }
        retryTimer.successfulAttemp();
      } catch (IndexTemporarilyNonOperational exception) {
        retryTimer.failedAttemp();
        schedule(retryTimer.delayUntilNextAttemp());
        indexingDuration = 0;
        IndexerPlugin.getLogger().logError(exception, "Index temporarily non-operational");
      }
      return Status.OK_STATUS;
    }
  }

  private class ResourceChangeListener implements IResourceChangeListener {
    @Override
    public void resourceChanged(IResourceChangeEvent event) {
      IResourceDelta delta = event.getDelta();
      try {
        if (delta != null) {
          DeltaProcessor deltaProcessor = new DeltaProcessor();
          delta.accept(deltaProcessor);
          indexer.enqueueChangedFiles(deltaProcessor.getRemovedFiles());
          workAdded();
        }
      } catch (CoreException e) {
        // cannot happen (only propagates from the visitor)
        IndexerPlugin.getLogger().logError(e);
      }
    }
  }

  private final static boolean TRACE_INDEXING_TIME = Boolean.valueOf(
      Platform.getDebugOption(IndexerDebugOptions.INDEXING_TIME)).booleanValue();

  private final WorkspaceIndexer indexer;

  private final RetryTimer retryTimer = new RetryTimer();

  private final IndexConfigurationInstance configuration;

  private final ResourceChangeListener resourceChangeListener = new ResourceChangeListener();

  private volatile boolean isShutdown = false;

  public static boolean isRunningTests = false;

  private final IndexingJob indexingJob = new IndexingJob();

  /**
   * The number of milliseconds we should wait for the indexer to finish before trying again to
   * execute a query.
   */
  // TODO(devoncarew): why 1000ms here?
  private static final int WAIT_INTERVAL = 1000;

  public WorkspaceIndexingDriver(IndexConfigurationInstance configuration) {
    this.configuration = configuration;
    IWorkspace workspace = ResourcesPlugin.getWorkspace();
    SavedDeltasProcessor processor = new SavedDeltasProcessor();
    try {
      ISavedState state = workspace.addSaveParticipant(IndexerPlugin.PLUGIN_ID,
          new SaveParticipantAskingForDelta());
      if (state != null) {
        state.processResourceChangeEvents(processor);
      }
    } catch (CoreException e) {
    }
    if (!processor.hasBeenCalled()) {
      indexer = new WorkspaceIndexer(configuration);
    } else {
      indexer = new WorkspaceIndexer(configuration, processor.getRemovedFiles());
    }
    workAdded();
    workspace.addResourceChangeListener(resourceChangeListener, IResourceChangeEvent.POST_CHANGE);

  }

  public String diskIndexAsString() throws IOException {
    return indexer.diskIndexAsString();
  }

  /**
   * Force the given files to be re-indexed.
   * 
   * @param changedFiles the files that need to be re-indexed
   */
  public void enqueueChangedFiles(IFile[] changedFiles) {
    indexer.enqueueChangedFiles(changedFiles);
    workAdded();
  }

  /**
   * Add the given targets to the queue of targets waiting to be indexed.
   * 
   * @param targets the targets to be added to the indexing queue
   */
  public void enqueueTargets(IndexingTarget[] targets) {
    indexer.enqueueTargets(targets);
    workAdded();
  }

  public void execute(Query query) throws IndexTemporarilyNonOperational {
    try {
      synchronized (indexer) {
        indexer.prioritizeQuery(query);
        try {
          boolean hasBeenScheduled = false;
          while (!isShutdown) {
            try {
              indexer.execute(query);
              break;
            } catch (IndexRequiresFullRebuild e) {
            } catch (IndexIsStillBuilding e) {
              // If we're waiting for the index to be built, then make sure that the indexer job has
              // been scheduled so that we don't wait forever.
              if (!hasBeenScheduled) {
                indexingJob.schedule();
                hasBeenScheduled = true;
              }
            }
            indexer.wait(WAIT_INTERVAL);
          }
        } finally {
          indexer.unprioritizeQuery(query);
        }
      }
      if (isShutdown) {
        throw new IndexTemporarilyNonOperational("The indexer has been shut down");
      }
    } catch (IndexTemporarilyNonOperational e) {
      throw e;
    } catch (InterruptedException e) {
      throw new OperationCanceledException();
    }
  }

  public IndexSessionStats gatherStatistics() {
    return indexer.gatherStatistics();
  }

  public IndexConfigurationInstance getConfiguration() {
    return configuration;
  }

  /**
   * @return files which may be indexed with errors
   */
  public IPath[] getFilesWithErrors() {
    return indexer.getFilesWithErrors();
  }

  /**
   * @return true if index contains errors
   */
  public boolean hasErrors() {
    return indexer.hasErrors();
  }

  public boolean isShutdown() {
    return isShutdown;
  }

  public void rebuildIndex() {
    indexingJob.cancel();
    try {
      indexingJob.join();
    } catch (InterruptedException exception) {
      IndexerPlugin.getLogger().logError(
          "Might not have joined indexing job before rebuilding the index", exception);
    }
    indexer.rebuildIndex();
    workAdded();
  }

  public void runConsistencyCheck(IProgressMonitor monitor) {
    indexer.runConsistencyCheck(monitor);
  }

  @SuppressWarnings("deprecation")
  public void shutdown() {
    IWorkspace workspace = ResourcesPlugin.getWorkspace();
    workspace.removeResourceChangeListener(resourceChangeListener);
    workspace.removeSaveParticipant(IndexerPlugin.getDefault());
    // XXX FIXME race condition: changes might be lost here
    indexingJob.cancel();
    isShutdown = true;

    try {
      indexingJob.join();
    } catch (InterruptedException exception) {
      IndexerPlugin.getLogger().logError("Might not have joined indexing job during shutdown",
          exception);
    }
    indexer.dispose();
  }

  private void workAdded() {
    indexingJob.schedule();
  }
}
