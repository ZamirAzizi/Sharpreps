import 'dart:async';
import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final String SERVICE_UUID = "d70ca57b-5b86-4fbe-b41e-494dfaecf80c";
  final String CHARACTERISTIC_UUID = "07a32ccb-1467-43a6-b25e-8a6616d7ca5c";

  bool? isReady;
  var id = "0";
  var Data = "0,0";

  var _maxLimit = "0";
  var _minLimit = "0";
  var _numberOfReps = "0";

  var _numberOfSets = "0";
  var _calibrationRequired = "0";
  var _currentDisplacement = "0";
  Stream<List<int>>? stream;
  BluetoothCharacteristic? sendCharacteristic; // Add this line

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    new Timer(const Duration(seconds: 15), () {
      if (!isReady!) {
        disconnectFromDevice();
        _Pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _Pop();
      return;
    }

    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            // Save the characteristic for sending data back
            sendCharacteristic = characteristic;
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;

            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if (!isReady!) {
      _Pop();
    }
  }

  // Future _onWillPop() {
  //   return showDialog(
  //       context: context,
  //       builder: (context) => new AlertDialog(
  //             title: Text('Are you sure?'),
  //             content: Text('Do you want to disconnect device and go back?'),
  //             actions: <Widget>[
  //               new TextButton(
  //                   onPressed: () => Navigator.of(context).pop(false),
  //                   child: new Text('No')),
  //               new TextButton(
  //                   onPressed: () {
  //                     disconnectFromDevice();
  //                     Navigator.of(context).pop(true);
  //                   },
  //                   child: new Text('Yes')),
  //             ],
  //           ));
  // }

  _Pop() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> dataFromDevice) {
    // var id = utf8.decode(dataFromDevice).split(",").elementAt(0);
    // var val_byte = utf8.decode(dataFromDevice).split(",").elementAt(1);

    return utf8.decode(dataFromDevice);

    // return utf8.decode(dataFromDevice);
  }

  Future _sendTestData(String dataToSend) async {
    if (sendCharacteristic != null) {
      List<int> dataBytes = utf8.encode(dataToSend);
      await sendCharacteristic!.write(dataBytes);
      print("Data that will be sent: ${dataBytes} ${dataToSend} ");
    }
  }

  // void _sendTestData() async {
  //   if (sendCharacteristic_5 != null) {
  //     String dataToSend = "1";
  //     List<int> dataBytes = utf8.encode(dataToSend);
  //     print(dataToSend);
  //     await sendCharacteristic_5!.write(dataBytes);
  //     print('Data sent successfully: $dataToSend');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Optical Distance Sensor'),
      ),
      body: Container(
          child: !isReady!
              ? Center(
                  child: Text(
                    "Waiting...",
                    style: TextStyle(fontSize: 24, color: Colors.red),
                  ),
                )
              : Scaffold(
                  body: Container(
                    child: StreamBuilder<List<int>>(
                      stream: stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<int>> snapshot) {
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');

                        if (snapshot.connectionState ==
                                ConnectionState.active &&
                            snapshot.data!.isNotEmpty) {
                          Data = _dataParser(snapshot.data!);
                          var id = Data.split(",").elementAt(0);
                          var val_byte = Data.split(",").elementAt(1);
                          print(Data);

                          if (id == "9") {
                            _maxLimit = val_byte;
                          } else if (id == "10") {
                            _minLimit = val_byte;
                          } else if (id == "3") {
                            _numberOfReps = val_byte;
                          } else if (id == "1") {
                            _numberOfReps = val_byte;
                          } else if (id == "6") {
                            _calibrationRequired = val_byte;
                            print(val_byte);
                          } else if (id == "7") {
                            _currentDisplacement = val_byte;
                          }
                          // var currentValue = utf8.decode(snapshot.data!);
                          print(_calibrationRequired);
                          // print(currentValue);
                          print(_currentDisplacement);
                          print(id);
                          print(val_byte);
                          return Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(' ${Data} mm',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                              color: Colors.black)),
                                      Text(
                                          _calibrationRequired == "1"
                                              ? " Calibration Completed"
                                              : " Calibratrion Required",
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          )),
                                      Text(
                                        "$_maxLimit cm",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      Text(
                                        "$_minLimit cm",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          id = "5";
                                          String data = ("${id}, 1 ");
                                          _sendTestData(data);
                                        },
                                        child: Text("Send Data"),
                                      )
                                    ]),
                              ),
                            ],
                          ));
                        } else {
                          return Text('Check the stream');
                        }
                      },
                    ),
                  ),
                )),
    );
  }
}
