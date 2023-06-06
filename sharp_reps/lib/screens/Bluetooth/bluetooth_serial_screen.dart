// For performing some operations asynchronously
import 'dart:async';

// For using PlatformException
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection? connection;

  int? _deviceState;

  bool isDisconnecting = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection!.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  final repsController = TextEditingController();
  final setsController = TextEditingController();

  var _globalId = -1;
  var _globalValByte1 = -1;
  var _globalValByte2 = -1;
  var _id = -1;
  var _value = -1;
  String _enteredNumberOfReps = '0';
  String _enteredNumberOfSets = '0';

  double _maxLimit = 0;
  double _minLimit = 0;
  double _numberOfReps = 0;

  double _numberOfSets = 0;
  double _calibrationRequired = 0;
  double _currentDisplacement = 0;

  // Uint8List? _dataToSend;
  double _globalValue = -1;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral
    // _getBTConnection();
    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<bool> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  Future<void> _onDataReceived(Uint8List data) async {
    try {
      if (data.isNotEmpty) {
        _resetBtReceivedData();

        _globalId = data.elementAt(0) - 128;
        _globalValByte1 = data.elementAt(1);
        _globalValByte2 = data.elementAt(2);

        _globalValue = (((_globalValByte1 * 128) + (_globalValByte2)) / 1);

        if (_globalId == 1) {
          _maxLimit = _globalValue;
        } else if (_globalId == 2) {
          _minLimit = _globalValue;
        } else if (_globalId == 3) {
          _numberOfReps = _globalValue;
        } else if (_globalId == 4) {
          _numberOfSets = _globalValue;
        } else if (_globalId == 6) {
          _calibrationRequired = _globalValue;
        } else if (_globalId == 7) {
          _currentDisplacement = _globalValue;
        }
      }
      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  void _sendByte(Uint8List byteData) async {
    try {
      // _id = 5;
      // _value = 1;
      // byteData = ([_id + 128, _value.floor() / 128, _value % 128]) as Uint8List;
      print("Sending Data");
      print(byteData);
      connection!.output.add(byteData);
    } catch (e) {
      setState(() {});
    }
  }

  _resetBtReceivedData() {
    _globalId = -1;
    _globalValByte1 = -1;
    _globalValByte2 = -1;
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "Workouts",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: <Widget>[
            DropdownButton(
              underline: Container(),
              dropdownColor: Theme.of(context).colorScheme.secondary,
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.secondary,
              ),
              items: [
                DropdownMenuItem(
                  value: 'Bluetooth Settings',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.bluetooth,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Bluetooth Settings',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'logout',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.exit_to_app,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (itemidentifier) {
                if (itemidentifier == 'Bluetooth Settings') {
                  FlutterBluetoothSerial.instance.openSettings();
                }
                if (itemidentifier == 'logout') {
                  FirebaseAuth.instance.signOut();
                }
              },
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _isButtonUnavailable &&
                      _bluetoothState == BluetoothState.STATE_ON,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.yellow,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Machine:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                              DropdownButton(
                                focusColor:
                                    Theme.of(context).colorScheme.onSecondary,
                                iconEnabledColor:
                                    Theme.of(context).colorScheme.onSecondary,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                dropdownColor:
                                    Theme.of(context).colorScheme.secondary,
                                //     Theme.of(context).colorScheme.primary,
                                items: _getDeviceItems(),
                                onChanged: (value) =>
                                    setState(() => _device = value!),
                                value: _devicesList.isNotEmpty ? _device : null,
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.primary,
                                )),
                                onPressed: _isButtonUnavailable
                                    ? null
                                    : _connected
                                        ? _disconnect
                                        : _connect,
                                child: Text(
                                  _connected ? 'Disconnect' : 'Connect',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    _id = 5;
                                    _value = 1;
                                    Uint8List _dataToSend = Uint8List.fromList(
                                        ([
                                      _id + 128,
                                      _value.toInt().floor(),
                                      _value % 128
                                    ]));

                                    _sendByte(_dataToSend);
                                  },
                                  child: Text("Send Data"))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  child: isConnected
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              TextFormField(
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                decoration: InputDecoration(
                                  focusColor:
                                      Theme.of(context).colorScheme.primary,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                  label: Text(
                                    'Enter Number Of Reps:',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ),
                                controller: repsController,
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      _enteredNumberOfReps = '0';
                                    } else {
                                      _enteredNumberOfReps = value;
                                    }

                                    _id = 1;
                                    _value =
                                        int.tryParse(_enteredNumberOfReps)!;
                                    Uint8List _dataToSend = Uint8List.fromList(
                                        ([
                                      _id + 128,
                                      _value.toInt().floor(),
                                      _value % 128
                                    ]));

                                    _sendByte(_dataToSend);
                                  });
                                },
                              ),
                              Padding(padding: EdgeInsets.all(5)),
                              TextFormField(
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                decoration: InputDecoration(
                                  focusColor:
                                      Theme.of(context).colorScheme.primary,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)),
                                  label: Text(
                                    'Enter Number Of Sets:',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ),
                                controller: setsController,
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      _enteredNumberOfSets = '0';
                                    } else {
                                      _enteredNumberOfSets = value;
                                    }

                                    _id = 2;
                                    _value =
                                        int.tryParse(_enteredNumberOfSets)!;
                                    Uint8List _dataToSend = Uint8List.fromList(
                                        ([
                                      _id + 128,
                                      _value.toInt().floor(),
                                      _value % 128
                                    ]));

                                    _sendByte(_dataToSend);
                                  });
                                },
                              ),
                              Text(
                                "$_currentDisplacement Distance",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                              Text(
                                _calibrationRequired == 1
                                    ? "$_calibrationRequired Calibration completed"
                                    : "$_calibrationRequired Calibratrion Required",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                              Text(
                                "$_maxLimit cm",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                              Text(
                                "$_minLimit cm",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            'Please connect to a Sharp Reps device',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text('${device.name}'),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device!.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection!.input!.listen(_onDataReceived).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection!.close();
    // show('Device disconnected');
    if (!connection!.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    // _scaffoldKey.currentState!.(
    //   new SnackBar(
    //     content: new Text(
    //       message,
    //     ),
    //     duration: duration,
    //   ),
    // );
  }
}
