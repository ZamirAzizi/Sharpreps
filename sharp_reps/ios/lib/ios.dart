// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

// import 'ios_platform_interface.dart';

// class Ios {
//   Future<String?> getPlatformVersion() {
//     return IosPlatform.instance.getPlatformVersion();
//   }
// }

import 'ios_method_channel.dart';

class MethodChannelIos extends MethodChannelBluetoothIosPlugin {
  // No need to redefine the methodChannel here, as it is already defined in MethodChannelBluetoothIosPlugin

  // Implement other methods defined in BluetoothIosPluginPlatform using the methodChannel
  @override
  Future<void> initializeBluetooth() async {
    return methodChannel.invokeMethod('initializeBluetooth');
  }

  @override
  Future<void> startScanning() async {
    return methodChannel.invokeMethod('startScanning');
  }

  @override
  Future<void> connectToDevice(
      String serviceUUID, String characteristicUUID) async {
    return methodChannel.invokeMethod('connectToDevice', {
      'serviceUUID': serviceUUID,
      'characteristicUUID': characteristicUUID,
    });
  }
}
