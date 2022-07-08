@TestOn('vm')

import 'package:actions_toolkit_dart/src/core/environment_variables.dart'
    as core;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final testEnvVars = {
  'PATH': 'path1${p.context.separator}path2',

  // Set inputs.
  'INPUT_MY_INPUT': 'val',
  'INPUT_MISSING': '',
  'INPUT_SPECIAL_CHARS_\'\t"\\': '\'\t"\\ response ',
  'INPUT_MULTIPLE_SPACES_VARIABLE': 'I have multiple spaces',
  'INPUT_BOOLEAN_INPUT': 'true',
  'INPUT_BOOLEAN_INPUT_TRUE1': 'true',
  'INPUT_BOOLEAN_INPUT_TRUE2': 'True',
  'INPUT_BOOLEAN_INPUT_TRUE3': 'TRUE',
  'INPUT_BOOLEAN_INPUT_FALSE1': 'false',
  'INPUT_BOOLEAN_INPUT_FALSE2': 'False',
  'INPUT_BOOLEAN_INPUT_FALSE3': 'FALSE',
  'INPUT_WITH_TRAILING_WHITESPACE': '  some val  ',

  'INPUT_MY_INPUT_LIST': 'val1\nval2\n\nval3',

  // Save inputs.
  'STATE_TEST_1': 'state_val',

  // File Commands.
  'GITHUB_PATH': '',
  'GITHUB_ENV': '',
};

void main() {
  group('updateEnvironmentVariableCache', () {
    setUp(() {
      core.setupEnvironmentVariables(testEnvVars);
    });

    test('adds new variable in cache', () {
      expect(core.environmentVariables['foo'], isNull);

      core.updateEnvironmentVariableCache(name: 'foo', value: 'bar');

      expect(core.environmentVariables['foo'], equals('bar'));
    });

    test('updates available variable in cache', () {
      core.updateEnvironmentVariableCache(name: 'PATH', value: 'NEW_PATH');

      expect(core.environmentVariables['PATH'], equals('NEW_PATH'));
    });

    test('removes available variable in cache if passed null', () {
      expect(core.environmentVariables.containsKey('GITHUB_ENV'), isTrue);

      core.updateEnvironmentVariableCache(name: 'GITHUB_ENV', value: null);

      expect(core.environmentVariables.containsKey('GITHUB_ENV'), isFalse);
    });
  });
}
