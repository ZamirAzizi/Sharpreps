import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/images/app_loading_icon.png",
            height: 250,
            width: 250,
          ),
          // Text(
          //   'Sharpen Up Your Reps',
          //   style: TextStyle(
          //     color: Theme.of(context).colorScheme.primary,
          //     fontSize: 20,
          //     fontStyle: FontStyle.italic,
          //   ),
          // ),
        ],
      ),
    );
  }
}
