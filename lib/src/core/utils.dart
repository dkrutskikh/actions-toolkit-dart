import 'dart:convert';

import 'annotation_properties.dart';

/// Sanitizes an input into a string so it can be passed into issueCommand safely.
String toCommandValue(Object? input) {
  if (input == null) {
    return '';
  } else if (input is String) {
    return input;
  }

  return jsonEncode(input);
}

/// Returns a command properties to send with the actual annotation command.
Map<String, Object> toCommandProperties(AnnotationProperties? properties) =>
    properties == null
        ? {}
        : {
            if (properties.title != null) 'title': properties.title!,
            if (properties.file != null) 'file': properties.file!,
            if (properties.startLine != null) 'line': properties.startLine!,
            if (properties.endLine != null) 'endLine': properties.endLine!,
            if (properties.startColumn != null) 'col': properties.startColumn!,
            if (properties.endColumn != null)
              'endColumn': properties.endColumn!,
          };
