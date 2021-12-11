@TestOn('vm')
import 'dart:io';

import 'package:actions_toolkit_dart/src/core/annotation_properties.dart';
import 'package:actions_toolkit_dart/src/core/core.dart' as core;
import 'package:actions_toolkit_dart/src/core/environment_variables.dart'
    as core;
import 'package:actions_toolkit_dart/src/core/input_options.dart' as core;
import 'package:actions_toolkit_dart/src/core/output.dart' as core;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class IOSinkMock extends Mock implements IOSink {}

const message = 'simple message';

final testEnvVars = {
  'PATH': 'path1${p.context.separator}path2',

  // Set inputs
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

  // Save inputs
  'STATE_TEST_1': 'state_val',

  // File Commands
  'GITHUB_PATH': '',
  'GITHUB_ENV': '',
};

void main() {
  group('core', () {
    setUp(() {
      core.setupOutput(IOSinkMock());
      core.setupEnvironmentVariables(testEnvVars);
    });

    test(
      'legacy exportVariable produces the correct command and sets the env',
      () {
        core.exportVariable(name: 'my var', value: 'var val');

        expect(
          verify(() => core.output.writeln(captureAny())).captured.single,
          equals('::set-env name=my var::var val'),
        );
      },
    );

    test('legacy exportVariable escapes variable names', () {
      core.exportVariable(
        name: 'special char var \r\n,:',
        value: 'special val',
      );

      expect(
        core.environmentVariables,
        containsPair('special char var \r\n,:', 'special val'),
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::set-env name=special char var %0D%0A%2C%3A::special val'),
      );
    });

    test('legacy exportVariable escapes variable values', () {
      core.exportVariable(name: 'my var2', value: 'var val\r\n');

      expect(
        core.environmentVariables,
        containsPair('my var2', 'var val\r\n'),
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::set-env name=my var2::var val%0D%0A'),
      );
    });

    test('legacy exportVariable handles boolean inputs', () {
      core.exportVariable(name: 'my var', value: true);

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::set-env name=my var::true'),
      );
    });

    test('legacy exportVariable handles number inputs', () {
      core.exportVariable(name: 'my var', value: 5);

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::set-env name=my var::5'),
      );
    });

    test('setSecret produces the correct command', () {
      core.setSecret(secret: 'secret val');

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::add-mask::secret val'),
      );
    });

    test(
      'legacy prependPath produces the correct commands and sets the env',
      () {
        core.addPath(path: 'myPath');

        expect(
          core.environmentVariables,
          containsPair(
            'PATH',
            'myPath${p.context.separator}path1${p.context.separator}path2',
          ),
        );

        expect(
          verify(() => core.output.writeln(captureAny())).captured.single,
          equals('::add-path::myPath'),
        );
      },
    );

    test('getInput gets non-required input', () {
      expect(core.getInput(name: 'my input'), equals('val'));
    });

    test('getInput gets required input', () {
      expect(
        core.getInput(
          name: 'my input',
          options: const core.InputOptions(required: true),
        ),
        equals('val'),
      );
    });

    test('getInput throws on missing required input', () {
      expect(
        () => core.getInput(
          name: 'missing',
          options: const core.InputOptions(required: true),
        ),
        throwsArgumentError,
      );
    });

    test('getInput does not throw on missing non-required input', () {
      expect(
        core.getInput(
          name: 'missing',
          options: const core.InputOptions(required: false),
        ),
        equals(''),
      );
    });

    test('getInput is case insensitive', () {
      expect(core.getInput(name: 'My InPuT'), equals('val'));
    });

    test('getInput handles special characters', () {
      expect(
        core.getInput(name: 'special chars_\'\t"\\'),
        equals('\'\t"\\ response'),
      );
    });

    test('getInput handles multiple spaces', () {
      expect(
        core.getInput(name: 'multiple spaces variable'),
        equals('I have multiple spaces'),
      );
    });

    test('getInput trims whitespace by default', () {
      expect(
        core.getInput(name: 'with trailing whitespace'),
        equals('some val'),
      );
    });

    test('getInput trims whitespace when option is explicitly true', () {
      expect(
        core.getInput(
          name: 'with trailing whitespace',
          options: const core.InputOptions(trimWhitespace: true),
        ),
        equals('some val'),
      );
    });
    test('getInput does not trim whitespace when option is false', () {
      expect(
        core.getInput(
          name: 'with trailing whitespace',
          options: const core.InputOptions(trimWhitespace: false),
        ),
        equals('  some val  '),
      );
    });

    test('getInput gets non-required boolean input', () {
      expect(core.getBooleanInput(name: 'boolean input'), isTrue);
    });

    test('getInput gets required input', () {
      expect(
        core.getBooleanInput(
          name: 'boolean input',
          options: const core.InputOptions(required: true),
        ),
        isTrue,
      );
    });

    test('getMultilineInput works', () {
      expect(
        core.getMultilineInput(name: 'my input list'),
        equals(['val1', 'val2', 'val3']),
      );
    });

    test('getBooleanInput handles boolean input', () {
      expect(core.getBooleanInput(name: 'boolean input true1'), isTrue);
      expect(core.getBooleanInput(name: 'boolean input true2'), isTrue);
      expect(core.getBooleanInput(name: 'boolean input true3'), isTrue);
      expect(core.getBooleanInput(name: 'boolean input false1'), isFalse);
      expect(core.getBooleanInput(name: 'boolean input false2'), isFalse);
      expect(core.getBooleanInput(name: 'boolean input false3'), isFalse);
    });

    test('getBooleanInput handles wrong boolean input', () {
      expect(
        () => core.getBooleanInput(name: 'wrong boolean input'),
        throwsStateError,
      );
    });

    test('setOutput produces the correct command', () {
      core.setOutput(name: 'some output', value: 'some value');

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals(['', '::set-output name=some output::some value']),
      );
    });

    test('setOutput handles bools', () {
      core.setOutput(name: 'some output', value: false);

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals(['', '::set-output name=some output::false']),
      );
    });

    test('setOutput handles numbers', () {
      core.setOutput(name: 'some output', value: 1.01);

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals(['', '::set-output name=some output::1.01']),
      );
    });

    test('setCommandEcho can enable echoing', () {
      core.setCommandEcho(enabled: true);

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::echo::on'),
      );
    });

    test('setCommandEcho can disable echoing', () {
      core.setCommandEcho(enabled: false);

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::echo::off'),
      );
    });

    test('setFailed sets the correct exit code and failure message', () {
      core.setFailed(message: 'Failure message');
      expect(exitCode, equals(1));

      core.setFailed(message: 'Failure \r\n\nmessage\r');

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals([
          '::error::Failure message',
          '::error::Failure %0D%0A%0Amessage%0D',
        ]),
      );
    });

    test('isDebug check debug state', () {
      core.setupEnvironmentVariables({});
      expect(core.isDebug(), isFalse);

      core.setupEnvironmentVariables({'RUNNER_DEBUG': '1'});
      expect(core.isDebug(), isTrue);
    });

    test('debug logs passed message', () {
      core.debug(message: '');
      core.debug(message: 'Debug');
      core.debug(message: '\r\ndebug\n');
      core.debug(message: '');

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals([
          '::debug::',
          '::debug::Debug',
          '::debug::%0D%0Adebug%0A',
          '::debug::',
        ]),
      );
    });

    test('error logs passed message', () {
      core.error(message: '');
      core.error(message: 'Error message');
      core.error(message: 'Error message\r\n\n');
      core.error(message: '');
      core.error(
        message: 'this is my error message',
        properties: const AnnotationProperties(
          title: 'A title',
          file: 'root/test.txt',
          startLine: 5,
          endLine: 5,
          startColumn: 1,
          endColumn: 2,
        ),
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals([
          '::error::',
          '::error::Error message',
          '::error::Error message%0D%0A%0A',
          '::error::',
          '::error title=A title,file=root/test.txt,line=5,endLine=5,col=1,endColumn=2::this is my error message',
        ]),
      );
    });

    test('warning logs passed message', () {
      core.warning(message: '');
      core.warning(message: 'Warning');
      core.warning(message: '\r\nwarning\n');
      core.warning(message: '');
      core.warning(
        message: 'this is my warning message',
        properties: const AnnotationProperties(
          title: 'A title',
          file: 'root/test.txt',
          startLine: 5,
          endLine: 5,
          startColumn: 1,
          endColumn: 2,
        ),
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals([
          '::warning::',
          '::warning::Warning',
          '::warning::%0D%0Awarning%0A',
          '::warning::',
          '::warning title=A title,file=root/test.txt,line=5,endLine=5,col=1,endColumn=2::this is my warning message',
        ]),
      );
    });

    test('notice logs passed message', () {
      core.notice(message: '');
      core.notice(message: 'Notice');
      core.notice(message: '\r\nnotice\n');
      core.notice(message: '');
      core.notice(
        message: 'this is my notice message',
        properties: const AnnotationProperties(
          title: 'A title',
          file: 'root/test.txt',
          startLine: 5,
          endLine: 5,
          startColumn: 1,
          endColumn: 2,
        ),
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals([
          '::notice::',
          '::notice::Notice',
          '::notice::%0D%0Anotice%0A',
          '::notice::',
          '::notice title=A title,file=root/test.txt,line=5,endLine=5,col=1,endColumn=2::this is my notice message',
        ]),
      );
    });

    test('info logs passed message', () {
      core.info(message: '');
      core.info(message: 'Info');
      core.info(message: '');

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals(['', 'Info', '']),
      );
    });

    test('startGroup starts a new group', () {
      core.startGroup(name: 'my-group');

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::group::my-group'),
      );
    });

    test('endGroup ends new group', () {
      core.endGroup();

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::endgroup::'),
      );
    });

    test('group wraps an async call in a group', () async {
      final result = await core.group(
        name: 'mygroup',
        fn: () async {
          core.info(message: 'in my group\n');

          return true;
        },
      );

      expect(result, isTrue);
      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals(['::group::mygroup', 'in my group\n', '::endgroup::']),
      );
    });

    test('saveState produces the correct command', () {
      core.saveState(name: 'state_1', value: 'some value');

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::save-state name=state_1::some value'),
      );
    });

    test('saveState handles numbers', () {
      core.saveState(name: 'state_1', value: 1);

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::save-state name=state_1::1'),
      );
    });

    test('saveState handles bools', () {
      core.saveState(name: 'state_1', value: true);

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::save-state name=state_1::true'),
      );
    });

    test('getState gets wrapper action state', () {
      expect(
        core.getState(name: 'TEST_1'),
        equals('state_val'),
      );
    });
  });
}
