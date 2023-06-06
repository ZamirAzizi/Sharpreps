import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sharp_reps/widgets/exercises_list.dart';

import '../data/workout_data.dart';

class WorkoutScreen extends StatefulWidget {
  final String workoutName;
  final String workoutAutoGuid;
  const WorkoutScreen(
      {super.key, required this.workoutName, required this.workoutAutoGuid});

  @override
  State<WorkoutScreen> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutScreen> {
  // checkbox was tapped
  // void onCheckboxChanged(String workoutName, String exerciseName) {
  //   Provider.of<WorkoutData>(context, listen: false)
  //       .checkOffExercise(workoutName, exerciseName);
  // }

  // text controllers
  final exerciseNameController = TextEditingController();
  final weightController = TextEditingController();
  final repsController = TextEditingController();
  final setsController = TextEditingController();
  // new exercise DB vars
  var _enteredExerciseName = '';
  var _enteredWeight = '';
  var _enteredReps = '';
  var _enteredSets = '';

  // Saving new exercies into the workout it was invoked by
  Future<void> _saveNewExercise() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance
        .collection('workouts')
        .doc(user.uid)
        .collection('workout names')
        .doc(widget.workoutAutoGuid)
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
      },
      // FirebaseFirestore.instance // Working
      //     .collection('workouts')
      //     .doc(user.uid)
      //     .collection('workout names')
      //     .doc(widget.workoutAutoGuid)
      //     .collection('exercises')
      //     .doc(_enteredExerciseName)
      //     // .collection(_enteredExerciseName)
      //     .set(
      //   {
      //     'exercise name': _enteredExerciseName,
      //     'weight used': _enteredWeight,
      //     'number of reps': _enteredReps,
      //     'number of sets': _enteredSets,
      //     'createdAt': Timestamp.now(),
      //     'userId': user.uid,
      //     'username': userData['username'],
      //   },
    );
    clear();
  }

  // create a new exercise
  void createNewExercise() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add a new exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // exercise name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    label: Text('Exercise Name:'),
                  ),
                  controller: exerciseNameController,
                  onChanged: (value) {
                    setState(() {
                      _enteredExerciseName = value;
                    });
                  },
                ),
              ),

              // weight
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    label: Text('Enter Weight Used:'),
                  ),
                  controller: weightController,
                  onChanged: (value) {
                    setState(() {
                      _enteredWeight = value;
                    });
                  },
                ),
              ),
              // reps
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    label: Text('Enter Number Of Reps:'),
                  ),
                  controller: repsController,
                  onChanged: (value) {
                    setState(() {
                      _enteredReps = value;
                    });
                  },
                ),
              ),
              // sets
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    label: Text('Enter Number Of Sets:'),
                  ),
                  controller: setsController,
                  onChanged: (value) {
                    setState(() {
                      _enteredSets = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: save,
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

  //save workout
  void save() {
    // saved new exercise to firebase DB
    _saveNewExercise();

    // // pop dialog box
    Navigator.pop(context);
    // Clear controllers
    clear();
  }

  void cancel() {
    Navigator.pop(context);
    clear();
  }

  void clear() {
    exerciseNameController.clear();
    weightController.clear();
    repsController.clear();
    setsController.clear();
  }

  // final user = FirebaseAuth.instance.currentUser!; // Get Current User

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: Text(widget.workoutName + ' Exercises'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewExercise,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Container(
            child: ExercisesList(workoutAutoGuid: widget.workoutAutoGuid),
            color: Colors.black12),
      ),
    );
  }
}
