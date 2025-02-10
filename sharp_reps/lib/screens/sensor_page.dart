import 'dart:async';
import 'dart:convert' show utf8;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SensorPage extends StatefulWidget {
  final String wkAutoGuid;
  final String exerciseNm;
  final String exAutoGuid;
  final String wkName;
  const SensorPage({
    Key? key,
    required this.device,
    required this.wkAutoGuid,
    required this.exerciseNm,
    required this.exAutoGuid,
    required this.wkName,
  }) : super(key: key);
  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final String SERVICE_UUID = "d70ca57b-5b86-4fbe-b41e-494dfaecf80c";
  final String CHARACTERISTIC_UUID = "07a32ccb-1467-43a6-b25e-8a6616d7ca5c";
  final txtController = TextEditingController();
  final ValueNotifier<String> _counter = ValueNotifier<String>("");

  bool? isReady;
  var id = "0";
  var Data = "0,0";

  // var _maxNumberofReps = "0";
  // var _maxNumberofSets = "0";
  var _maxLimit = "0";
  var _minLimit = "0";
  var numberOfReps = "0";
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
  var _enteredWeight = "";
  double currVal = 0;
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
            : Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/images/background_image.png"), // <-- BACKGROUND IMAGE
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Scaffold(
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
                                    currVal =
                                        double.parse(_currentDisplacement);
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
                                    numberOfReps = val_byte;
                                    _saveNewExercise(
                                      context,
                                      _enteredWeight,
                                      widget.wkAutoGuid,
                                      widget.wkName,
                                      widget.exerciseNm,
                                      widget.exAutoGuid,
                                      numberOfReps,
                                      _numberOfSets,
                                      _repTime,
                                      _setTime,
                                      _setRestTimer,
                                    );
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
                                  int intVal = int.parse(numberOfReps);
                                  double maxL = double.parse(_maxLimit);
                                  double minL = double.parse(_minLimit);
                                  // double currVal =
                                  //     double.parse(_currentDisplacement);

                                  return Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          id = "5";
                                                          String data =
                                                              ("${id}, 1 ");
                                                          _sendTestData(data);
                                                        },
                                                        child: Text(
                                                            "Start Calibraation"),
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(
                                                            _calibrationRequired ==
                                                                    "1"
                                                                ? " Calibration Completed"
                                                                : " Calibratrion Required",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                          ),
                                                          Text(
                                                            "$_calibState",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SfLinearGauge(
                                                    maximum: 500,
                                                    majorTickStyle:
                                                        LinearTickStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                    minorTickStyle:
                                                        LinearTickStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                    axisLabelStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                    axisTrackStyle:
                                                        LinearAxisTrackStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                    markerPointers: [
                                                      LinearWidgetPointer(
                                                        value: maxL,
                                                        dragBehavior:
                                                            LinearMarkerDragBehavior
                                                                .free,
                                                        position:
                                                            LinearElementPosition
                                                                .outside,
                                                        child: Icon(
                                                            Icons
                                                                .arrow_downward,
                                                            color: Colors.green,
                                                            size: 30),
                                                      ),
                                                      LinearWidgetPointer(
                                                        value: minL,
                                                        position:
                                                            LinearElementPosition
                                                                .outside,
                                                        dragBehavior:
                                                            LinearMarkerDragBehavior
                                                                .free,
                                                        child: Icon(
                                                            Icons
                                                                .arrow_downward,
                                                            color: Colors.red,
                                                            size: 30),
                                                      ),
                                                      LinearWidgetPointer(
                                                        value: currVal,
                                                        position:
                                                            LinearElementPosition
                                                                .outside,
                                                        dragBehavior:
                                                            LinearMarkerDragBehavior
                                                                .free,
                                                        child: Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            size: 30),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Min $_minLimit cm",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Max $_maxLimit cm",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                            width: double.infinity,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: [
                                                  StepProgressIndicator(
                                                    totalSteps: 10,
                                                    currentStep: intVal,
                                                    direction: Axis.horizontal,
                                                    selectedColor: Colors.green,
                                                    unselectedColor: Colors.red,
                                                    size: 50,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          id = "3";
                                                          String data =
                                                              ("${id}, 1 ");
                                                          _sendTestData(data);
                                                        },
                                                        child: Text(
                                                            "Start Workout"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          id = "4";
                                                          String data =
                                                              ("${id}, 1 ");
                                                          _sendTestData(data);
                                                        },
                                                        child: Text(
                                                            "Start Next Set"),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 100,
                                                    child: TextField(
                                                      controller: txtController,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              labelStyle:
                                                                  TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                              ),
                                                              labelText:
                                                                  "Enter Weight"),
                                                      onSubmitted: (value) {
                                                        _enteredWeight = value;
                                                        // _saveNewExercise(
                                                        //   context,
                                                        //   _enteredWeight,
                                                        //   widget.wkAutoGuid,
                                                        //   widget.wkName,
                                                        //   widget.exerciseNm,
                                                        //   widget.exAutoGuid,
                                                        //   numberOfReps,
                                                        // );
                                                      },
                                                    ),
                                                  ),
                                                  ValueListenableBuilder(
                                                    valueListenable: _counter,
                                                    builder:
                                                        (BuildContext context,
                                                            String value,
                                                            child) {
                                                      // return _saveNewExercise(
                                                      //     context,
                                                      //     _enteredWeight,
                                                      //     widget.wkAutoGuid,
                                                      //     widget.wkName,
                                                      //     widget.exerciseNm,
                                                      //     widget.exAutoGuid);
                                                      return Text(
                                                        '$value',
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Rep State: $_repState',
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      Text(
                                                        "$_setRestTimer Rest Time s",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "$numberOfReps Reps",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      Text(
                                                        "$_numberOfSets Sets",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "$_repTime Rep Time",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      Text(
                                                        "$_setTime Set Time",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "$_repIncompleteCounter Incomplete Reps",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      Text(
                                                        "$_repIncompletePercentage Incomplete Reps %",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: 10,
                                                      width: double.infinity),
                                                ],
                                              ),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                ],
              ),
      ),
    );
  }
}

Future<void> _saveNewExercise(
  BuildContext context,
  String enteredWeight,
  String wkAtGuid,
  String workoutName,
  String exerciseName,
  String exerciseAutoGuid,
  String _numOfReps,
  String _numOfSets,
  String _repTime,
  String _setTime,
  String _setRestTimer,
) async {
  FocusScope.of(context).unfocus();
  final user = FirebaseAuth.instance.currentUser!;
  final numberofSets = 5;
  final nuOfSetsUser = int.parse(_numOfSets);
  final userData =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  try {
    // if (_numOfReps == '') {
    //   return;
    // } else {

    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "0" && _numOfReps == "1") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 1': _numOfReps,
            'set 1 rep 1 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
      if (_numOfSets == "0" && _numOfReps == '2') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 2': _numOfReps,
            'set 1 rep 2 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "0" && _numOfReps == "3") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 3': _numOfReps,
            'set 1 rep 3 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
      if (_numOfSets == "0" && _numOfReps == '4') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 4': _numOfReps,
            'set 1 rep 4 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "0" && _numOfReps == "5") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 5': _numOfReps,
            'set 1 rep 5 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
      if (_numOfSets == "0" && _numOfReps == '6') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 6': _numOfReps,
            'set 1 rep 6 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "0" && _numOfReps == "7") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 7': _numOfReps,
            'set 1 rep 7 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
      if (_numOfSets == "0" && _numOfReps == '8') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 8': _numOfReps,
            'set 1 rep 8 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "0" && _numOfReps == "9") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 9': _numOfReps,
            'set 1 rep 9 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
      if (_numOfSets == "0" && _numOfReps == '10') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 10': _numOfReps,
            'set 1 rep 10 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "0" && _numOfReps == "11") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 11': _numOfReps,
            'set 1 rep 11 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
      if (_numOfSets == "0" && _numOfReps == '12') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 12': _numOfReps,
            'set 1 rep 12 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "0" && _numOfReps == "13") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 13': _numOfReps,
            'set 1 rep 13 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
      if (_numOfSets == "0" && _numOfReps == '14') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 14': _numOfReps,
            'set 1 rep 14 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "0" && _numOfReps == "15") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 1 Reps 15': _numOfReps,
            'set 1 rep 15 time ': _repTime,
            'set 1 Time': _setTime,
          },
        );
      }
      if (_numOfSets == "1" && _numOfReps == "1") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 1': _numOfReps,
          },
        );
      }
      if (_numOfSets == "1" && _numOfReps == '2') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 2': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "1" && _numOfReps == "3") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 3': _numOfReps,
          },
        );
      }
      if (_numOfSets == "1" && _numOfReps == '4') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 4': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "1" && _numOfReps == "5") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 5': _numOfReps,
          },
        );
      }
      if (_numOfSets == "1" && _numOfReps == '6') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 6': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "1" && _numOfReps == "7") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 7': _numOfReps,
          },
        );
      }
      if (_numOfSets == "1" && _numOfReps == '8') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 8': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "1" && _numOfReps == "9") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 9': _numOfReps,
          },
        );
      }
      if (_numOfSets == "1" && _numOfReps == '10') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 10': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "1" && _numOfReps == "11") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 11': _numOfReps,
          },
        );
      }
      if (_numOfSets == "1" && _numOfReps == '12') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 12': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "1" && _numOfReps == "13") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 13': _numOfReps,
          },
        );
      }
      if (_numOfSets == "1" && _numOfReps == '14') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 14': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "1" && _numOfReps == "15") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 2 Reps 15': _numOfReps,
          },
        );
      }
      if (_numOfSets == "2" && _numOfReps == "1") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 1': _numOfReps,
          },
        );
      }
      if (_numOfSets == "2" && _numOfReps == '2') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 2': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "2" && _numOfReps == "3") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 3': _numOfReps,
          },
        );
      }
      if (_numOfSets == "2" && _numOfReps == '4') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 4': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "2" && _numOfReps == "5") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 5': _numOfReps,
          },
        );
      }
      if (_numOfSets == "2" && _numOfReps == '6') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 6': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "2" && _numOfReps == "7") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 7': _numOfReps,
          },
        );
      }
      if (_numOfSets == "2" && _numOfReps == '8') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 8': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "2" && _numOfReps == "9") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 9': _numOfReps,
          },
        );
      }
      if (_numOfSets == "2" && _numOfReps == '10') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 10': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "2" && _numOfReps == "11") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 11': _numOfReps,
          },
        );
      }
      if (_numOfSets == "2" && _numOfReps == '12') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 12': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "2" && _numOfReps == "13") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 13': _numOfReps,
          },
        );
      }
      if (_numOfSets == "2" && _numOfReps == '14') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 14': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "2" && _numOfReps == "15") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 3 Reps 15': _numOfReps,
          },
        );
      }

      if (_numOfSets == "3" && _numOfReps == "1") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 1': _numOfReps,
          },
        );
      }
      if (_numOfSets == "3" && _numOfReps == '2') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 2': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "3" && _numOfReps == "3") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 3': _numOfReps,
          },
        );
      }
      if (_numOfSets == "3" && _numOfReps == '4') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 4': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "3" && _numOfReps == "5") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 5': _numOfReps,
          },
        );
      }
      if (_numOfSets == "3" && _numOfReps == '6') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 6': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "3" && _numOfReps == "7") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 7': _numOfReps,
          },
        );
      }
      if (_numOfSets == "3" && _numOfReps == '8') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 8': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "3" && _numOfReps == "9") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 9': _numOfReps,
          },
        );
      }
      if (_numOfSets == "3" && _numOfReps == '10') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 10': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "3" && _numOfReps == "11") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 11': _numOfReps,
          },
        );
      }
      if (_numOfSets == "3" && _numOfReps == '12') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 12': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "3" && _numOfReps == "13") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 13': _numOfReps,
          },
        );
      }
      if (_numOfSets == "3" && _numOfReps == '14') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 14': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "3" && _numOfReps == "15") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 4 Reps 15': _numOfReps,
          },
        );
      }

      if (_numOfSets == "4" && _numOfReps == "1") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 1': _numOfReps,
          },
        );
      }
      if (_numOfSets == "4" && _numOfReps == '2') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 2': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "4" && _numOfReps == "3") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 3': _numOfReps,
          },
        );
      }
      if (_numOfSets == "4" && _numOfReps == '4') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 4': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "4" && _numOfReps == "5") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 5': _numOfReps,
          },
        );
      }
      if (_numOfSets == "4" && _numOfReps == '6') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 6': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "4" && _numOfReps == "7") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 7': _numOfReps,
          },
        );
      }
      if (_numOfSets == "4" && _numOfReps == '8') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 8': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "4" && _numOfReps == "9") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 9': _numOfReps,
          },
        );
      }
      if (_numOfSets == "4" && _numOfReps == '10') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 10': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "4" && _numOfReps == "11") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 11': _numOfReps,
          },
        );
      }
      if (_numOfSets == "4" && _numOfReps == '12') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 12': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "4" && _numOfReps == "13") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 13': _numOfReps,
          },
        );
      }
      if (_numOfSets == "4" && _numOfReps == '14') {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 14': _numOfReps,
          },
        );
      }
    }
    if (nuOfSetsUser <= numberofSets) {
      if (_numOfSets == "4" && _numOfReps == "15") {
        FirebaseFirestore.instance
            .collection('workouts')
            .doc(user.uid)
            .collection('workout names')
            .doc(wkAtGuid)
            .collection('exercises')
            .doc(exerciseAutoGuid)
            .update(
          {
            'set 5 Reps 15': _numOfReps,
          },
        );
      }
    }
    ;

    // for (var i = 0; i <= numberofSets; i++) {
    //   if (_numOfSets <= "0" && _numOfReps == "1") {
    //     FirebaseFirestore.instance
    //         .collection('workouts')
    //         .doc(user.uid)
    //         .collection('workout names')
    //         .doc(wkAtGuid)
    //         .collection('exercises')
    //         .doc(exerciseAutoGuid)
    //         .update(
    //       {
    //         'set 1 Reps 1': _numOfReps,
    //       },
    //     );
    //   }
    //   if (_numOfSets == "0" && _numOfReps == '2') {
    //     FirebaseFirestore.instance
    //         .collection('workouts')
    //         .doc(user.uid)
    //         .collection('workout names')
    //         .doc(wkAtGuid)
    //         .collection('exercises')
    //         .doc(exerciseAutoGuid)
    //         .update(
    //       {
    //         'set 1 Reps 2': _numOfReps,
    //       },
    //     );
    //   }
    // }

    // if (
    //     _numOfSets == "0" &&
    //     _numOfReps == "1") {
    //   FirebaseFirestore.instance
    //       .collection('workouts')
    //       .doc(user.uid)
    //       .collection('workout names')
    //       .doc(wkAtGuid)
    //       .collection('exercises')
    //       .doc(exerciseAutoGuid)
    //       .update(
    //     {
    //       'set 1 Reps 1': _numOfReps,
    //     },
    //   );
    // }
    // if (_numOfSets == "0" && _numOfReps == '2') {
    //   FirebaseFirestore.instance
    //       .collection('workouts')
    //       .doc(user.uid)
    //       .collection('workout names')
    //       .doc(wkAtGuid)
    //       .collection('exercises')
    //       .doc(exerciseAutoGuid)
    //       .update(
    //     {
    //       'set 1 Reps 2': _numOfReps,
    //     },
    //   );
    // }
    // }
    //Clear the text
    // enteredWeight = '';
  } catch (err) {
    var message = 'Please enter values for the fields provided';
    message = err.toString();

    var snackbar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
