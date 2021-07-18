import 'dart:io';

import 'package:meta/meta.dart';

Map<String, String> _environmentVariables = Platform.environment;
Map<String, String> get environmentVariables => _environmentVariables;

@visibleForTesting
void setupEnvironmentVariables(Map<String, String> newVariables) {
  _environmentVariables = newVariables;
}
