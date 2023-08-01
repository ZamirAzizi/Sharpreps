import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bluetooth_ios_plugin_method_channel.dart';

abstract class BluetoothIosPluginPlatform extends PlatformInterface {
  /// Constructs a BluetoothIosPluginPlatform.
  BluetoothIosPluginPlatform() : super(token: _token);
  // Define the methods for Bluetooth serial communication
  Future<void> initializeBluetooth();
  Future<void> startScanning();
  Future<void> connectToDevice(String serviceUUID, String characteristicUUID);

  // Define event streams for data received and errors
  Stream<dynamic> onDataReceived();
  Stream<dynamic> onError();

  static final Object _token = Object();

  static BluetoothIosPluginPlatform _instance =
      MethodChannelBluetoothIosPlugin();

  /// The default instance of [BluetoothIosPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelBluetoothIosPlugin].
  static BluetoothIosPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BluetoothIosPluginPlatform] when
  /// they register themselves.
  static set instance(BluetoothIosPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

class MethodChannelBluetoothIosPluginPlatform
    extends BluetoothIosPluginPlatform {
  // MethodChannel for communicating with the native platform
  final MethodChannel _methodChannel =
      const MethodChannel('bluetooth_ios_plugin');

  @override
  Future<void> initializeBluetooth() async {
    await _methodChannel.invokeMethod('initializeBluetooth');
  }

  @override
  Future<void> startScanning() async {
    await _methodChannel.invokeMethod('startScanning');
  }

  @override
  Future<void> connectToDevice(
      String serviceUUID, String characteristicUUID) async {
    await _methodChannel.invokeMethod('connectToDevice', {
      'serviceUUID': serviceUUID,
      'characteristicUUID': characteristicUUID,
    });
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

  // Implement other methods and event streams for Bluetooth serial communication
  // ...

  // Implement the event streams onDataReceived and onError
  // ...
}
