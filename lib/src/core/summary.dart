import 'dart:io';

import 'models/summary_image_options.dart';
import 'models/summary_table_cell.dart';
import 'utils/summary_filepath.dart';

class Summary {
  final _buffer = StringBuffer();

  final SummaryFilePath _filePath;

  Summary({SummaryFilePath? filePath})
      : _filePath = filePath ?? SummaryFilePath();

  /// Writes text in the buffer to the summary buffer file and empties buffer.
  ///
  /// Will append by default.
  void write({bool overwrite = false}) {
    File(_filePath.path()).writeAsStringSync(
      _buffer.toString(),
      mode: overwrite ? FileMode.writeOnly : FileMode.append,
    );

    _buffer.clear();
  }

  /// Clears the summary buffer and wipes the summary file.
  void clear() {
    emptyBuffer();
    write(overwrite: true);
  }

  /// Returns the current summary buffer as a string.
  @override
  String toString() => _buffer.toString();

  /// If the summary buffer is empty.
  bool isEmptyBuffer() => _buffer.isEmpty;

  /// Resets the summary buffer without writing to summary file.
  void emptyBuffer() {
    _buffer.clear();
  }

  /// Adds raw [text] to the summary buffer
  ///
  /// [addEOL] append an EOL to the raw text
  void addRaw(String text, {bool addEOL = false}) {
    if (addEOL) {
      _buffer.writeln(text);
    } else {
      _buffer.write(text);
    }
  }

  /// Adds the operating system-specific end-of-line marker to the buffer.
  void addEOL() {
    addRaw('', addEOL: true);
  }

  /// Adds an HTML [codeblock] to the summary buffer.
  void addCodeBlock(String codeblock, [String? lang]) {
    final attributes = {
      if (lang != null) 'lang': lang,
    };

    final element = _wrap(
      tag: 'pre',
      content: _wrap(tag: 'code', content: codeblock),
      attributes: attributes,
    );

    return addRaw(element, addEOL: true);
  }

  /// Adds an HTML [items] list to the summary buffer.
  void addList(Iterable<String> items, {bool ordered = false}) {
    final listItems =
        items.map((item) => _wrap(tag: 'li', content: item)).join('');

    addRaw(_wrap(tag: ordered ? 'ol' : 'ul', content: listItems), addEOL: true);
  }

  /// Adds an HTML table to the summary buffer.
  void addTable(Iterable<Iterable<SummaryTableCell>> rows) {
    final tableBody = rows.map((row) {
      final cells = row.map((cell) {
        final tag = cell.header ? 'th' : 'td';

        final attributes = {
          if (cell.columns != null) 'colspan': '${cell.columns}',
          if (cell.rows != null) 'rowspan': '${cell.rows}',
        };

        return _wrap(tag: tag, content: cell.data, attributes: attributes);
      }).join('');

      return _wrap(tag: 'tr', content: cells);
    }).join('');

    addRaw(_wrap(tag: 'table', content: tableBody), addEOL: true);
  }

  /// Adds a collapsible HTML details element to the summary buffer.
  void addDetails(String label, String content) {
    final element = _wrap(
      tag: 'details',
      content: '${_wrap(tag: 'summary', content: label)}$content',
    );

    addRaw(element, addEOL: true);
  }

  /// Adds an HTML image tag to the summary buffer.
  void addImage(String src, String alt, {SummaryImageOptions? options}) {
    final width = options?.width;
    final height = options?.height;

    final attributes = {
      'src': src,
      'alt': alt,
      if (width != null) 'width': '$width',
      if (height != null) 'height': '$height',
    };

    addRaw(_wrap(tag: 'img', attributes: attributes), addEOL: true);
  }

  /// Adds an HTML section heading element.
  void addHeading(String text, {int level = 1}) {
    const allowedTags = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

    final tag = allowedTags.contains('h$level') ? 'h$level' : allowedTags.first;

    addRaw(_wrap(tag: tag, content: text), addEOL: true);
  }

  /// Adds an HTML thematic break (<hr>) to the summary buffer.
  void addSeparator() {
    addRaw(_wrap(tag: 'hr'), addEOL: true);
  }

  /// Adds an HTML line break (<br>) to the summary buffer.
  void addBreak() {
    addRaw(_wrap(tag: 'br'), addEOL: true);
  }

  /// Adds an HTML blockquote to the summary buffer.
  void addQuote(String text, {String? citation}) {
    final attributes = {
      if (citation != null) 'cite': citation,
    };

    addRaw(
      _wrap(tag: 'blockquote', content: text, attributes: attributes),
      addEOL: true,
    );
  }

  /// Adds an HTML anchor tag to the summary buffer.
  void addLink(String text, String href) {
    addRaw(
      _wrap(tag: 'a', content: text, attributes: {'href': href}),
      addEOL: true,
    );
  }

  /// Wraps [content] in an HTML [tag], adding any HTML attributes.
  String _wrap({
    required String tag,
    String? content,
    Map<String, String> attributes = const {},
  }) {
    final htmlAttributes = attributes.entries
        .map((entry) => ' ${entry.key}="${entry.value}"')
        .join('');

    return content != null
        ? '<$tag$htmlAttributes>$content</$tag>'
        : '<$tag$htmlAttributes>';
  }
}
