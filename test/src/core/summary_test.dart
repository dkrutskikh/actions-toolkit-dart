import 'dart:io';

import 'package:actions_toolkit_dart/src/core/models/summary_image_options.dart';
import 'package:actions_toolkit_dart/src/core/models/summary_table_cell.dart';
import 'package:actions_toolkit_dart/src/core/summary.dart';
import 'package:actions_toolkit_dart/src/core/utils/summary_filepath.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class SummaryFilePathMock extends Mock implements SummaryFilePath {}

const testFilePath = 'test-summary.md';

const fixturesText = 'hello world 🌎';
const fixturesCode = '''
func fork() {
  for {
    go fork()
  }
}''';
const fixtureList = ['foo', 'bar', 'baz', '💣'];
const fixturesTable = [
  [
    SummaryTableCell(data: 'foo', header: true),
    SummaryTableCell(data: 'bar', header: true),
    SummaryTableCell(data: 'baz', header: true),
    SummaryTableCell(data: 'tall', rows: 3),
  ],
  [
    SummaryTableCell(data: 'one'),
    SummaryTableCell(data: 'two'),
    SummaryTableCell(data: 'three'),
  ],
  [
    SummaryTableCell(data: 'wide', columns: 3),
  ],
];
const fixturesDetailsLabel = 'open me';
const fixturesDetailsContent = '🎉 surprise';
const fixturesImgSrc = 'https://github.com/actions.png';
const fixturesImgAlt = 'actions logo';
const fixturesImgOptions = SummaryImageOptions(width: 32, height: 32);
const fixturesQuoteText = 'Where the world builds software';
const fixturesQuoteCitation = 'https://github.com/about';
const fixturesLinkText = 'GitHub';
const fixturesLinkHref = 'https://github.com/';

void main() {
  group('Summary', () {
    late Summary summary;
    late File summaryFile;

    setUp(() {
      final filePath = SummaryFilePathMock();

      when(filePath.path).thenReturn(testFilePath);

      summary = Summary(filePath: filePath);

      summaryFile = File(testFilePath)..createSync();
    });

    test('appends text to summary file', () {
      summaryFile.writeAsStringSync('# ');

      summary
        ..addRaw(fixturesText)
        ..write();

      expect(summaryFile.readAsStringSync(), equals('# $fixturesText'));
    });

    test('overwrites text to summary file', () {
      summaryFile.writeAsStringSync('# ');

      summary
        ..addRaw(fixturesText)
        ..write(overwrite: true);

      expect(summaryFile.readAsStringSync(), equals(fixturesText));
    });

    test('appends text with EOL to summary file', () {
      summaryFile.writeAsStringSync('# ');

      summary
        ..addRaw(fixturesText, addEOL: true)
        ..write(overwrite: true);

      expect(summaryFile.readAsStringSync(), equals('$fixturesText\n'));
    });

    test('chains appends text to summary file', () {
      summary
        ..addRaw(fixturesText)
        ..addRaw(fixturesText)
        ..addRaw(fixturesText)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals([fixturesText, fixturesText, fixturesText].join('')),
      );
    });

    test('empties buffer after write', () {
      summary
        ..addRaw(fixturesText)
        ..write();

      expect(summaryFile.readAsStringSync(), equals(fixturesText));

      expect(summary.isEmptyBuffer(), isTrue);
    });

    test('returns summary buffer as string', () {
      summary.addRaw(fixturesText);

      expect(summary.toString(), equals(fixturesText));
    });

    test('return correct values for isEmptyBuffer', () {
      summary.addRaw(fixturesText);
      expect(summary.isEmptyBuffer(), isFalse);

      summary.emptyBuffer();
      expect(summary.isEmptyBuffer(), isTrue);
    });

    test('clears a buffer and summary file', () {
      summaryFile.writeAsStringSync('content');

      summary.clear();

      expect(summary.isEmptyBuffer(), isTrue);
      expect(summaryFile.readAsStringSync(), isEmpty);
    });

    test('adds EOL', () {
      summary
        ..addRaw(fixturesText)
        ..addEOL()
        ..write();

      expect(summaryFile.readAsStringSync(), equals('$fixturesText\n'));
    });

    test('adds a code block without language', () {
      summary
        ..addCodeBlock(fixturesCode)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals(
          '<pre><code>func fork() {\n  for {\n    go fork()\n  }\n}</code></pre>\n',
        ),
      );
    });

    test('adds a code block with a language', () {
      summary
        ..addCodeBlock(fixturesCode, 'go')
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals(
          '<pre lang="go"><code>func fork() {\n  for {\n    go fork()\n  }\n}</code></pre>\n',
        ),
      );
    });

    test('adds an unordered list', () {
      summary
        ..addList(fixtureList)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals('<ul><li>foo</li><li>bar</li><li>baz</li><li>💣</li></ul>\n'),
      );
    });

    test('adds an ordered list', () {
      summary
        ..addList(fixtureList, ordered: true)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals('<ol><li>foo</li><li>bar</li><li>baz</li><li>💣</li></ol>\n'),
      );
    });

    test('adds a table', () {
      summary
        ..addTable(fixturesTable)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals(
          '<table><tr><th>foo</th><th>bar</th><th>baz</th><td rowspan="3">tall</td></tr><tr><td>one</td><td>two</td><td>three</td></tr><tr><td colspan="3">wide</td></tr></table>\n',
        ),
      );
    });

    test('adds a details element', () {
      summary
        ..addDetails(fixturesDetailsLabel, fixturesDetailsContent)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals('<details><summary>open me</summary>🎉 surprise</details>\n'),
      );
    });

    test('adds an image with alt text', () {
      summary
        ..addImage(fixturesImgSrc, fixturesImgAlt)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals(
          '<img src="https://github.com/actions.png" alt="actions logo">\n',
        ),
      );
    });

    test('adds an image with custom dimensions', () {
      summary
        ..addImage(fixturesImgSrc, fixturesImgAlt, options: fixturesImgOptions)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals(
          '<img src="https://github.com/actions.png" alt="actions logo" width="32" height="32">\n',
        ),
      );
    });

    test('adds headings h1...h6', () {
      for (final level in [1, 2, 3, 4, 5, 6]) {
        summary.addHeading('heading', level: level);
      }
      summary.write();

      expect(
        summaryFile.readAsStringSync(),
        equals(
          '<h1>heading</h1>\n<h2>heading</h2>\n<h3>heading</h3>\n<h4>heading</h4>\n<h5>heading</h5>\n<h6>heading</h6>\n',
        ),
      );
    });

    test('adds h1 if heading level not specified', () {
      summary
        ..addHeading('heading')
        ..write();

      expect(summaryFile.readAsStringSync(), equals('<h1>heading</h1>\n'));
    });

    test('uses h1 if heading level is garbage or out of range', () {
      summary
        ..addHeading('heading')
        ..addHeading('heading', level: 1337)
        ..addHeading('heading', level: -1)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals('<h1>heading</h1>\n<h1>heading</h1>\n<h1>heading</h1>\n'),
      );
    });

    test('adds a separator', () {
      summary
        ..addSeparator()
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals('<hr>\n'),
      );
    });

    test('adds a break', () {
      summary
        ..addBreak()
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals('<br>\n'),
      );
    });

    test('adds a quote', () {
      summary
        ..addQuote(fixturesQuoteText)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals('<blockquote>Where the world builds software</blockquote>\n'),
      );
    });

    test('adds a quote with citation', () {
      summary
        ..addQuote(fixturesQuoteText, citation: fixturesQuoteCitation)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals(
          '<blockquote cite="https://github.com/about">Where the world builds software</blockquote>\n',
        ),
      );
    });

    test('adds a link with href', () {
      summary
        ..addLink(fixturesLinkText, fixturesLinkHref)
        ..write();

      expect(
        summaryFile.readAsStringSync(),
        equals('<a href="https://github.com/">GitHub</a>\n'),
      );
    });

    tearDown(() {
      summaryFile.deleteSync();
    });
  });
}
