import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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

  // var _maxNumberofReps = "0";
  // var _maxNumberofSets = "0";
  var _maxLimit = "0";
  var _minLimit = "0";
  var _numberOfReps = "0";
  var _repTime = "0";
  var _setTime = "0";
  var _numberOfSets = "0";
  var _calibrationRequired = "0";
  var _currentDisplacement = "0";
  var _repState = 'Idle';
  var _repIncompleteCounter = '0';
  var _setRestTimer = '0';
  var _repIncompletePercentage = '0';
  var _calibState = 'Idle';
  Stream<List<int>>? stream;
  BluetoothCharacteristic? sendCharacteristic; // Add this line
  final double profileHeight = 120;

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

  DateTime _date = DateTime.now();

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2059),
    ).then((value) {
      setState(() {
        _date = value!;
      });
    });
  }

  String intToTimeLeft(int value) {
    int h, m, s;

    h = value ~/ 3600;

    m = ((value - h * 3600)) ~/ 60;

    s = value - (h * 3600) - (m * 60);

    String result = "$h:$m:$s s";

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: !isReady!
            ? Center(
                child: Text(
                  "Waiting...",
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Scaffold(
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 45,
                        left: 25,
                        right: 25,
                        bottom: 25,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          CircleAvatar(
                            radius: profileHeight / 2.5,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            backgroundImage: AssetImage(
                              "assets/images/app_loading_icon.png",
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              ' Exercises',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Expanded(
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

                              if (id == "6") {
                                _calibrationRequired = val_byte;
                                print(val_byte);
                              } else if (id == "7") {
                                _currentDisplacement = val_byte;
                              } else if (id == "8") {
                                var State = val_byte;
                                if (State == '0') {
                                  _calibState = 'Idle';
                                } else if (State == '1') {
                                  _calibState = 'Looking For Max';
                                } else if (State == '2') {
                                  _calibState = 'Looking For Min';
                                }
                              } else if (id == "9") {
                                _maxLimit = val_byte;
                              } else if (id == "10") {
                                _minLimit = val_byte;
                              } else if (id == "11") {
                                _numberOfReps = val_byte;
                              } else if (id == "12") {
                                _numberOfSets = val_byte;
                              } else if (id == "13") {
                                var time =
                                    ((int.parse(val_byte) * 100) ~/ 1000);
                                _repTime = intToTimeLeft(time);
                              } else if (id == "14") {
                                var time =
                                    ((int.parse(val_byte) * 100) ~/ 1000);
                                _setTime = intToTimeLeft(time);
                              } else if (id == "15") {
                                var State = val_byte;
                                if (State == '0') {
                                  _repState = 'Idle';
                                } else if (State == '1') {
                                  _repState = 'UP';
                                } else if (State == '2') {
                                  _repState = 'Down';
                                }
                              } else if (id == "16") {
                                _repIncompleteCounter = val_byte;
                              } else if (id == "17") {
                                var time =
                                    ((int.parse(val_byte) * 100) ~/ 1000);
                                _setRestTimer = intToTimeLeft(time);
                              } else if (id == "18") {
                                _repIncompletePercentage = val_byte;
                              }
                              int intVal = int.parse(_numberOfReps);
                              double maxL = double.parse(_maxLimit);
                              double minL = double.parse(_minLimit);
                              double currVal =
                                  double.parse(_currentDisplacement);

                              return Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SfLinearGauge(
                                        maximum: 500,
                                        majorTickStyle: LinearTickStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        minorTickStyle: LinearTickStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        axisLabelStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        axisTrackStyle: LinearAxisTrackStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        markerPointers: [
                                          LinearWidgetPointer(
                                            value: maxL,
                                            dragBehavior:
                                                LinearMarkerDragBehavior.free,
                                            position:
                                                LinearElementPosition.outside,
                                            child: Icon(Icons.location_pin,
                                                color: Colors.blue, size: 30),
                                          ),
                                          LinearWidgetPointer(
                                            value: minL,
                                            position:
                                                LinearElementPosition.outside,
                                            dragBehavior:
                                                LinearMarkerDragBehavior.free,
                                            child: Icon(Icons.location_pin,
                                                color: Colors.red, size: 30),
                                          ),
                                          LinearWidgetPointer(
                                            value: currVal,
                                            position:
                                                LinearElementPosition.outside,
                                            dragBehavior:
                                                LinearMarkerDragBehavior.free,
                                            child: Icon(Icons.arrow_drop_down,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                size: 30),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        ' ${Data} mm',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
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
                                        ),
                                      ),
                                      Text(
                                        _date.toString(),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              id = "5";
                                              String data = ("${id}, 1 ");
                                              _sendTestData(data);
                                            },
                                            child: Text("Start Calibraation"),
                                          ),
                                          SizedBox(
                                            height: 12,
                                            width: 12,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              id = "3";
                                              String data = ("${id}, 1 ");
                                              _sendTestData(data);
                                            },
                                            child: Text("Start Workout"),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              id = "4";
                                              String data = ("${id}, 1 ");
                                              _sendTestData(data);
                                            },
                                            child: Text("Start New Set"),
                                          ),
                                          SizedBox(
                                            height: 12,
                                            width: 12,
                                          ),
                                          MaterialButton(
                                            onPressed: _showDatePicker,
                                            child: const Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                'Choose Date',
                                              ),
                                            ),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ],
                                      ),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          StepProgressIndicator(
                                            totalSteps: 10,
                                            currentStep: intVal,
                                            direction: Axis.horizontal,
                                            selectedColor: Colors.green,
                                            unselectedColor: Colors.red,
                                            size: 50,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "$_numberOfReps Reps",
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                            width: 12,
                                          ),
                                          Text(
                                            "$_numberOfSets Sets",
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _repState,
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      Text(
                                        "$_repTime Rep Time",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      Text(
                                        "$_setTime Set Time",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      Text(
                                        "$_setRestTimer Rest Time",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      Text(
                                        "$_repIncompleteCounter Incomplete Reps",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      Text(
                                        "$_repIncompletePercentage Incomplete Reps %",
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
