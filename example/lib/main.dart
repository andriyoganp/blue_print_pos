import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/models.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'package:blue_print_pos/receipt/receipt_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluePrintPos _bluePrintPos;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice _selectedDevice;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _bluePrintPos = BluePrintPos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Blue Print Pos'),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              : _blueDevices.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: List<Widget>.generate(_blueDevices.length,
                              (int index) {
                            return GestureDetector(
                              onTap: () => _onSelectDevice(_blueDevices[index]),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _blueDevices[index].name,
                                      style: TextStyle(
                                        color: _selectedDevice?.address ==
                                                _blueDevices[index].address
                                            ? Colors.blue
                                            : Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _blueDevices[index].address,
                                      style: TextStyle(
                                        color: _selectedDevice?.address ==
                                                _blueDevices[index].address
                                            ? Colors.blueGrey
                                            : Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        TextButton(
                          onPressed: onPrintReceipt,
                          child: Container(
                            color: _selectedDevice == null
                                ? Colors.grey
                                : Colors.blue,
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              'Print',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5);
                                }
                                return null; // Use the component's default.
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Text(
                            'Scan bluetooth device',
                            style: TextStyle(fontSize: 24, color: Colors.blue),
                          ),
                          Text(
                            'Press button scan',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isLoading ? null : _onScanPressed,
          child: const Icon(Icons.search),
          backgroundColor: _isLoading ? Colors.grey : Colors.blue,
        ),
      ),
    );
  }

  Future<void> _onScanPressed() async {
    setState(() => _isLoading = true);
    _bluePrintPos.scan().then((List<BlueDevice> devices) {
      if (devices.isNotEmpty) {
        setState(() {
          _blueDevices = devices;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  void _onSelectDevice(BlueDevice blueDevice) {
    _bluePrintPos.connect(blueDevice).then((ConnectionStatus status) {
      if (status == ConnectionStatus.connected) {
        setState(() => _selectedDevice = blueDevice);
      } else if (status == ConnectionStatus.timeout) {
        print('$runtimeType - timeout');
      } else {
        print('$runtimeType - something wrong');
      }
    });
  }

  Future<void> onPrintReceipt() async {
    /// Example for Print Image
    final ByteData logoBytes = await rootBundle.load(
      'assets/logo.jpg',
    );
    await _bluePrintPos.printReceiptImage(
      logoBytes.buffer.asUint8List(),
      width: 120,
    );

    /// Example for Print Text
    final ReceiptSectionText receiptText = ReceiptSectionText();
    receiptText.addSpacer();
    receiptText.addText(
      'MY STORE',
      size: ReceiptTextSizeType.medium,
      style: ReceiptTextStyleType.bold,
    );
    receiptText.addText(
      'Black White Street, Jakarta, Indonesia',
      size: ReceiptTextSizeType.small,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText('Time', '04/06/21, 10:00');
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Apple 1kg',
      'Rp30.000',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.bold,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'TOTAL',
      'Rp30.000',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.bold,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Payment',
      'Cash',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.normal,
    );
    receiptText.addSpacer(count: 2);
    await _bluePrintPos.printReceiptText(receiptText, feedCount: 1);

    /// Example for print QR
    await _bluePrintPos.printQR('www.google.com', size: 250, feedCount: 1);
    final ReceiptSectionText receiptFooterText = ReceiptSectionText();
    receiptFooterText.addText('Powered by', size: ReceiptTextSizeType.small);
    receiptFooterText.addText('ayeee', size: ReceiptTextSizeType.small);
    receiptFooterText.addSpacer();

    /// Example for separated text, for this example separated by image qr
    await _bluePrintPos.printReceiptText(
      receiptFooterText,
      feedCount: 2,
      useCut: true,
    );
  }
}
