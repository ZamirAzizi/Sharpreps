import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharp_reps/screens/Bluetooth/BLE_Android_Screen.dart';

class ExerciseTile extends StatefulWidget {
  final String exerciseName;
  final String weight;
  final String reps;
  final String sets;
  final bool isCompleted;
  void Function(bool?)? onCheckboxChanged;
  final String workoutAutoGuid;
  final String exerciseAutoGuid;

  ExerciseTile({
    super.key,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.isCompleted,
    required this.onCheckboxChanged,
    required this.workoutAutoGuid,
    required this.exerciseAutoGuid,
  });

  @override
  State<ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<ExerciseTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
          ),
          color: Theme.of(context).colorScheme.secondary),
      // color: Theme.of(context).colorScheme.secondary,
      child: ListTile(
        title: Text(
          widget.exerciseName,
        ),
        subtitle: Row(
          children: <Widget>[
            // Weight
            Chip(
              backgroundColor: Theme.of(context).colorScheme.primary,
              clipBehavior: Clip.antiAlias,
              label: Text(
                "${widget.weight} kg",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            // Reps
            Chip(
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text(
                "${widget.reps} reps",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            // Sets
            Chip(
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text(
                "${widget.sets} sets",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        trailing: Wrap(
          spacing: -15,
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          children: [
            Checkbox(
              value: widget.isCompleted,
              onChanged: (onCheckboxChanged) {
                if (onCheckboxChanged == true) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlutterBlueApp(),
                      ));
                }
                setState(() {
                  onCheckboxChanged = !onCheckboxChanged!;
                });
                _checkboxChanged(context, onCheckboxChanged!,
                    widget.exerciseAutoGuid, widget.workoutAutoGuid);
              },
              checkColor: Colors.white,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            Text(
              widget.isCompleted ? 'Completed' : 'Start Workout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _checkboxChanged(BuildContext context, bool Val, String exAutoGuid,
    String wkAutoGuid) async {
  FocusScope.of(context).unfocus();
  final user = FirebaseAuth.instance.currentUser!;

  FirebaseFirestore.instance
      .collection('workouts')
      .doc(user.uid)
      .collection('workout names')
      .doc(wkAutoGuid)
      .collection('exercises')
      .doc(exAutoGuid)
      .update(
    {
      'checkbox': !Val,
    },
  );
}
