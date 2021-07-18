import 'command.dart';
import 'environment_variables.dart';
import 'output.dart';

//-----------------------------------------------------------------------
// Logging Commands
//-----------------------------------------------------------------------

/// Gets whether Actions Step Debug is on or not
bool isDebug() => environmentVariables['RUNNER_DEBUG'] == '1';

/// Writes debug message to user log
void debug(String message) {
  issueCommand('debug', {}, message);
}

/// Adds an error issue
void error(String message) {
  issue('error', message);
}

/// Adds an warning issue
void warning(String message) {
  issue('warning', message);
}

/// Writes info to log with console.log.
void info(String message) {
  output.writeln(message);
}

/// Begin an output group.
///
/// Output until the next `groupEnd` will be foldable in this group.
void startGroup(String name) {
  issue('group', name);
}

/// End an output group.
void endGroup() {
  issue('endgroup');
}

/// Wrap an asynchronous function call in a group.
///
/// Returns the same type as the function itself.
Future<T?> group<T>(String name, Future<T> Function() fn) async {
  startGroup(name);

  T? result;

  try {
    result = await fn();
  } finally {
    endGroup();
  }

  return result;
}
