class ReceiptLine {
  ReceiptLine({this.count = 1, this.useDashed = false});

  final int count;
  final bool useDashed;

  String get html {
    String concatHtml = '';
    for (int i = 0; i < count; i++) {
      concatHtml += useDashed ? _dashedLine : _emptyLine;
    }
    return concatHtml;
  }

  String get _dashedLine => '''
    <hr>
    ''';

  String get _emptyLine => '''
    <br>
    ''';
}
