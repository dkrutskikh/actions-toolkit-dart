import 'dart:io';

import '../environment_variables.dart';

const _summaryEnvVar = 'GITHUB_STEP_SUMMARY';

class SummaryFilePath {
  String? _resolvedPath;

  /// Finds the summary file path from the environment, rejects if env var is not found or file does not exist.
  String path() {
    if (_resolvedPath != null) {
      return _resolvedPath!;
    }

    final pathFromEnv = environmentVariables[_summaryEnvVar];
    if (pathFromEnv == null) {
      throw StateError(
        'Unable to find environment variable for \$$_summaryEnvVar. Check if your runtime environment supports job summaries.',
      );
    }

    if (!File(pathFromEnv).existsSync()) {
      throw StateError(
        "Unable to access summary file: '$pathFromEnv'. Check if the file has correct read/write permissions.",
      );
    }

    _resolvedPath = pathFromEnv;

    return pathFromEnv;
  }
}
