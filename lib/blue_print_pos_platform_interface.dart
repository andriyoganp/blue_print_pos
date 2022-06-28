import 'blue_print_pos_method_channel.dart';

abstract class BluePrintPosPlatform {
  /// Constructs a BluePrintPosPlatform.
  BluePrintPosPlatform() : super();

  static final Object _token = Object();

  static final BluePrintPosPlatform _instance = MethodChannelBluePrintPos();

  /// The default instance of [BluePrintPosPlatform] to use.
  ///
  /// Defaults to [MethodChannelBluePrintPos].
  static BluePrintPosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BluePrintPosPlatform] when
  /// they register themselves.

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
