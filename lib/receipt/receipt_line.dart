class ReceiptLine {
  ReceiptLine({this.count = 1, this.useDashed = false});

  /// [count] to decide how much line without are used, empty or dashed line
  final int count;

  /// [useDashed] to use empty or dashed line style. Default value is false
  final bool useDashed;

  /// Get the tag of html, empty line use <br> and dashed line use <hr>
  /// For loop will generate how much line will printed
  String get html {
    String concatHtml = '';
    for (int i = 0; i < count; i++) {
      concatHtml += useDashed ? _dashedLine : _emptyLine;
    }
    return concatHtml;
  }

  /// Tag <hr>
  String get _dashedLine => '''
    <hr>
    ''';

  /// <br>
  String get _emptyLine => '''
    <br>
    ''';
}
