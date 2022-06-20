import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'blue_print_pos_platform_interface.dart';

/// An implementation of [BluePrintPosPlatform] that uses method channels.
class MethodChannelBluePrintPos extends BluePrintPosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('blue_print_pos');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
