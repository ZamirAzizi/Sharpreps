import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/workout_screen.dart';

class WorkoutsList extends StatefulWidget {
  const WorkoutsList({super.key});

  @override
  State<WorkoutsList> createState() => _WorkoutsListState();
}

class _WorkoutsListState extends State<WorkoutsList> {
  Future<void> goToWorkoutScreen(
      String workoutAutoGuid, String workoutName) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(
          workoutAutoGuid: workoutAutoGuid,
          workoutName: workoutName,
        ),
      ),
    );
  }

  final user = FirebaseAuth.instance.currentUser!; // Get Current User
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance
          .userChanges()
          .first, // On any user data changes rerun the builder and pull in the new data
      builder: (ctx, futureSnapshots) {
        if (futureSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(), // Show loading spinner when pulling data
          );
        }

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('workouts')
              .doc(user.uid)
              .collection('workout names')
              .snapshots(), // Drill down to the part of the data needed from the firebase DB in this case workouts/user.uid/workout names
          builder: (ctx, workoutsSnapshots) {
            if (workoutsSnapshots.connectionState == ConnectionState.waiting)
              return const Center(
                child:
                    CircularProgressIndicator(), // show loading spinner when retrieving data
              );

            return ListView.builder(
              // Item count based on the length of data in the DB
              itemCount: workoutsSnapshots.data!.docs.length,
              itemBuilder: (ctx, index) {
                var workoutName = workoutsSnapshots.data!.docs[index].get(
                    'workout name'); // Get the ID of the data you want so it is human legible
                var workoutAutoGuid = workoutsSnapshots.data!.docs[index].id;
                return ListTile(
                  title: Text(
                      workoutName.toString()), // print the id as workout title
                  trailing: IconButton(
                      icon: Icon(
                        Icons
                            .arrow_forward, // Icon button so that we can add exercises to the workouts created.
                      ),
                      onPressed: () =>
                          goToWorkoutScreen(workoutAutoGuid, workoutName)),
                );
              },
            );
          },
        );
      },
    );
  }
}
