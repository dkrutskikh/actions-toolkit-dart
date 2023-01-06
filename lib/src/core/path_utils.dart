import 'package:path/path.dart' as p;

/// Converts the given path to the posix form.
///
/// On Windows, `\` will be replaced with `/`.
String toPosixPath(String pth) => pth.replaceAll(r'\', '/');

/// Converts the given path to the win32 form.
///
/// On Linux or MacOS, `/` will be replaced with `\`.
String toWin32Path(String pth) => pth.replaceAll('/', r'\');

/// Converts the given path to a platform-specific path.
///
/// It does this by replacing instances of `/` and `\` with the
/// platform-specific path separator.
String toPlatformPath(String pth) {
  final separator = p.separator;

  return pth.replaceAll(r'\', separator).replaceAll('/', separator);
}
