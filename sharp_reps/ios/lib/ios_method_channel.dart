import 'package:flutter/services.dart';

class MethodChannelBluetoothIosPlugin {
  final MethodChannel methodChannel =
      const MethodChannel('bluetooth_ios_plugin');

  Future<void> initializeBluetooth() async {
    return methodChannel.invokeMethod('initializeBluetooth');
  }

  Future<void> startScanning() async {
    return methodChannel.invokeMethod('startScanning');
  }

  Future<void> connectToDevice(
      String serviceUUID, String characteristicUUID) async {
    return methodChannel.invokeMethod('connectToDevice', {
      'serviceUUID': serviceUUID,
      'characteristicUUID': characteristicUUID,
    });
  }

  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  // Add other Bluetooth-related methods here, implemented using methodChannel
}
