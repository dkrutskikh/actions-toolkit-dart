import 'dart:io';

import 'package:actions_toolkit_dart/src/core/environment_variables.dart';
import 'package:actions_toolkit_dart/src/core/utils/summary_filepath.dart';
import 'package:test/test.dart';

const _summaryPath = 'summary.txt';

void main() {
  group('SummaryFilePath path', () {
    late SummaryFilePath filePath;

    setUp(() {
      filePath = SummaryFilePath();

      setupEnvironmentVariables({'GITHUB_STEP_SUMMARY': _summaryPath});
    });

    test('throws exception if not found valid github variable', () {
      setupEnvironmentVariables({});

      expect(
        () => filePath.path(),
        throwsStateError,
      );
    });

    test('throws exception if found invalid filepath', () {
      expect(
        () => filePath.path(),
        throwsStateError,
      );
    });

    test('returns summary file path', () {
      final file = File(_summaryPath)..createSync();

      expect(filePath.path(), equals(_summaryPath));

      file.deleteSync();

      expect(filePath.path(), equals(_summaryPath));
    });
  });
}
