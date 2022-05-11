@TestOn('vm')
import 'package:actions_toolkit_dart/src/core/annotation_properties.dart';
import 'package:actions_toolkit_dart/src/core/utils.dart';
import 'package:test/test.dart';

void main() {
  test('annotations map field names correctly', () {
    final commandProperties = toCommandProperties(const AnnotationProperties(
      title: 'A title',
      file: 'root/test.txt',
      startColumn: 1,
      endColumn: 2,
      startLine: 5,
      endLine: 5,
    ));

    expect(commandProperties, containsPair('title', 'A title'));
    expect(commandProperties, containsPair('file', 'root/test.txt'));
    expect(commandProperties, containsPair('col', 1));
    expect(commandProperties, containsPair('endColumn', 2));
    expect(commandProperties, containsPair('line', 5));
    expect(commandProperties, containsPair('endLine', 5));
  });
}
