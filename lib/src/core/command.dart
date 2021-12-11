import 'output.dart';
import 'utils.dart';

void issueCommand(
  String command,
  Map<String, Object> properties,
  String message,
) {
  final cmd = Command(command, properties, message);
  output.writeln(cmd.toString());
}

void issue(String name, [String message = '']) {
  issueCommand(name, {}, message);
}

/// Representation of GitHub action command
///
/// Command Format:
/// ```
///   ::name key=value,key=value::message
/// ```
///
/// Examples:
/// ```
///   ::warning::This is the message
///   ::set-env name=MY_VAR::some value
/// ```
class Command {
  final String command;
  final String message;
  final Map<String, Object> properties;

  Command(String command, this.properties, this.message)
      : command = command.isNotEmpty ? command : 'missing.command';

  @override
  String toString() {
    const cmdString = '::';

    final cmdStr = StringBuffer()
      ..write(cmdString)
      ..write(command);

    if (properties.isNotEmpty) {
      cmdStr
        ..write(' ')
        ..write(properties.entries
            .map((prop) => '${prop.key}=${escapeProperty(prop.value)}')
            .join(','));
    }

    cmdStr.write('$cmdString${escapeData(message)}');

    return cmdStr.toString();
  }
}

String escapeData(Object? s) => toCommandValue(s)
    .replaceAll('%', '%25')
    .replaceAll('\r', '%0D')
    .replaceAll('\n', '%0A');

String escapeProperty(Object? s) => toCommandValue(s)
    .replaceAll('%', '%25')
    .replaceAll('\r', '%0D')
    .replaceAll('\n', '%0A')
    .replaceAll(':', '%3A')
    .replaceAll(',', '%2C');
