import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:sharp_reps/screens/bluetooth_detail_screen.dart';

import '../controllers/BluetoothDeviceListEntry.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen>
    with WidgetsBindingObserver {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  List<BluetoothDevice> devices = <BluetoothDevice>[];
  BluetoothConnection? connection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getBTState();
    _stateChangedListener();
    _listBondedDevices();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifeCycleState(AppLifecycleState state) {
    if (state.index == 0) {
      //resume
      if (_bluetoothState.isEnabled) {
        _listBondedDevices();
      }
    }
  }

  _getBTState() {
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      if (_bluetoothState.isEnabled) {
        _listBondedDevices();
      }
      setState(() {});
    });
  }

  _stateChangedListener() {
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      _bluetoothState = state;
      if (_bluetoothState.isEnabled) {
        _listBondedDevices();
      } else {
        devices.clear();
      }

      setState(() {});
    });
  }

  _listBondedDevices() {
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      devices = bondedDevices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32 Bluetooth Serial'),
        // actions: [DropdownButton(items: items, onChanged: onChanged)],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SwitchListTile(
              activeTrackColor: Theme.of(context).colorScheme.onSecondary,
              activeColor: Theme.of(context).colorScheme.onSecondary,
              title: Text('Enable Bluetooth'),
              tileColor: Theme.of(context).colorScheme.secondary,
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                future() async {
                  if (value) {
                    await FlutterBluetoothSerial.instance.requestEnable();
                  } else {
                    await FlutterBluetoothSerial.instance.requestDisable();
                  }
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              tileColor: Theme.of(context).colorScheme.secondary,
              title: Text("Bluetooth Status"),
              subtitle: Text(_bluetoothState.toString()),
              trailing: ElevatedButton(
                child: Text("Settings"),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            Expanded(
              child: ListView(
                children: devices
                    .map(
                      (_devices) => BluetoothDeviceListEntry(
                        device: _devices,
                        enabled: true,
                        onTap: () {
                          // print('Item');
                          goToBTDetailScreen(context, _devices);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToBTDetailScreen(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BluetoothDetailScreen(server: server);
    }));
  }
}
