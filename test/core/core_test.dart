@TestOn('vm')
import 'dart:io';

import 'package:actions_toolkit_dart/src/core/core.dart' as core;
import 'package:actions_toolkit_dart/src/core/environment_variables.dart'
    as core;
import 'package:actions_toolkit_dart/src/core/output.dart' as core;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class IOSinkMock extends Mock implements IOSink {}

const message = 'simple message';

void main() {
  group('core', () {
    setUp(() {
      core.setupOutput(IOSinkMock());
    });

    test('isDebug check debug state', () {
      core.setupEnvironmentVariables({});
      expect(core.isDebug(), isFalse);

      core.setupEnvironmentVariables({'RUNNER_DEBUG': '1'});
      expect(core.isDebug(), isTrue);
    });

    test('debug logs passed message', () {
      core.debug('');
      core.debug('Debug');
      core.debug('\r\ndebug\n');
      core.debug('');

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
      core.error('');
      core.error('Error message');
      core.error('Error message\r\n\n');
      core.error('');

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals([
          '::error::',
          '::error::Error message',
          '::error::Error message%0D%0A%0A',
          '::error::',
        ]),
      );
    });

    test('warning logs passed message', () {
      core.warning('');
      core.warning('Warning');
      core.warning('\r\nwarning\n');
      core.warning('');

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals([
          '::warning::',
          '::warning::Warning',
          '::warning::%0D%0Awarning%0A',
          '::warning::',
        ]),
      );
    });

    test('info logs passed message', () {
      core.info('');
      core.info('Info');
      core.info('');

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals(['', 'Info', '']),
      );
    });

    test('startGroup starts a new group', () {
      core.startGroup('my-group');

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
      final result = await core.group('mygroup', () async {
        core.info('in my group\n');

        return true;
      });

      expect(result, isTrue);
      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals(['::group::mygroup', 'in my group\n', '::endgroup::']),
      );
    });
  });
}
