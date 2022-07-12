[![Build Status](https://shields.io/github/workflow/status/dkrutskikh/actions-toolkit-dart/build?logo=github&logoColor=white)](https://github.com/dkrutskikh/actions-toolkit-dart/)
[![Coverage Status](https://img.shields.io/codecov/c/github/dkrutskikh/actions-toolkit-dart?logo=codecov&logoColor=white)](https://codecov.io/gh/dkrutskikh/actions-toolkit-dart/)
[![Pub Version](https://img.shields.io/pub/v/actions_toolkit_dart?logo=dart&logoColor=white)](https://pub.dev/packages/actions_toolkit_dart/)
[![Dart SDK Version](https://badgen.net/pub/sdk-version/actions_toolkit_dart)](https://pub.dev/packages/actions_toolkit_dart/)
[![License](https://img.shields.io/github/license/dkrutskikh/actions-toolkit-dart)](https://github.com/dkrutskikh/actions-toolkit-dart/blob/master/LICENSE)
[![Pub popularity](https://badgen.net/pub/popularity/actions_toolkit_dart)](https://pub.dev/packages/actions_toolkit_dart/score)
[![GitHub popularity](https://img.shields.io/github/stars/dkrutskikh/actions-toolkit-dart?logo=github&logoColor=white)](https://github.com/dkrutskikh/actions-toolkit-dart/stargazers)

# Actions Toolkit for Dart

A third-party toolkit for [GitHub Actions](https://help.github.com/en/actions) written in Dart. This is port of the official [`actions/toolkit`](https://github.com/actions/toolkit/).

## core

> Core functions for setting results, logging, registering secrets and exporting variables across actions.

### Usage

#### Installation

```sh
$ dart pub add actions_toolkit_dart
```

**OR**

add it manually to `pubspec.yaml`

```yaml
dependencies:
  actions_toolkit_dart: ^0.5.1
```

#### Import the package

```dart
import 'package:actions_toolkit_dart/core.dart' as core;
```

##### Inputs/Outputs

Action inputs can be read with `getInput` which returns a `string` or `getBooleanInput` which parses a boolean based on the [YAML 1.2 specification](https://yaml.org/spec/1.2/spec.html#id2804923). If `required` set to be false, the input should have a default value in `action.yml`.

Outputs can be set with `setOutput` which makes them available to be mapped into inputs of other actions to ensure they are decoupled.

```dart
final myInput = core.getInput(name: 'inputName', options: const core.InputOptions(required: true));
final myBooleanInput = core.getBooleanInput(name: 'booleanInputName', options: const core.InputOptions(required: true));
final myMultilineInput = core.getMultilineInput(name: 'multilineInputName', options: const core.InputOptions(required: true));

core.setOutput(name: 'outputKey', value: 'outputVal');
```

##### Exporting variables

Since each step runs in a separate process, you can use `exportVariable` to add it to this step and future steps environment blocks.

```dart
core.exportVariable(name: 'envVar', value: 'Val');
```

##### Setting a secret

Setting a secret registers the secret with the runner to ensure it is masked in logs.

```dart
core.setSecret('myPassword');
```

##### PATH Manipulation

To make a tool's path available in the path for the remainder of the job (without altering the machine or containers state), use `addPath`.  The runner will prepend the path given to the jobs PATH.

```dart
core.addPath('/path/to/my_tool');
```

##### Exit codes

You should use this library to set the failing exit code for your action.  If status is not set and the script runs to completion, that will lead to a success.

```dart
try {
  // Do stuff
}
catch (err) {
  // setFailed logs the message and sets a failing exit code
  core.setFailed('Action failed with error $err');
}
```

##### Logging

```dart
import 'package:actions_toolkit_dart/core.dart' as core;

try {
  core.debug('Inside try block');

  core.warning('myInput was not set');

  if (core.isDebug()) {
    // curl -v https://github.com
  } else {
    // curl https://github.com
  }

  // Do stuff
  core.info('Output to the actions build log');

  core.notice('This is a message that will also emit an annotation');
}
catch (err) {
  core.error('Error $err, action may still succeed though');
}
```

This library can also wrap chunks of output in foldable groups.

```dart
import 'package:actions_toolkit_dart/core.dart' as core;

// Manually wrap output
core.startGroup('Do some function');
doSomeFunction();
core.endGroup();

// Wrap an asynchronous function call
const result = await core.group('Do something async', () async {
  const response = await doSomeHTTPRequest();
  return response;
});
```

##### Annotations

This library has 3 methods that will produce [annotations](https://docs.github.com/en/rest/reference/checks#create-a-check-run).

```dart
core.error('This is a bad error. This will also fail the build.');

core.warning("Something went wrong, but it's not bad enough to fail the build.");

core.notice('Something happened that you might want to know about.');
```

These will surface to the UI in the Actions page and on Pull Requests.
