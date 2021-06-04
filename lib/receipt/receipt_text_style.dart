enum ReceiptTextStyleType { normal, bold }

enum ReceiptTextSizeType { small, medium, large, extraLarge }

class ReceiptTextStyle {
  const ReceiptTextStyle({
    this.type = ReceiptTextStyleType.normal,
    this.size = ReceiptTextSizeType.medium,
    this.useSpan = false,
  });

  final ReceiptTextStyleType type;
  final ReceiptTextSizeType size;
  final bool useSpan;

  String get textStyleHTML {
    if (useSpan) {
      return type == ReceiptTextStyleType.normal ? 'span' : 'b';
    }
    return type == ReceiptTextStyleType.normal ? 'p' : 'b';
  }

  String get textSizeHtml {
    switch (size) {
      case ReceiptTextSizeType.small:
        return 'text-small';
      case ReceiptTextSizeType.medium:
        return 'text-medium';
      case ReceiptTextSizeType.large:
        return 'text-large';
      case ReceiptTextSizeType.extraLarge:
        return 'text-extra-large';
      default:
        return 'text-medium';
    }
  }
}
