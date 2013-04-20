// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of pipeline;

List stdout, stderr, log;
var replyPort;
int _procId = 1;
Map _procs = {};

/**
 * Create a file path for a temporary file. The file will be in the
 * [tmpDir] directory, with name [basis], but with any extension
 * stripped and replaced by [suffix].
 */
String createTempName(String tmpDir, String basis, String suffix) {
  var p = new Path(basis);
  return '$tmpDir${Platform.pathSeparator}'
      '${p.filenameWithoutExtension}${suffix}';
}

/**
 * Given a file path [file], make it absolute if it is relative,
 * and return the result as a [Path].
 */
Path getAbsolutePath(String file) {
  var p = new Path(file).canonicalize();
  if (p.isAbsolute) {
    return p;
  } else {
    var cwd = new Path((new Directory.current()).path);
    return cwd.join(p);
  }
}

/** Get the directory that contains a [file]. */
String getDirectory(String file) =>
    getAbsolutePath(file).directoryPath.toString();

/** Create a file [fileName] and populate it with [contents]. */
void writeFile(String fileName, String contents) {
  var file = new File(fileName);
  var ostream = file.openOutputStream(FileMode.WRITE);
  ostream.writeString(contents);
  ostream.close();
}

/*
 * Run an external process [cmd] with command line arguments [args].
 * [timeout] can be used to forcefully terminate the process after
 * some number of seconds. This is used by runCommand and startProcess.
 * If [procId] is non-zero (i.e. called from startProcess) then a reference
 * to the [Process] will be put in a map with key [procId]; in this case
 * the process can be terminated later by calling [stopProcess] and
 * passing in the [procId].
 * [outputMonitor] is an optional function that will be called back with each
 * line of output from the process.
 * Returns a [Future] for when the process terminates.
 */
Future _processHelper(String command, List<String> args,
    [int timeout = 300, int procId = 0, Function outputMonitor]) {
  var completer = procId == 0 ? new Completer() : null;
  log.add('Running $command ${args.join(" ")}');
  var timer = null;
  var stdoutHandler, stderrHandler;
  var processFuture = Process.start(command, args);
  processFuture.then((process) {
    _procs[procId] = process;

    timer = new Timer(new Duration(seconds: timeout), () {
      timer = null;
      process.kill();
    });

    process.onExit = (exitCode) {
      if (timer != null) {
        timer.cancel();
      }
      process.close();
      if (completer != null) {
        completer.complete(exitCode);
      }
    };

    _pipeStream(process.stdout, stdout, outputMonitor);
    _pipeStream(process.stderr, stderr, outputMonitor);
  });
  processFuture.handleException((e) {
    stderr.add("Error starting process:");
    stderr.add("  Command: $command");
    stderr.add("  Error: $e");
    completePipeline(-1);
    return true;
  });

  return completer.future;
}

void _pipeStream(InputStream stream, List<String> destination,
                 Function outputMonitor) {
  var source = new StringInputStream(stream);
  source.onLine = () {
    if (source.available() == 0) return;
    var line = source.readLine();
    while (null != line) {
      if (config["immediate"] && line.startsWith('###')) {
        // TODO - when we dump the list later skip '###' messages if immediate.
        print(line.substring(3));
      }
      if (outputMonitor != null) {
        outputMonitor(line);
      }
      destination.add(line);
      line = source.readLine();
    }
  };
}

/**
 * Run an external process [cmd] with command line arguments [args].
 * [timeout] can be used to forcefully terminate the process after
 * some number of seconds.
 * Returns a [Future] for when the process terminates.
 */
Future runCommand(String command, List<String> args,
                  [int timeout = 300, Function outputMonitor]) {
  return _processHelper(command, args, timeout, outputMonitor:outputMonitor);
}

/**
 * Start an external process [cmd] with command line arguments [args].
 * Returns an ID by which it can later be stopped.
 */
int startProcess(String command, List<String> args, [Function outputMonitor]) {
  int id = _procId++;
  _processHelper(command, args, 3000, id,
      outputMonitor:outputMonitor).then((e) {
    _procs.remove(id);
  });
  return id;
}

/** Checks if a process is still running. */
bool isProcessRunning(int id) {
  return _procs.containsKey(id);
}

/**
 * Stop a process previously started with [startProcess] or [runCommand],
 * given the id string.
 */
void stopProcess(int id) {
  if (_procs.containsKey(id)) {
    Process p = _procs.remove(id);
    p.kill();
  }
}

/** Delete a file named [fname] if it exists. */
bool cleanup(String fname) {
  if (fname != null && !config['keep-files']) {
    var f = new File(fname);
    try {
      if (f.existsSync()) {
        logMessage('Removing $fname');
        f.deleteSync();
      }
    } catch (e) {
      return false;
    }
  }
  return true;
}

initPipeline(port) {
  replyPort = port;
  stdout = new List();
  stderr = new List();
  log = new List();
}

void completePipeline([exitCode = 0]) {
  replyPort.send([stdout, stderr, log, exitCode]);
}

/** Utility function to log diagnostic messages. */
void logMessage(msg) => log.add(msg);
