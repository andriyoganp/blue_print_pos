import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// [WebcontentConverter] will convert into raw bytes image
class WebcontentConverter {
  WebcontentConverter._();

  static const MethodChannel _channel = MethodChannel('webcontent_converter');

  /// ## `WebcontentConverter.contentToImage`
  /// `This method use html content directly to convert html to List<Int> image`
  /// ### Example:
  /// ```
  /// final content = Demo.getReceiptContent();
  /// var bytes = await WebcontentConverter.contentToImage(content: content);
  /// if (bytes.length > 0){
  ///   var dir = await getTemporaryDirectory();
  ///   var path = join(dir.path, "receipt.jpg");
  ///   File file = File(path);
  ///   await file.writeAsBytes(bytes);
  /// }
  /// ```
  static Future<Uint8List> contentToImage({
    required String content,
    double duration = 2000,
    String? executablePath,
  }) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'content': content,
      'duration': duration
    };
    Uint8List results = Uint8List.fromList(<int>[]);
    try {
      results = await _channel.invokeMethod('contentToImage', arguments) ??
          Uint8List.fromList(<int>[]);
    } on Exception catch (e) {
      log('[method:contentToImage]: $e');
      throw Exception('Error: $e');
    }
    return results;
  }
}
