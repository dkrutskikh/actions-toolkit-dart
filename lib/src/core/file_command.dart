import 'dart:io';

import 'environment_variables.dart';
import 'utils.dart';

void issueFileCommand(String command, Object message) {
  final filePath = environmentVariables['GITHUB_$command'];
  if (filePath == null) {
    throw ArgumentError(
      'Unable to find environment variable for file command: $command',
    );
  }

  final file = File(filePath);
  if (file.existsSync()) {
    throw ArgumentError('Missing file at path: $filePath');
  }

  file.writeAsStringSync('${toCommandValue(message)}\n');
}
