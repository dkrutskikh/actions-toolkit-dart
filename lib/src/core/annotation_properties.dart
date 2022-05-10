import 'package:meta/meta.dart';

/// Optional properties that can be sent with annotation commands (notice, error, and warning)
///
/// See: https://docs.github.com/en/rest/reference/checks#create-a-check-run for
/// more information about annotations.
@immutable
class AnnotationProperties {
  /// A title for the annotation.
  final String? title;

  /// The path of the file for which the annotation should be created.
  final String? file;

  /// The start line for the annotation.
  final int? startLine;

  /// The end line for the annotation.
  ///
  /// Defaults to `startLine` when `startLine` is provided.
  final int? endLine;

  /// The start column for the annotation.
  ///
  /// Cannot be sent when `startLine` and `endLine` are different values.
  final int? startColumn;

  /// The start column for the annotation.
  ///
  /// Cannot be sent when `startLine` and `endLine` are different values.
  /// Defaults to `startColumn` when `startColumn` is provided.
  final int? endColumn;

  const AnnotationProperties({
    this.title,
    this.file,
    this.startLine,
    this.endLine,
    this.startColumn,
    this.endColumn,
  });
}
