import 'package:flutter/material.dart';

class ExerciseDetail extends StatefulWidget {
  const ExerciseDetail({super.key});

  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Details'),
      ),
    );
  }
}
