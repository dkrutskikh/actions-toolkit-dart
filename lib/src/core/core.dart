import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'annotation_properties.dart';
import 'command.dart';
import 'environment_variables.dart';
import 'exit_code.dart';
import 'file_command.dart';
import 'input_options.dart';
import 'output.dart';
import 'utils.dart';

/// Sets env variable for this action and future actions in the job.
void exportVariable({required String name, required Object value}) {
  final convertedVal = toCommandValue(value);

  final filePath = environmentVariables['GITHUB_ENV'] ?? '';
  if (filePath.isNotEmpty) {
    const delimiter = '_GitHubActionsFileCommandDelimeter_';
    const separator = '\n';
    final commandValue =
        '$name<<$delimiter$separator$convertedVal$separator$delimiter';
    issueFileCommand('ENV', commandValue);
  } else {
    issueCommand('set-env', {'name': name}, convertedVal);
  }

  updateEnvironmentVariableCache(name: name, value: convertedVal);
}

/// Registers a secret which will get masked from logs.
void setSecret(String secret) {
  issueCommand('add-mask', {}, secret);
}

/// Prepends inputPath to the PATH (for this action and future actions).
void addPath({required String path}) {
  final filePath = environmentVariables['GITHUB_PATH'] ?? '';

  if (filePath.isNotEmpty) {
    issueFileCommand('PATH', path);
  } else {
    issueCommand('add-path', {}, path);
  }

  updateEnvironmentVariableCache(
    name: 'PATH',
    value: '$path${p.separator}${environmentVariables['PATH']}',
  );
}

/// Gets the value of an input.
///
/// Unless trimWhitespace is set to false in [InputOptions], the value is also
/// trimmed. Returns an empty string if the value is not defined.
String getInput({
  required String name,
  InputOptions options = const InputOptions(),
}) {
  final key = 'INPUT_${name.replaceAll(' ', '_').toUpperCase()}';

  final val = environmentVariables[key] ?? '';
  if (options.required && val.isEmpty) {
    throw ArgumentError('Input required and not supplied: $name');
  }

  return options.trimWhitespace ? val.trim() : val;
}

/// Gets the values of a multiline input. Each value is also trimmed.
Iterable<String> getMultilineInput({
  required String name,
  InputOptions options = const InputOptions(),
}) =>
    getInput(name: name, options: options)
        .split('\n')
        .where((value) => value.isNotEmpty)
        .toList();

/// Gets the input value of the boolean type in the [YAML 1.2](https://yaml.org/spec/1.2/spec.html#id2804923) "core schema" specification.
///
/// Supported boolean input list: `true | True | TRUE | false | False | FALSE` .
bool getBooleanInput({
  required String name,
  InputOptions options = const InputOptions(),
}) {
  const trueValues = {'true', 'True', 'TRUE'};
  const falseValues = {'false', 'False', 'FALSE'};

  final val = getInput(name: name, options: options);
  if (trueValues.contains(val)) {
    return true;
  } else if (falseValues.contains(val)) {
    return false;
  }

  throw StateError(
    'Input does not meet YAML 1.2 "Core Schema" specification: $name\n'
    'Supported boolean input list: `true | True | TRUE | false | False | FALSE`',
  );
}

/// Sets the value of an output.
void setOutput({required String name, required Object value}) {
  final filePath = Platform.environment['GITHUB_OUTPUT'] ?? '';
  final message = value is String ? value : jsonEncode(value);

  if (filePath.isNotEmpty) {
    issueFileCommand('OUTPUT', '$name=$message');
  } else {
    output.writeln('');

    issueCommand(
      'set-output',
      {'name': name},
      message,
    );
  }
}

/// Enables or disables the echoing of commands into stdout for the rest of the step.
///
/// Echoing is disabled by default if ACTIONS_STEP_DEBUG is not set.
void setCommandEcho({required bool enabled}) {
  issue('echo', enabled ? 'on' : 'off');
}

//-----------------------------------------------------------------------
// Results
//-----------------------------------------------------------------------

/// Sets the action status to failed.
///
/// When the action exits it will be with an exit code of 1
void setFailed({required String message}) {
  exitCode = ExitCode.failure;

  error(message: message);
}

//-----------------------------------------------------------------------
// Logging Commands
//-----------------------------------------------------------------------

/// Gets whether Actions Step Debug is on or not
bool isDebug() => environmentVariables['RUNNER_DEBUG'] == '1';

/// Writes debug [message] to user log.
void debug({required String message}) {
  issueCommand('debug', {}, message);
}

/// Adds an error [message] with optional [properties].
void error({required String message, AnnotationProperties? properties}) {
  issueCommand('error', toCommandProperties(properties), message);
}

/// Adds an warning [message] with optional [properties].
void warning({required String message, AnnotationProperties? properties}) {
  issueCommand('warning', toCommandProperties(properties), message);
}

/// Adds a notice issue [message] with optional [properties].
void notice({required String message, AnnotationProperties? properties}) {
  issueCommand('notice', toCommandProperties(properties), message);
}

/// Writes info [message] to log with console.log.
void info({required String message}) {
  output.writeln(message);
}

/// Begin an output group.
///
/// Output until the next [endGroup] will be foldable in this group.
void startGroup({required String name}) {
  issue('group', name);
}

/// End an output group.
void endGroup() {
  issue('endgroup');
}

/// Wraps an asynchronous function call in a group.
///
/// Returns the same type as the function itself.
Future<T?> group<T>({
  required String name,
  required Future<T> Function() fn,
}) async {
  startGroup(name: name);

  T? result;

  try {
    result = await fn();
  } finally {
    endGroup();
  }

  return result;
}

//-----------------------------------------------------------------------
// Wrapper action state
//-----------------------------------------------------------------------

/// Saves state for current action.
///
/// The state can only be retrieved by this action's post job execution.
void saveState({
  required String name,
  required Object value,
}) {
  final filePath = Platform.environment['GITHUB_STATE'] ?? '';
  final message = value is String ? value : jsonEncode(value);

  if (filePath.isNotEmpty) {
    issueFileCommand('STATE', '$name=$message');
  } else {
    issueCommand(
      'save-state',
      {'name': name},
      message,
    );
  }
}

/// Gets the value of an state set by this action's main execution.
String getState({required String name}) =>
    environmentVariables['STATE_$name'] ?? '';
