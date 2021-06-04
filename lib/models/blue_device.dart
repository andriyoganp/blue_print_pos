class BlueDevice {
  BlueDevice({
    required this.name,
    required this.address,
    this.connected = false,
    this.type = 0,
  });

  /// Name of bluetooth device, Android and iOS have same field name
  final String name;

  /// [address] value in Android get from model with same field name
  /// But in iOS get from id.id
  final String address;

  int? type;
  bool? connected;
}
