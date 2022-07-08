import 'dart:io';

import 'package:meta/meta.dart';

Map<String, String> _environmentVariables = Platform.environment;
Map<String, String> get environmentVariables => _environmentVariables;

void updateEnvironmentVariableCache({
  required String name,
  required String? value,
}) {
  final newEnvs = {...environmentVariables};

  if (value != null) {
    newEnvs[name] = value;
  } else {
    newEnvs.remove(name);
  }

  _environmentVariables = newEnvs;
}

@visibleForTesting
void setupEnvironmentVariables(Map<String, String> newVariables) {
  _environmentVariables = newVariables;
}
