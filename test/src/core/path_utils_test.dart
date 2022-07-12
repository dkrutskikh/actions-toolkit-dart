@TestOn('vm')

import 'package:actions_toolkit_dart/src/core/path_utils.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Path utils', () {
    test('toPosixPath return given path in posix style', () {
      expect(toPosixPath(''), equals(''));

      expect(toPosixPath('foo'), equals('foo'));

      expect(toPosixPath('foo/bar/baz'), equals('foo/bar/baz'));

      expect(toPosixPath('/foo/bar/baz'), equals('/foo/bar/baz'));

      expect(toPosixPath(r'\foo\bar\baz'), equals('/foo/bar/baz'));

      expect(toPosixPath(r'\foo/bar/baz'), equals('/foo/bar/baz'));
    });

    test('toWin32Path return given path in posix style', () {
      expect(toWin32Path(''), equals(''));

      expect(toWin32Path('foo'), equals('foo'));

      expect(toWin32Path('foo/bar/baz'), equals(r'foo\bar\baz'));

      expect(toWin32Path('/foo/bar/baz'), equals(r'\foo\bar\baz'));

      expect(toWin32Path(r'foo\bar\baz'), equals(r'foo\bar\baz'));

      expect(toWin32Path(r'\foo\bar\baz'), equals(r'\foo\bar\baz'));

      expect(toWin32Path(r'\foo/bar\baz'), equals(r'\foo\bar\baz'));
    });

    test('toPlatformPath return given path in posix style', () {
      expect(toPlatformPath(''), equals(''));

      expect(toPlatformPath('foo'), equals('foo'));

      expect(
        toPlatformPath('foo/bar/baz'),
        equals(p.join('foo', 'bar', 'baz')),
      );

      expect(
        toPlatformPath('/foo/bar/baz'),
        equals(equals(p.join(p.separator, 'foo', 'bar', 'baz'))),
      );

      expect(
        toPlatformPath(r'foo\bar\baz'),
        equals(p.join('foo', 'bar', 'baz')),
      );

      expect(
        toPlatformPath(r'\foo\bar\baz'),
        equals(equals(p.join(p.separator, 'foo', 'bar', 'baz'))),
      );

      expect(
        toPlatformPath(r'\foo/bar\baz'),
        equals(equals(p.join(p.separator, 'foo', 'bar', 'baz'))),
      );
    });
  });
}
