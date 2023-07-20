import 'package:flutter/material.dart';
import 'package:sharp_reps/Flutter_Bluetooth_IOS/Flutter_Bluetooth_IOS.dart';

class DeviceSelectionPage extends StatefulWidget {
  @override
  _DeviceSelectionPageState createState() => _DeviceSelectionPageState();
}

class _DeviceSelectionPageState extends State<DeviceSelectionPage> {
  List<Map<String, String>> devices = [];

  @override
  void initState() {
    super.initState();

    // Listen for devices discovered during scanning
    SwiftBluetoothPlugin.onDevicesDiscovered((discoveredDevices) {
      setState(() {
        devices = discoveredDevices;
      });
    });

    // Start scanning for available Bluetooth devices
    SwiftBluetoothPlugin.startScan(Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Bluetooth Device'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index]['name'] ?? 'Unknown Device'),
            subtitle: Text(devices[index]['id']!),
            onTap: () {
              // Return the selected device's UUIDs to the previous page
              Navigator.pop(context, {
                'serviceUUID': devices[index]['serviceUUID'],
                'characteristicUUID': devices[index]['characteristicUUID'],
              });
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Stop scanning for devices when the page is disposed
    SwiftBluetoothPlugin.stopScan();
    super.dispose();
  }
}
