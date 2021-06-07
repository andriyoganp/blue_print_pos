import 'dart:io';

import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue_thermal;
import 'package:flutter_blue/flutter_blue.dart' as flutter_blue;

/// This class with static method to handler scanning in Android and iOS
class BlueScanner {
  const BlueScanner._();

  /// Provide list of bluetooth device, return as list of [BlueDevice]
  static Future<List<BlueDevice>> scan() async {
    List<BlueDevice> devices = <BlueDevice>[];
    if (Platform.isAndroid) {
      final blue_thermal.BlueThermalPrinter bluetoothAndroid =
          blue_thermal.BlueThermalPrinter.instance;
      final List<blue_thermal.BluetoothDevice> resultDevices =
          await bluetoothAndroid.getBondedDevices();
      devices = resultDevices
          .map(
            (blue_thermal.BluetoothDevice bluetoothDevice) => BlueDevice(
              name: bluetoothDevice.name ?? '',
              address: bluetoothDevice.address ?? '',
              type: bluetoothDevice.type,
            ),
          )
          .toList();
    } else if (Platform.isIOS) {
      final flutter_blue.FlutterBlue bluetoothIOS =
          flutter_blue.FlutterBlue.instance;
      final List<flutter_blue.BluetoothDevice> resultDevices =
          <flutter_blue.BluetoothDevice>[];

      await bluetoothIOS.startScan(
        timeout: const Duration(seconds: 5),
      );
      bluetoothIOS.scanResults
          .listen((List<flutter_blue.ScanResult> scanResults) {
        for (final flutter_blue.ScanResult scanResult in scanResults) {
          resultDevices.add(scanResult.device);
        }
      });

      await bluetoothIOS.stopScan();
      devices = resultDevices
          .toSet()
          .toList()
          .map(
            (flutter_blue.BluetoothDevice bluetoothDevice) => BlueDevice(
              address: bluetoothDevice.id.id,
              name: bluetoothDevice.name,
              type: bluetoothDevice.type.index,
            ),
          )
          .toList();
    }
    return devices;
  }
}
