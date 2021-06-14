# Introduction

This plugin to help use bluetooth printer in Android/iOS. Support for text, image, add new line or 
line dashed and QR. 

## Usage
### Initialize
```dart
BluePrintPos bluePrintPos = BluePrintPos.instance; 
```

### Scan bluetooth printer
```dart
bluePrintPos.scan();
```

### Connect bluetooth printer
```dart
bluePrintPos.connect(device);
```

### Print Text
In method ```.addText(text, {size, style, alignment})``` you can modify size, style and alignment
```dart
ReceiptSectionText receiptText = ReceiptSectionText();
receiptText.addText('MY STORE', size: ReceiptTextSizeType.medium, style: ReceiptTextStyleType.bold);
```

### Print text left right
```dart
receiptText.addLeftRightText('Time', '04/06/21, 10:00');
```

### Print image
```dart
final ByteData logoBytes = await rootBundle.load('assets/logo.jpg');
receiptText.addImage(
  base64.encode(Uint8List.view(logoBytes.buffer)),
  width: 150,
);
```

### Add new line
```dart 
receiptText.addSpacer();
```

### Add new line with dash
```dart 
receiptText.addSpacer(useDashed: true);
```

## Getting Started
### Android

Change the ```minSdkVersion``` in **android/app/build.gradle** in 19
```groovy
android {
  defaultConfig {
     minSdkVersion 19
  }
}
```

Add permission for Bluetooth and access location in **android/app/src/main/AndroidManifest.xml**
```xml 
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
``` 

### iOS
Add info key in **ios/Runner/Info.plist**
```dart
<key>NSBluetoothAlwaysUsageDescription</key>  
<string>Need BLE permission</string>  
<key>NSBluetoothPeripheralUsageDescription</key>  
<string>Need BLE permission</string>  
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>  
<string>Need Location permission</string>  
<key>NSLocationAlwaysUsageDescription</key>  
<string>Need Location permission</string>  
<key>NSLocationWhenInUseUsageDescription</key>  
<string>Need Location permission</string>
``` 


## Thanks to
Reference and dependencies create this plugin
- [blue_thermal_printer](https://pub.dev/packages/blue_thermal_printer)
- [esc_pos_utils](https://pub.dev/packages/esc_pos_utils)
- [esc_pos_utils_plus](https://pub.dev/packages/esc_pos_utils_plus)
- [flutter_blue](https://pub.dev/packages/flutter_blue)
- [image](https://pub.dev/packages/image)
- [qr_flutter](https://pub.dev/packages/qr_flutter)
- [webcontent_converter](https://pub.dev/packages/webcontent_converter/score)


