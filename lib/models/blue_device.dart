class BlueDevice {
  BlueDevice({
    this.name,
    this.address,
    this.connected = false,
    this.type = 0,
  });

  final String name;
  final String address;
  int type;
  bool connected;
}
