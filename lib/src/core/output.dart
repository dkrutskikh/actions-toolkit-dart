import 'dart:io';

import 'package:meta/meta.dart';

IOSink _output = stdout;
IOSink get output => _output;

@visibleForTesting
void setupOutput(IOSink newOutput) {
  _output = newOutput;
}
