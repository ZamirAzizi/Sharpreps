// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'bluetooth_ios_plugin_platform_interface.dart';

class BluetoothIosPlugin {
  Future<String?> getPlatformVersion() {
    return BluetoothIosPluginPlatform.instance.getPlatformVersion();
  }

  BluetoothIosPlugin._();

  // Create a singleton instance of the platform interface
  static final BluetoothIosPluginPlatform _platform =
      MethodChannelBluetoothIosPluginPlatform();

  // Provide methods to interact with the platform interface
  static Future<void> initializeBluetooth() async {
    await _platform.initializeBluetooth();
  }

  static Future<void> startScanning() async {
    await _platform.startScanning();
  }

  static Future<void> connectToDevice(
      String serviceUUID, String characteristicUUID) async {
    await _platform.connectToDevice(serviceUUID, characteristicUUID);
  }

  // Expose event streams for data received and errors
  static Stream<dynamic> get onDataReceived => _platform.onDataReceived();
  static Stream<dynamic> get onError => _platform.onError();
}
// your_plugin_name.dart



 
 
