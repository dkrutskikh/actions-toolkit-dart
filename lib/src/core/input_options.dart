import 'package:meta/meta.dart';

/// Interface for getInput options
@immutable
class InputOptions {
  /// Whether the input is required.
  ///
  /// If required and not present, will throw exception.
  final bool required;

  /// Whether leading/trailing whitespace will be trimmed for the input.
  final bool trimWhitespace;

  const InputOptions({this.required = false, this.trimWhitespace = true});
}
