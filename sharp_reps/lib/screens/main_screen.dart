import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharp_reps/widgets/workouts_list.dart';

import '../data/workout_data.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // text controller
  final newWorkoutNameController = TextEditingController();
  // vars for
  var _enteredWorkoutName = '';

  Future<void> _saveWorkout() async {
    FocusScope.of(context).unfocus();
    // Get user id
    final user = FirebaseAuth.instance.currentUser!;

    // Store new workout in database.
    FirebaseFirestore.instance
        .collection('workouts')
        .doc(user.uid)
        .collection('workout names')
        .doc()
        .set({
      'createdAt': Timestamp.now(),
      'workout name': _enteredWorkoutName
    });

    //Clear the text
    newWorkoutNameController.clear();
  }

  // create a new workout
  void createNewWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create new workout'),
        content: TextField(
          controller: newWorkoutNameController,
          onChanged: (value) {
            setState(() {
              _enteredWorkoutName = value;
            });
          },
        ),
        actions: [
          // save button
          MaterialButton(
            onPressed: save,
            child: Text('Save'),
            color: Theme.of(context).colorScheme.primary,
          ),
          // Cancel button
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
    // Firestore firebase DB retrieving stored workouts
    _saveWorkout();

    // pop dialog box
    Navigator.pop(context);
    clear();
  }

  void cancel() {
    Navigator.pop(context);
    clear();
  }

  void clear() {
    newWorkoutNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Workouts Home"),
          actions: <Widget>[
            DropdownButton(
              underline: Container(),
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.secondary,
              ),
              items: [
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
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
              onChanged: (itemidentifier) {
                if (itemidentifier == 'logout') {
                  FirebaseAuth.instance.signOut();
                }
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: createNewWorkout,
        ),
        body: WorkoutsList(),
      ),
    );
  }
}
