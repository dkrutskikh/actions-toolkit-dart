[![Build Status](https://shields.io/github/workflow/status/dkrutskikh/actions-toolkit-dart/build?logo=github&logoColor=white)](https://github.com/dkrutskikh/actions-toolkit-dart/)
[![Coverage Status](https://img.shields.io/codecov/c/github/dkrutskikh/actions-toolkit-dart?logo=codecov&logoColor=white)](https://codecov.io/gh/dkrutskikh/actions-toolkit-dart/)
[![License](https://img.shields.io/github/license/dkrutskikh/actions-toolkit-dart)](https://github.com/dkrutskikh/actions-toolkit-dart/blob/master/LICENSE)

# Actions Toolkit for Dart

A third-party toolkit for [GitHub Actions](https://help.github.com/en/actions) written in Dart. This is port of the official [`actions/toolkit`](https://github.com/actions/toolkit/).

## core

> Core functions for setting results, logging, registering secrets and exporting variables across actions.

### Usage

#### Import the package

```dart
import 'package:actions_toolkit_dart/core.dart' as core;
```

##### Exit codes

You should use this library to set the failing exit code for your action.  If status is not set and the script runs to completion, that will lead to a success.

```dart
import 'package:actions_toolkit_dart/core.dart' as core;

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
