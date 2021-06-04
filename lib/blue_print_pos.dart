import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:blue_print_pos/models/connection_status.dart';
import 'package:blue_print_pos/models/models.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'package:blue_print_pos/scanner/blue_scanner.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter_blue/flutter_blue.dart' as flutter_blue;
import 'package:flutter_blue/gen/flutterblue.pb.dart' as proto;
import 'package:blue_thermal_printer/blue_thermal_printer.dart'
    as blue_thermal;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:webcontent_converter/webcontent_converter.dart';

class BluePrintPos {
  BluePrintPos() {
    _bluetoothAndroid = blue_thermal.BlueThermalPrinter.instance;
    _bluetoothIOS = flutter_blue.FlutterBlue.instance;
  }

  blue_thermal.BlueThermalPrinter _bluetoothAndroid;
  flutter_blue.FlutterBlue _bluetoothIOS;
  flutter_blue.BluetoothDevice _bluetoothDeviceIOS;
  bool isConnected = false;
  BlueDevice selectedDevice;

  Future<List<BlueDevice>> scan() async {
    return await BlueScanner.scan();
  }

  Future<ConnectionStatus> connect(BlueDevice device,
      {Duration timeout = const Duration(
        seconds: 5,
      )}) async {
    selectedDevice = device;
    try {
      if (Platform.isAndroid) {
        final blue_thermal.BluetoothDevice bluetoothDeviceAndroid =
            blue_thermal.BluetoothDevice(
                selectedDevice.name, selectedDevice.address);
        await _bluetoothAndroid.connect(bluetoothDeviceAndroid);
      } else if (Platform.isIOS) {
        _bluetoothDeviceIOS = flutter_blue.BluetoothDevice.fromProto(
          proto.BluetoothDevice(
            name: selectedDevice.name,
            remoteId: selectedDevice.address,
            type: proto.BluetoothDevice_Type.valueOf(selectedDevice.type),
          ),
        );
        final List<flutter_blue.BluetoothDevice> connectedDevices =
            await _bluetoothIOS.connectedDevices;
        final int deviceConnectedIndex = connectedDevices
            ?.indexWhere((flutter_blue.BluetoothDevice bluetoothDevice) {
          return bluetoothDevice.id == _bluetoothDeviceIOS.id;
        });
        if (deviceConnectedIndex < 0) {
          await _bluetoothDeviceIOS.connect();
        }
      }

      isConnected = true;
      selectedDevice.connected = true;
      return Future<ConnectionStatus>.value(ConnectionStatus.connected);
    } on Exception catch (error) {
      print('Exception $error');
      isConnected = false;
      selectedDevice.connected = false;
      return Future<ConnectionStatus>.value(ConnectionStatus.timeout);
    }
  }

  Future<ConnectionStatus> disconnect({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (Platform.isAndroid) {
      await _bluetoothAndroid.disconnect();
      isConnected = false;
    } else if (Platform.isIOS) {
      await _bluetoothDeviceIOS.disconnect();
      isConnected = false;
    }

    return ConnectionStatus.disconnect;
  }

  Future<void> printReceiptText(
    ReceiptSectionText receiptSectionText, {
    int feedCount = 0,
    bool useCut = false,
  }) async {
    final Uint8List bytes = await WebcontentConverter.contentToImage(
        content: receiptSectionText.content);
    final List<int> byteBuffer = await _getBytes(
      bytes,
      paperSize: PaperSize.mm58,
      feedCount: feedCount,
      useCut: useCut,
    );
    _printProcess(byteBuffer);
  }

  Future<void> printReceiptImage(
    List<int> bytes, {
    int width = 120,
    int feedCount = 0,
    bool useCut = false,
  }) async {
    final List<int> byteBuffer = await _getBytes(
      bytes,
      customWidth: width,
      feedCount: feedCount,
      useCut: useCut,
    );
    _printProcess(byteBuffer);
  }

  Future<void> printQR(
    String text, {
    int size = 120,
    int feedCount = 0,
    bool useCut = false,
  }) async {
    final List<int> byteBuffer = await _getQRImage(text, size: size.toDouble());
    printReceiptImage(
      byteBuffer,
      width: size,
      feedCount: feedCount,
      useCut: useCut,
    );
  }

  Future<void> _printProcess(List<int> byteBuffer) async {
    try {
      if (selectedDevice == null) {
        print('Device not selected');
        return Future<void>.value(null);
      }
      if (!isConnected) {
        await connect(selectedDevice);
      }
      if (Platform.isAndroid) {
        _bluetoothAndroid.writeBytes(Uint8List.fromList(byteBuffer));
      } else if (Platform.isIOS) {
        final List<flutter_blue.BluetoothService> bluetoothServices =
            await _bluetoothDeviceIOS.discoverServices();
        final flutter_blue.BluetoothService bluetoothService =
            bluetoothServices.firstWhere(
          (flutter_blue.BluetoothService service) => service.isPrimary,
        );
        final flutter_blue.BluetoothCharacteristic characteristic =
            bluetoothService.characteristics.firstWhere(
          (flutter_blue.BluetoothCharacteristic bluetoothCharacteristic) =>
              bluetoothCharacteristic.properties.write,
        );
        await characteristic?.write(byteBuffer, withoutResponse: true);
      }
    } on Exception catch (error) {
      print('Error : $error');
    }
  }

  Future<List<int>> _getBytes(
    List<int> data, {
    PaperSize paperSize = PaperSize.mm58,
    int customWidth,
    int feedCount = 0,
    bool useCut = false,
  }) async {
    List<int> bytes = <int>[];
    final CapabilityProfile profile = await CapabilityProfile.load();
    final Generator generator = Generator(PaperSize.mm58, profile);
    final img.Image _resize = img.copyResize(
      img.decodeImage(data),
      width: customWidth ?? paperSize.width,
    );
    bytes += generator.image(_resize);
    if (feedCount > 0) {
      bytes += generator.feed(feedCount);
    }
    if (useCut) {
      bytes += generator.cut();
    }
    return bytes;
  }

  Future<Uint8List> _getQRImage(String text, {double size}) async {
    try {
      final Image image = await QrPainter(
        data: text,
        version: QrVersions.auto,
        gapless: false,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      ).toImage(size);
      final ByteData a = await image.toByteData(format: ImageByteFormat.png);
      return a.buffer.asUint8List();
    } on Exception catch (exception) {
      print('$runtimeType - $exception');
      rethrow;
    }
  }
}
