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
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue_thermal;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;

// ignore: import_of_legacy_library_into_null_safe
import 'package:webcontent_converter/webcontent_converter.dart';

class BluePrintPos {
  BluePrintPos._() {
    _bluetoothAndroid = blue_thermal.BlueThermalPrinter.instance;
    _bluetoothIOS = flutter_blue.FlutterBlue.instance;
  }

  static final BluePrintPos _instance = BluePrintPos._();

  static BluePrintPos get instance => _instance;

  /// This field is library to handle in Android Platform
  blue_thermal.BlueThermalPrinter? _bluetoothAndroid;

  /// This field is library to handle in iOS Platform
  flutter_blue.FlutterBlue? _bluetoothIOS;

  /// Bluetooth Device model for iOS
  flutter_blue.BluetoothDevice? _bluetoothDeviceIOS;

  /// State to get bluetooth is connected
  bool _isConnected = false;

  /// Getter value [_isConnected]
  bool get isConnected => _isConnected;

  /// Selected device after connecting
  BlueDevice? selectedDevice;

  /// return bluetooth device list, handler Android and iOS in [BlueScanner]
  Future<List<BlueDevice>> scan() async {
    return await BlueScanner.scan();
  }

  /// When connecting, reassign value [selectedDevice] from parameter [device]
  /// and if connection time more than [timeout]
  /// will return [ConnectionStatus.timeout]
  /// When connection success, will return [ConnectionStatus.connected]
  Future<ConnectionStatus> connect(
    BlueDevice device, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    selectedDevice = device;
    try {
      if (Platform.isAndroid) {
        final blue_thermal.BluetoothDevice bluetoothDeviceAndroid =
            blue_thermal.BluetoothDevice(
                selectedDevice?.name ?? '', selectedDevice?.address ?? '');
        await _bluetoothAndroid?.connect(bluetoothDeviceAndroid);
      } else if (Platform.isIOS) {
        _bluetoothDeviceIOS = flutter_blue.BluetoothDevice.fromProto(
          proto.BluetoothDevice(
            name: selectedDevice?.name ?? '',
            remoteId: selectedDevice?.address ?? '',
            type: proto.BluetoothDevice_Type.valueOf(selectedDevice?.type ?? 0),
          ),
        );
        final List<flutter_blue.BluetoothDevice> connectedDevices =
            await _bluetoothIOS?.connectedDevices ??
                <flutter_blue.BluetoothDevice>[];
        final int deviceConnectedIndex = connectedDevices
            .indexWhere((flutter_blue.BluetoothDevice bluetoothDevice) {
          return bluetoothDevice.id == _bluetoothDeviceIOS?.id;
        });
        if (deviceConnectedIndex < 0) {
          await _bluetoothDeviceIOS?.connect();
        }
      }

      _isConnected = true;
      selectedDevice?.connected = true;
      return Future<ConnectionStatus>.value(ConnectionStatus.connected);
    } on Exception catch (error) {
      print('$runtimeType - Error $error');
      _isConnected = false;
      selectedDevice?.connected = false;
      return Future<ConnectionStatus>.value(ConnectionStatus.timeout);
    }
  }

  /// To stop communication between bluetooth device and application
  Future<ConnectionStatus> disconnect({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (Platform.isAndroid) {
      await _bluetoothAndroid?.disconnect();
      _isConnected = false;
    } else if (Platform.isIOS) {
      await _bluetoothDeviceIOS?.disconnect();
      _isConnected = false;
    }

    return ConnectionStatus.disconnect;
  }

  /// This method only for print text
  /// value and styling inside model [ReceiptSectionText].
  /// [feedCount] to create more space after printing process done
  /// [useCut] to cut printing process
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

  /// This method only for print image with parameter [bytes] in List<int>
  /// define [width] to custom width of image, default value is 120
  /// [feedCount] to create more space after printing process done
  /// [useCut] to cut printing process
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

  /// This method only for print QR, only pass value on parameter [data]
  /// define [size] to size of QR, default value is 120
  /// [feedCount] to create more space after printing process done
  /// [useCut] to cut printing process
  Future<void> printQR(
    String data, {
    int size = 120,
    int feedCount = 0,
    bool useCut = false,
  }) async {
    final List<int> byteBuffer = await _getQRImage(data, size.toDouble());
    printReceiptImage(
      byteBuffer,
      width: size,
      feedCount: feedCount,
      useCut: useCut,
    );
  }

  /// Reusable method for print text, image or QR based value [byteBuffer]
  /// Handler Android or iOS will use method writeBytes from ByteBuffer
  /// But in iOS more complex handler using service and characteristic
  Future<void> _printProcess(List<int> byteBuffer) async {
    try {
      if (selectedDevice == null) {
        print('$runtimeType - Device not selected');
        return Future<void>.value(null);
      }
      if (!_isConnected && selectedDevice != null) {
        await connect(selectedDevice!);
      }
      if (Platform.isAndroid) {
        _bluetoothAndroid?.writeBytes(Uint8List.fromList(byteBuffer));
      } else if (Platform.isIOS) {
        final List<flutter_blue.BluetoothService> bluetoothServices =
            await _bluetoothDeviceIOS?.discoverServices() ??
                <flutter_blue.BluetoothService>[];
        final flutter_blue.BluetoothService bluetoothService =
            bluetoothServices.firstWhere(
          (flutter_blue.BluetoothService service) => service.isPrimary,
        );
        final flutter_blue.BluetoothCharacteristic characteristic =
            bluetoothService.characteristics.firstWhere(
          (flutter_blue.BluetoothCharacteristic bluetoothCharacteristic) =>
              bluetoothCharacteristic.properties.write,
        );
        await characteristic.write(byteBuffer, withoutResponse: true);
      }
    } on Exception catch (error) {
      print('$runtimeType - Error $error');
    }
  }

  /// This method to convert byte from [data] into as image canvas.
  /// It will automatically set width and height based [paperSize].
  /// [customWidth] to print image with specific width
  /// [feedCount] to generate byte buffer as feed in receipt.
  /// [useCut] to cut of receipt layout as byte buffer.
  Future<List<int>> _getBytes(
    List<int> data, {
    PaperSize paperSize = PaperSize.mm58,
    int customWidth = 0,
    int feedCount = 0,
    bool useCut = false,
  }) async {
    List<int> bytes = <int>[];
    final CapabilityProfile profile = await CapabilityProfile.load();
    final Generator generator = Generator(PaperSize.mm58, profile);
    final img.Image _resize = img.copyResize(
      img.decodeImage(data)!,
      width: customWidth > 0 ? customWidth : paperSize.width,
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

  /// Handler to generate QR image from [text] and set the [size].
  /// Using painter and convert to [Image] object and return as [Uint8List]
  Future<Uint8List> _getQRImage(String text, double size) async {
    try {
      final Image image = await QrPainter(
        data: text,
        version: QrVersions.auto,
        gapless: false,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      ).toImage(size);
      final ByteData? byteData =
          await image.toByteData(format: ImageByteFormat.png);
      assert(byteData != null);
      return byteData!.buffer.asUint8List();
    } on Exception catch (exception) {
      print('$runtimeType - $exception');
      rethrow;
    }
  }
}
