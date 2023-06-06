import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDetailScreen extends StatefulWidget {
  final BluetoothDevice server;

  const BluetoothDetailScreen({super.key, required this.server});

  @override
  State<BluetoothDetailScreen> createState() => _BluetoothDetailScreenState();
}

class _BluetoothDetailScreenState extends State<BluetoothDetailScreen> {
  BluetoothConnection? connection;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;
  bool isDisconnecting = false;
  var _globalId = -1;
  var _globalValByte1 = -1;
  var _globalValByte2 = -1;

  double _globalValue = -1;

  @override
  void initState() {
    super.initState();

    _getBTConnection();
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = false;
      connection!.dispose();
      connection = null;
    }
    super.dispose();
  }

  _getBTConnection() {
    BluetoothConnection.toAddress(widget.server.address).then(
      (_connection) {
        connection = _connection;
        isConnecting = false;
        isDisconnecting = false;
        setState(() {
          connection!.input!.listen(_onDataReceived).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally');
            } else {
              print('Disconnecting remotely');
            }
            if (this.mounted) {
              setState(() {});
            }
            Navigator.of(context).pop();
          });
        });
      },
    ).catchError((error) {
      Navigator.of(context).pop();
    });
  }

  void _onDataReceived(Uint8List data) {
    if (data.isNotEmpty) {
      _resetBtReceivedData();

      print(data);

      setState(() {
        _globalId = data.elementAt(0) - 128;
        _globalValByte1 = data.elementAt(1);
        _globalValByte2 = data.elementAt(2);

        _globalValue = (((_globalValByte1 * 128) + (_globalValByte2)) / 1);
      });
    }
  }

  void _sendMessage(String text) async {}

  _resetBtReceivedData() {
    _globalId = -1;
    _globalValByte1 = -1;
    _globalValByte2 = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: (isConnecting
            ? Text('Connecting with ${widget.server.name}')
            : isConnected
                ? Text('Connected with ${widget.server.name}')
                : Text('Disconnected with ${widget.server.name}')),
      ),
      body: Container(
        child: isConnected
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "$_globalId",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    Text(
                      "$_globalValue",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Text(
                  'Connecting...',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
              ),
      ),
    );
  }
}
