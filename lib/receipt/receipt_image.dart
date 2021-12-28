import 'collection_style.dart';
import 'receipt.dart';

class ReceiptImage {
  ReceiptImage(
    this.data, {
    this.alignment = ReceiptAlignment.center,
    this.width = 120,
  });

  final String data;
  final int width;
  final ReceiptAlignment alignment;

  String get html => '''
    <div class="$_alignmentStyleHTML">
      <img src ="data:image/png;base64,$data" width="$width"/>
    </div>
    ''';

  String get _alignmentStyleHTML {
    if (alignment == ReceiptAlignment.left) {
      return CollectionStyle.textLeft;
    } else if (alignment == ReceiptAlignment.right) {
      return CollectionStyle.textRight;
    }
    return CollectionStyle.textCenter;
  }
}
