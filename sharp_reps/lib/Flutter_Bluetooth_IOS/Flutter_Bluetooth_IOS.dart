import 'dart:async';
import 'package:flutter/services.dart';

class SwiftBluetoothPlugin {
  static const MethodChannel _channel = MethodChannel('Flutter_Bluetooth_IOS');

  // Initialize the BluetoothManager when the plugin is initialized
  static Future<void> initialize() async {
    await _channel.invokeMethod('initialize');
  }

  // Connect to the specified device with the given serviceUUID and characteristicUUID
  static Future<void> connectToDevice(
      String serviceUUID, String characteristicUUID) async {
    await _channel.invokeMethod('connectToDevice', {
      'serviceUUID': serviceUUID,
      'characteristicUUID': characteristicUUID,
    });
  }

  // Send data to the connected device
  static Future<void> sendData(String data) async {
    await _channel.invokeMethod('sendData', {'data': data});
  }

  // Start scanning for nearby Bluetooth devices
  static Future<void> startScan(Duration scanDuration) async {
    await _channel
        .invokeMethod('startScan', {'duration': scanDuration.inSeconds});
  }

  // Stop scanning for nearby Bluetooth devices
  static Future<void> stopScan() async {
    await _channel.invokeMethod('stopScan');
  }

  // Handle dataReceived event from the BluetoothManager
  static void onDataReceived(void Function(String) onData) {
    EventChannel('Flutter_Bluetooth_IOS/dataReceived')
        .receiveBroadcastStream()
        .listen((data) {
      onData(data);
    });
  }

  // Handle error event from the BluetoothManager
  static void onError(void Function(String) onError) {
    EventChannel('your_plugin_name/error')
        .receiveBroadcastStream()
        .listen((error) {
      onError(error);
    });
  }

  // Handle devicesDiscovered event from the BluetoothManager
  static void onDevicesDiscovered(
      void Function(List<Map<String, String>>) onDevicesDiscovered) {
    EventChannel('Flutter_Bluetooth_IOS/devicesDiscovered')
        .receiveBroadcastStream()
        .listen((devices) {
      onDevicesDiscovered(List<Map<String, String>>.from(
          devices.map((device) => Map<String, String>.from(device))));
    });
  }
}
