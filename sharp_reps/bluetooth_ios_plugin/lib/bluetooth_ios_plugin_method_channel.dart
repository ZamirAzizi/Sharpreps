import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bluetooth_ios_plugin_platform_interface.dart';

/// An implementation of [BluetoothIosPluginPlatform] that uses method channels.
class MethodChannelBluetoothIosPlugin extends BluetoothIosPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bluetooth_ios_plugin');

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

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Stream onDataReceived() {
    // TODO: implement onDataReceived
    throw UnimplementedError();
  }

  @override
  Stream onError() {
    // TODO: implement onError
    throw UnimplementedError();
  }
}
