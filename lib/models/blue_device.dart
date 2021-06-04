class BlueDevice {
  BlueDevice({
    required this.name,
    required this.address,
    this.connected = false,
    this.type = 0,
  });

  final String name;
  final String address;
  int type;
  bool connected;
}
