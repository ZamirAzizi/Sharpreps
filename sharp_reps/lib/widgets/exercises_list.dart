import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharp_reps/screens/exercise_detail.dart';

import '../components/exercise_tile.dart';

// import '../components/exercise_tile.dart';

class ExercisesList extends StatefulWidget {
  final String workoutAutoGuid;
  final String WorkoutName;

  const ExercisesList({
    super.key,
    required this.workoutAutoGuid,
    required this.WorkoutName,
  });

  @override
  State<ExercisesList> createState() => _ExercisesListState();
}

class _ExercisesListState extends State<ExercisesList> {
  final user = FirebaseAuth.instance.currentUser!;

  // checkbox was tapped
  // onCheckboxChanged(String workoutName, String exerciseName) {
  //   Provider.of<WorkoutData>(context, listen: false)
  //       .checkOffExercise(workoutName, exerciseName);
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance
          .userChanges()
          .first, // On any user data changes rerun the builder and pull in the new data
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('workouts')
              .doc(user.uid)
              .collection('workout names')
              .doc(widget.workoutAutoGuid)
              .collection('exercises')
              .snapshots(),
          builder: (context, exercisesSnapshot) {
            if (exercisesSnapshot.connectionState == ConnectionState.waiting)
              return const Center(
                child:
                    CircularProgressIndicator(), // show loading spinner when retrieving data
              );
            return ListView.builder(
              itemCount: exercisesSnapshot.data!.docs
                  .length, // Item count based on the length of data in the DB
              itemBuilder: (ctx, index) {
                var exerciseAutoGuid = exercisesSnapshot.data!.docs[index].id;

                var exerciseName =
                    exercisesSnapshot.data!.docs[index].get('exercise name');
                return ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExerciseDetail(),
                    ),
                  ),
                  title: SingleChildScrollView(
                    child: ExerciseTile(
                      exerciseName: exerciseName,
                      exerciseAutoGuid: exerciseAutoGuid,
                      workoutAutoGuid: widget.workoutAutoGuid,
                      weight: exercisesSnapshot.data!.docs[index]
                          ['weight used'],
                      reps: exercisesSnapshot.data!.docs[index]
                          ['number of reps'],
                      sets: exercisesSnapshot.data!.docs[index]
                          ['number of sets'],
                      isCompleted: exercisesSnapshot.data!.docs[index]
                          ['checkbox'],
                      onCheckboxChanged: (val) {
                        val = val!;
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
