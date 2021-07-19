@TestOn('vm')
import 'dart:io';

import 'package:actions_toolkit_dart/src/core/command.dart' as core;
import 'package:actions_toolkit_dart/src/core/output.dart' as core;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class IOSinkMock extends Mock implements IOSink {}

const message = 'simple message';

void main() {
  group('command', () {
    setUp(() {
      core.setupOutput(IOSinkMock());
    });

    test('command only', () {
      core.issueCommand('some-command', {}, '');

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::some-command::'),
      );
    });

    test('command escapes message', () {
      // Verify replaces each instance, not just first instance
      core.issueCommand(
        'some-command',
        {},
        'percent % percent % cr \r cr \r lf \n lf \n',
      );
      // Verify literal escape sequences
      core.issueCommand('some-command', {}, '%25 %25 %0D %0D %0A %0A');

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals([
          '::some-command::percent %25 percent %25 cr %0D cr %0D lf %0A lf %0A',
          '::some-command::%2525 %2525 %250D %250D %250A %250A',
        ]),
      );
    });

    test('command escapes property', () {
      // Verify replaces each instance, not just first instance
      core.issueCommand(
        'some-command',
        {
          'name':
              'percent % percent % cr \r cr \r lf \n lf \n colon : colon : comma , comma ,',
        },
        '',
      );
      // Verify literal escape sequences
      core.issueCommand(
        'some-command',
        {},
        '%25 %25 %0D %0D %0A %0A %3A %3A %2C %2C',
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured,
        equals([
          '::some-command name=percent %25 percent %25 cr %0D cr %0D lf %0A lf %0A colon %3A colon %3A comma %2C comma %2C::',
          '::some-command::%2525 %2525 %250D %250D %250A %250A %253A %253A %252C %252C',
        ]),
      );
    });

    test('command with message', () {
      core.issueCommand('some-command', {}, 'some message');

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::some-command::some message'),
      );
    });

    test('command with message and properties', () {
      core.issueCommand(
        'some-command',
        {'prop1': 'value 1', 'prop2': 'value 2'},
        'some message',
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::some-command prop1=value 1,prop2=value 2::some message'),
      );
    });

    test('command with one property', () {
      core.issueCommand('some-command', {'prop1': 'value 1'}, '');

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::some-command prop1=value 1::'),
      );
    });

    test('command with two properties', () {
      core.issueCommand(
        'some-command',
        {'prop1': 'value 1', 'prop2': 'value 2'},
        '',
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::some-command prop1=value 1,prop2=value 2::'),
      );
    });

    test('command with three properties', () {
      core.issueCommand(
        'some-command',
        {'prop1': 'value 1', 'prop2': 'value 2', 'prop3': 'value 3'},
        '',
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals('::some-command prop1=value 1,prop2=value 2,prop3=value 3::'),
      );
    });

    test('should handle issuing commands for non-string objects', () {
      core.issueCommand(
        'some-command',
        {
          'prop1': {'test': 'object'},
          'prop2': 123,
          'prop3': true,
        },
        '',
      );

      expect(
        verify(() => core.output.writeln(captureAny())).captured.single,
        equals(
          '::some-command prop1={"test"%3A"object"},prop2=123,prop3=true::',
        ),
      );
    });
    // 116
  });
}
