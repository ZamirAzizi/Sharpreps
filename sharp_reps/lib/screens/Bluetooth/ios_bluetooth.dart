import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IosBluetooth extends StatefulWidget {
  @override
  _IosBluetoothState createState() => _IosBluetoothState();
}

class _IosBluetoothState extends State<IosBluetooth> {
  // Set up the event channel to listen for devicesDiscovered event
  final EventChannel devicesDiscoveredChannel =
      EventChannel('bluetooth_ios_plugin/devicesDiscovered');

  // Start listening for the devicesDiscovered event
  StreamSubscription<dynamic>? devicesDiscoveredSubscription;

  @override
  void initState() {
    super.initState();

    // Start listening for the devicesDiscovered event when the widget is initialized
    devicesDiscoveredSubscription =
        devicesDiscoveredChannel.receiveBroadcastStream().listen((event) {
      // Handle the event here
      // 'event' will contain the list of discovered devices
      print('Discovered devices: $event');
    });
  }

  @override
  void dispose() {
    // Don't forget to cancel the subscription when the widget is disposed to avoid memory leaks
    devicesDiscoveredSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Your widget UI code goes here
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Widget'),
      ),
      body: Center(
        child: Text('Your Widget Content'),
      ),
    );
  }
}
