import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExerciseDetail extends StatefulWidget {
  final String exerciseName;
  final String weight;
  final String reps;
  final String sets;
  final bool isCompleted;
  void Function(bool?)? onCheckboxChanged;
  final String workoutAutoGuid;
  final String exerciseAutoGuid;
  final String workoutName;
  ExerciseDetail({
    super.key,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.isCompleted,
    required this.onCheckboxChanged,
    required this.workoutAutoGuid,
    required this.exerciseAutoGuid,
    required this.workoutName,
  });

  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  final double profileHeight = 120;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 45,
                left: 25,
                right: 25,
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    backgroundImage: AssetImage(
                      "assets/images/app_loading_icon.png",
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      widget.exerciseName + ' Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                  ),
                  // IconButton(
                  //   onPressed: () => FirebaseAuth.instance.signOut(),
                  //   icon: Icon(
                  //     Icons.exit_to_app,
                  //     color: Theme.of(context).colorScheme.onSecondary,
                  //   ),
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
