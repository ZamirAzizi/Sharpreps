import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharp_reps/screens/workout_screen.dart';
import 'package:sharp_reps/widgets/workouts_list.dart';
// import 'package:sharp_reps/widgets/workouts_list.dart';

// import '../data/workout_data.dart';

// text controller
final newWorkoutNameController = TextEditingController();
// vars for
var _enteredWorkoutName;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  final double coverHeight = 220;
  final double profileHeight = 120;
  final user = FirebaseAuth.instance.currentUser!; // Get Current User

  // Future<void> _saveWorkout() async {
  //   FocusScope.of(context).unfocus();
  //   // Get user id
  //   final user = FirebaseAuth.instance.currentUser!;

  //   // Store new workout in database.
  //   FirebaseFirestore.instance
  //       .collection('workouts')
  //       .doc(user.uid)
  //       .collection('workout names')
  //       .doc()
  //       .set({
  //     'createdAt': Timestamp.now(),
  //     'workout name': _enteredWorkoutName
  //   });

  //   //Clear the text
  //   newWorkoutNameController.clear();
  // }

  // // create a new workout
  // void createNewWorkout() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Create new workout'),
  //       content: TextField(
  //         controller: newWorkoutNameController,
  //         onChanged: (value) {
  //           setState(() {
  //             _enteredWorkoutName = value;
  //           });
  //         },
  //       ),
  //       actions: [
  //         // save button
  //         MaterialButton(
  //           onPressed: save,
  //           child: Text('Save'),
  //           color: Theme.of(context).colorScheme.primary,
  //         ),
  //         // Cancel button
  //         MaterialButton(
  //           onPressed: cancel,
  //           child: Text('Cancel'),
  //           color: Theme.of(context).colorScheme.primary,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // //save workout
  // void save() {
  //   // Firestore firebase DB retrieving stored workouts
  //   _saveWorkout();

  //   // pop dialog box

  //   clear();
  // }

  // void cancel() {
  //   // GoRouter.of(context).pop();
  //   Navigator.pop(context);
  //   clear();
  // }

  // void clear() {
  //   newWorkoutNameController.clear();
  // }

  @override
  Widget build(BuildContext context) {
    final top = coverHeight / 2;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Workouts"),
      //   actions: <Widget>[
      //     DropdownButton(
      //       underline: Container(),
      //       icon: Icon(
      //         Icons.more_vert,
      //         color: Theme.of(context).colorScheme.secondary,
      //       ),
      //       items: [
      //         DropdownMenuItem(
      //           value: 'logout',
      //           child: Row(
      //             children: <Widget>[
      //               Icon(
      //                 Icons.exit_to_app,
      //                 color: Theme.of(context).colorScheme.onSecondary,
      //               ),
      //               SizedBox(
      //                 width: 8,
      //               ),
      //               Text('Logout'),
      //             ],
      //           ),
      //         ),
      //       ],
      //       onChanged: (itemidentifier) {
      //         if (itemidentifier == 'logout') {
      //           FirebaseAuth.instance.signOut();
      //         }
      //       },
      //     )
      //   ],
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: () async {
          DialogService.load(context);
        },
      ),
      body: Column(
        children: <Widget>[
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
                CircleAvatar(
                  radius: profileHeight / 2.5,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  backgroundImage: AssetImage(
                    "assets/images/app_loading_icon.png",
                  ),
                ),
                SizedBox(width: 15),
                Text(
                  'Workouts',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: WorkoutsList(),
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
        title: Text('Create new workout'),
        content: TextFormField(
          controller: newWorkoutNameController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a workout name!';
            }
            return null;
          },
          onChanged: (value) {
            _enteredWorkoutName = value;
          },
        ),
        actions: [
          // Cancel button
          MaterialButton(
            onPressed: cancel,
            child: Text('Cancel'),
            color: Theme.of(context).colorScheme.primary,
          ),

          // save button
          MaterialButton(
            onPressed: () => save(context),
            child: Text('Save'),
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
void save(BuildContext context) {
  // Firestore firebase DB retrieving stored workouts
  _saveWorkout(context);
  clear();
  // pop dialog box
  // DialogService.dispose();
}

void cancel() {
  // GoRouter.of(context).pop();
  DialogService.dispose();
  clear();
}

void clear() {
  newWorkoutNameController.clear();
}

Future<void> _saveWorkout(BuildContext context) async {
  FocusScope.of(context).unfocus();
  // Get user id
  final user = FirebaseAuth.instance.currentUser!;
  final date = DateTime.parse(DateTime.now().toString());
  var formattedDate = "${date.day}-${date.month}-${date.year}";
  // Store new workout in database.
  if (_enteredWorkoutName == null) {
    // DialogService.dispose();
    // newWorkoutNameController.clear();
    return;
  } else {
    FirebaseFirestore.instance
        .collection('workouts')
        .doc(user.uid)
        .collection('workout names')
        .doc()
        .set(
      {
        'created': formattedDate,
        'workout name': _enteredWorkoutName,
      },
    );
  }

  //Clear the text
  newWorkoutNameController.clear();
  _enteredWorkoutName = null;
  DialogService.dispose();
}
