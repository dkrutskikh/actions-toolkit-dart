class SummaryTableCell {
  /// Cell content.
  final String data;

  /// Render cell as header.
  final bool header;

  /// Number of columns the cell extends.
  final int? columns;

  /// Number of rows the cell extends.
  final int? rows;

  const SummaryTableCell({
    required this.data,
    this.header = false,
    this.columns,
    this.rows,
  });
}
