import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sharp_reps/widgets/exercises_list.dart';

import '../data/workout_data.dart';

// text controllers
final exerciseNameController = TextEditingController();
final weightController = TextEditingController();
final set1Controller = TextEditingController();
final repsController = TextEditingController();
final setsController = TextEditingController();
// new exercise DB vars
var _enteredExerciseName = '';
var _enteredWeight = '';
var _enteredReps = '';
var _enteredSets = '';

var _workoutAutoGuid;

class WorkoutScreen extends StatefulWidget {
  final String workoutName;
  final String workoutAutoGuid;
  const WorkoutScreen(
      {super.key, required this.workoutName, required this.workoutAutoGuid});

  @override
  State<WorkoutScreen> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutScreen> {
  final double profileHeight = 120;

  // checkbox was tapped
  onCheckboxChanged() {}

  // final user = FirebaseAuth.instance.currentUser!; // Get Current User

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/background_closeup.png"), // <-- BACKGROUND IMAGE
                fit: BoxFit.cover,
              ),
            ),
          ),
          Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                _workoutAutoGuid = widget.workoutAutoGuid;
                DialogService.load(context);
              },
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
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
                    // mainAxisAlignment: MainAxisAlignment.center,
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
                          widget.workoutName + ' Exercises',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ExercisesList(
                      workoutAutoGuid: widget.workoutAutoGuid,
                      WorkoutName: widget.workoutName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DialogService {
  const DialogService._();

  static IDialog? _current;

  static Future<void> load(
    BuildContext context, {
    String? title,
  }) async {
    _current = LoadDialog(title: title);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _current ?? LoadDialog(title: title),
    );
  }

  static void dispose() {
    if (_current != null) {
      _current!.dismiss();
      _current = null;
    }
  }
}

mixin IDialogService {
  void dismiss();
}

abstract class IDialog extends StatelessWidget with IDialogService {
  const IDialog({Key? key}) : super(key: key);
}

// ignore: must_be_immutable
class LoadDialog extends IDialog {
  final String? title;
  LoadDialog({
    Key? key,
    this.title,
  }) : super(key: key);

  BuildContext? _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Add a new exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // exercise name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    label: Text('Exercise Name:'),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the exercise name!';
                    }
                    return null;
                  },
                  controller: exerciseNameController,
                  onChanged: (value) {
                    _enteredExerciseName = value;
                  },
                ),
              ),

              // weight
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    label: Text('Enter Weight Used:'),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the weight used!';
                    }
                    return null;
                  },
                  controller: weightController,
                  onChanged: (value) {
                    _enteredWeight = value;
                  },
                ),
              ),

              // sets
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    label: Text('Enter Number Of Sets:'),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the number of sets!';
                    }
                    return null;
                  },
                  controller: setsController,
                  onChanged: (value) {
                    _enteredSets = value;
                  },
                ),
              ),

              // reps
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    label: Text('Enter Number Of Reps:'),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter number of reps!';
                    }
                    return null;
                  },
                  controller: repsController,
                  onChanged: (value) {
                    _enteredReps = value;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () => save(context),
            child: Text('Save'),
            color: Theme.of(context).colorScheme.primary,
          ),
          // save button
          MaterialButton(
            onPressed: cancel,
            child: Text('Cancel'),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  @override
  void dismiss() {
    Navigator.pop(_context!);
  }
}

//save workout
void save(context) {
  // saved new exercise to firebase DB
  _saveNewExercise(context);

  // // pop dialog box
  // DialogService.dispose();
  // Clear controllers
  clear();
}

void cancel() {
  DialogService.dispose();
  clear();
}

void clear() {
  exerciseNameController.clear();
  weightController.clear();
  repsController.clear();
  setsController.clear();
}

// Saving new exercies into the workout it was invoked by
Future<void> _saveNewExercise(BuildContext context) async {
  FocusScope.of(context).unfocus();
  final user = FirebaseAuth.instance.currentUser!;
  final userData =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  try {
    if (_enteredExerciseName == '' ||
        _enteredWeight == '' ||
        _enteredReps == '' ||
        _enteredSets == '') {
      return;
    } else {
      FirebaseFirestore.instance
          .collection('workouts')
          .doc(user.uid)
          .collection('workout names')
          .doc(_workoutAutoGuid)
          .collection('exercises')
          .doc()
          .set(
        {
          'exercise name': _enteredExerciseName,
          'weight used': _enteredWeight,
          'number of reps': _enteredReps,
          'number of sets': _enteredSets,
          'createdAt': Timestamp.now(),
          'userId': user.uid,
          'username': userData['username'],
          'checkbox': false,
        },
      );
    }
    //Clear the text
    _enteredExerciseName = "";
    _enteredWeight = '';
    _enteredReps = '';
    _enteredSets = '';

    DialogService.dispose();
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
