import 'dart:convert';

/// Sanitizes an input into a string so it can be passed into issueCommand safely
String toCommandValue(Object? input) {
  if (input == null) {
    return '';
  } else if (input is String) {
    return input;
  }

  return jsonEncode(input);
}
