import 'package:flutter/services.dart';

class BluetoothSerial {
  static const MethodChannel _channel = MethodChannel('bluetooth_serial');

  // Method to initialize Bluetooth communication
  static Future<void> initializeBluetooth() async {
    try {
      await _channel.invokeMethod('initializeBluetooth');
    } catch (e) {
      throw Exception('Error initializing Bluetooth: $e');
    }
  }

  // Method to start scanning for nearby Bluetooth devices
  static Future<void> startScanning() async {
    try {
      await _channel.invokeMethod('startScanning');
    } catch (e) {
      throw Exception('Error starting scanning: $e');
    }
  }

  // Method to connect to a Bluetooth device with the given serviceUUID and characteristicUUID
  static Future<void> connectToDevice(
      String serviceUUID, String characteristicUUID) async {
    try {
      await _channel.invokeMethod('connectToDevice', {
        'serviceUUID': serviceUUID,
        'characteristicUUID': characteristicUUID,
      });
    } catch (e) {
      throw Exception('Error connecting to device: $e');
    }
  }

  // Method to send data to the connected Bluetooth device
  static Future<void> sendData(String data) async {
    try {
      await _channel.invokeMethod('sendData', {'data': data});
    } catch (e) {
      throw Exception('Error sending data: $e');
    }
  }

  // Method to receive data from the connected Bluetooth device
  // This method should listen for dataReceived event streams
  // Add the necessary implementation to receive data from the platform
}

// Event stream for data received from the connected Bluetooth device
Stream<dynamic> onDataReceived() {
  return const EventChannel('bluetooth_serial/dataReceived')
      .receiveBroadcastStream();
}

// Event stream for errors during Bluetooth communication
Stream<dynamic> onError() {
  return const EventChannel('bluetooth_serial/error').receiveBroadcastStream();
}

// Event stream for discovering nearby Bluetooth devices
Stream<dynamic> onDevicesDiscovered() {
  return const EventChannel('bluetooth_serial/devicesDiscovered')
      .receiveBroadcastStream();
}
