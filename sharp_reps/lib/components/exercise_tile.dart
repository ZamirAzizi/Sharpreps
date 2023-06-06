import 'package:flutter/material.dart';

class ExerciseTile extends StatelessWidget {
  final String exerciseName;
  final String weight;
  final String reps;
  final String sets;
  // final bool isCompleted;
  // void Function(bool?)? onCheckboxChanged;

  ExerciseTile({
    super.key,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    // required this.isCompleted,
    // required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: ListTile(
        title: Text(
          exerciseName,
        ),
        subtitle: Row(
          children: <Widget>[
            // Weight
            Chip(
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text(
                "${weight} kg",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            // Reps
            Chip(
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text("$reps reps",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  )),
            ),
            // Sets
            Chip(
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text(
                "$sets sets",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        // trailing: Checkbox(
        //   value: isCompleted,
        //   onChanged: (value) => onCheckboxChanged!(value),
        //   checkColor: Colors.black,
        //   activeColor: Theme.of(context).colorScheme.primary,
        // ),
      ),
    );
  }
}
