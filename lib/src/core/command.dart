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

class Command {
  final String command;
  final String message;
  final Map<String, Object> properties;

  Command(String command, this.properties, this.message)
      : command = command.isNotEmpty ? command : 'missing.command';

  @override
  String toString() {
    const cmdString = '::';

    final cmdStr = StringBuffer()..write(cmdString)..write(command);

    if (properties.isNotEmpty) {
      cmdStr.write(' ');
      var first = true;
      for (final entry in properties.entries) {
        if (first) {
          first = false;
        } else {
          cmdStr.write(',');
        }

        cmdStr.write('${entry.key}=${escapeProperty(entry.value)}');
      }
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
