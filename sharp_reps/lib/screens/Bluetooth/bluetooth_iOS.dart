import 'package:sharp_reps/Flutter_Bluetooth_IOS/Flutter_Bluetooth_IOS.dart';

import 'package:flutter/material.dart';

import 'device_selection_page.dart';

class BluetoothIOS extends StatefulWidget {
  @override
  _BluetoothIOSState createState() => _BluetoothIOSState();
}

class _BluetoothIOSState extends State<BluetoothIOS> {
  String receivedData = '';
  TextEditingController sendDataController = TextEditingController();
  String selectedServiceUUID = '';
  String selectedCharacteristicUUID = '';

  @override
  void initState() {
    super.initState();

    // Initialize the Bluetooth plugin
    SwiftBluetoothPlugin.initialize();

    // Listen for received data
    SwiftBluetoothPlugin.onDataReceived((data) {
      setState(() {
        receivedData = data;
      });
    });

    // Listen for errors
    SwiftBluetoothPlugin.onError((error) {
      // Handle the error, e.g., show a dialog or display a snackbar
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    sendDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Communication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Received Data:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              receivedData,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: sendDataController,
              decoration: InputDecoration(
                labelText: 'Send Data',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Send data to the connected device
                SwiftBluetoothPlugin.sendData(sendDataController.text);
                sendDataController.clear();
              },
              child: Text('Send'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Start scanning for available Bluetooth devices
                await SwiftBluetoothPlugin.startScan(Duration(seconds: 10));
                // Navigate to the Bluetooth device selection page
                final selectedUUIDs = await Navigator.push<Map<String, String>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceSelectionPage(),
                  ),
                );
                if (selectedUUIDs != null) {
                  setState(() {
                    selectedServiceUUID = selectedUUIDs['serviceUUID']!;
                    selectedCharacteristicUUID =
                        selectedUUIDs['characteristicUUID']!;
                  });

                  // Connect to the selected Bluetooth device
                  SwiftBluetoothPlugin.connectToDevice(
                      selectedServiceUUID, selectedCharacteristicUUID);
                }
              },
              child: Text('Select Device'),
            ),
          ],
        ),
      ),
    );
  }
}
