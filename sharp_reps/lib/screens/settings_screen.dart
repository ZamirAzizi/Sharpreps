import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 45,
            left: 25,
            right: 25,
            // bottom: 25,
          ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 120 / 2.5,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                backgroundImage: AssetImage(
                  "assets/images/app_loading_icon.png",
                ),
              ),
              SizedBox(width: 15),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: ListView(
                padding: EdgeInsets.all(24),
                children: [
                  SettingsGroup(
                    title: 'General',
                    subtitle: '  ',
                    titleTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    children: <Widget>[
                      buildAccount(context),
                      buildContactUs(
                        context,
                        _formKey,
                        _controller,
                      ),
                    ],
                  ),
                  SettingsGroup(
                    title: 'Feedback',
                    subtitle: '  ',
                    titleTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    children: <Widget>[
                      buildFeedback(
                        context,
                        _formKey,
                        _controller,
                      ),
                      buildReportABug(
                        context,
                        _formKey,
                        _controller,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}

// Future<bool> _changePassword(String currentPassword, String newPassword) async {
//   bool success = false;

//   //Create an instance of the current user.
//   var user = await FirebaseAuth.instance.currentUser!;
//   //Must re-authenticate user before updating the password. Otherwise it may fail or user get signed out.

//   final cred = await EmailAuthProvider.credential(
//       email: user.email!, password: currentPassword);
//   await user.reauthenticateWithCredential(cred).then((value) async {
//     await user.updatePassword(newPassword).then((_) {
//       success = true;
//       usersRef.doc(uid).update({"password": newPassword});
//     }).catchError((error) {
//       print(error);
//     });
//   }).catchError((err) {
//     print(err);
//   });

//   return success;
// }

Future<String?> changePassword(String oldPassword, String newPassword) async {
  User user = FirebaseAuth.instance.currentUser!;
  AuthCredential credential =
      EmailAuthProvider.credential(email: user.email!, password: oldPassword);

  Map<String, String?> codeResponses = {
    // Re-auth responses
    "user-mismatch": null,
    "user-not-found": null,
    "invalid-credential": null,
    "invalid-email": null,
    "wrong-password": null,
    "invalid-verification-code": null,
    "invalid-verification-id": null,
    // Update password error codes
    "weak-password": null,
    "requires-recent-login": null
  };

  try {
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
    return null;
  } on FirebaseAuthException catch (error) {
    return codeResponses[error.code] ?? "Unknown";
  }
}

Widget buildAccount(BuildContext ctx) => SimpleSettingsTile(
      leading: Icon(
        Icons.person,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      title: 'Account Settings',
      subtitle: 'Privacy, Security, Language',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Account Settings',
          ),
        ),
      ),
      onTap: () {},
    );

Widget buildFeedback(
  BuildContext ctx,
  GlobalKey _formKey,
  TextEditingController _controller,
) =>
    SimpleSettingsTile(
      leading: Icon(
        Icons.feedback,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      title: 'Feedback',
      subtitle: 'Tell us what we can do better',
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                      radius: 120 / 2.5,
                      backgroundColor: Theme.of(ctx).colorScheme.secondary,
                      backgroundImage: AssetImage(
                        "assets/images/app_loading_icon.png",
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 200,
                width: 300,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: 'Write to us here', filled: true),
                    maxLines: 10,
                    maxLength: 4096,
                    textInputAction: TextInputAction.done,
                    validator: (String? text) {
                      if (text == null || text.isEmpty) {
                        return 'Please enter Feedback';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      String message;

                      try {
                        final user = FirebaseAuth.instance.currentUser!;
                        final collection =
                            FirebaseFirestore.instance.collection('Feedback');

                        await collection.doc().set(
                          {
                            'timestamp': FieldValue.serverTimestamp(),
                            'Feedback': _controller.text,
                            'userId': user.uid
                          },
                        );
                        message = 'Feedbac submitted successfully';
                      } catch (_) {
                        message = 'Error when submiting feedback';
                      }
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(message),
                        ),
                      );
                      // Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Submit',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                    width: 50,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Cancel',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

Widget buildContactUs(
  BuildContext ctx,
  GlobalKey _formKey,
  TextEditingController _controller,
) =>
    SimpleSettingsTile(
      leading: Icon(
        Icons.contact_mail,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      title: 'Contact US',
      subtitle: 'Get in touch with us',
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                      radius: 120 / 2.5,
                      backgroundColor: Theme.of(ctx).colorScheme.secondary,
                      backgroundImage: AssetImage(
                        "assets/images/app_loading_icon.png",
                      ),
                    ),
                    SizedBox(width: 15),
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 200,
                width: 300,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: 'Write to us here', filled: true),
                    maxLines: 10,
                    maxLength: 4096,
                    textInputAction: TextInputAction.done,
                    validator: (String? text) {
                      if (text == null || text.isEmpty) {
                        return 'Please enter your enquiry';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      String message;

                      try {
                        final user = FirebaseAuth.instance.currentUser!;
                        final collection =
                            FirebaseFirestore.instance.collection('Customers');

                        await collection.doc().set(
                          {
                            'timestamp': FieldValue.serverTimestamp(),
                            'Customer Enquiry': _controller.text,
                            'userId': user.uid
                          },
                        );
                        message = 'Submitted successfully';
                      } catch (_) {
                        message = 'Error when submiting ';
                      }
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(message),
                        ),
                      );
                      // Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Submit',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                    width: 50,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Cancel',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

Widget buildReportABug(
  BuildContext ctx,
  GlobalKey _formKey,
  TextEditingController _controller,
) =>
    SimpleSettingsTile(
        leading: Icon(
          Icons.bug_report,
          color: Theme.of(ctx).colorScheme.primary,
        ),
        title: 'Reprot A Bug',
        subtitle: 'Report an issue',
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
                        radius: 120 / 2.5,
                        backgroundColor: Theme.of(ctx).colorScheme.secondary,
                        backgroundImage: AssetImage(
                          "assets/images/app_loading_icon.png",
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Report A Bug',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 200,
                  width: 300,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          hintText: 'Report a bug here', filled: true),
                      maxLines: 10,
                      maxLength: 4096,
                      textInputAction: TextInputAction.done,
                      validator: (String? text) {
                        if (text == null || text.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        String message;

                        try {
                          final user = FirebaseAuth.instance.currentUser!;
                          final collection =
                              FirebaseFirestore.instance.collection('bugs');

                          await collection.doc().set(
                            {
                              'timestamp': FieldValue.serverTimestamp(),
                              'Bug report': _controller.text,
                              'userId': user.uid
                            },
                          );
                          message = 'Bug report submitted successfully';
                        } catch (_) {
                          message = 'Error when submiting bug report';
                        }
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(message),
                          ),
                        );
                        // Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Submit',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      width: 50,
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        // onTap: () {},
        );

// {
//                     showDialog(
//                       context: ctx,
//                       builder: ((context) => AlertDialog(
//                             content: Form(
//                               key: _formKey,
//                               child: TextFormField(
//                                 controller: _controller,
//                                 keyboardType: TextInputType.multiline,
//                                 decoration: InputDecoration(
//                                     hintText: 'Report a bug here',
//                                     filled: true),
//                                 maxLines: 10,
//                                 maxLength: 4096,
//                                 textInputAction: TextInputAction.done,
//                                 validator: (String? text) {
//                                   if (text == null || text.isEmpty) {
//                                     return 'Please enter a value';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.of(ctx).pop(),
//                                 child: const Text(
//                                   'Cancel',
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () async {
//                                   String message;

//                                   try {
//                                     final user =
//                                         FirebaseAuth.instance.currentUser!;
//                                     final collection = FirebaseFirestore
//                                         .instance
//                                         .collection('bugs');

//                                     await collection.doc().set(
//                                       {
//                                         'timestamp':
//                                             FieldValue.serverTimestamp(),
//                                         'Bug report': _controller.text,
//                                         'userId': user.uid
//                                       },
//                                     );
//                                     message =
//                                         'Bug report submitted successfully';
//                                   } catch (_) {
//                                     message = 'Error when submiting bug report';
//                                   }
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(message),
//                                     ),
//                                   );
//                                   Navigator.pop(context);
//                                 },
//                                 child: const Text(
//                                   'Submit',
//                                 ),
//                               ),
//                             ],
//                           )),
//                     );
//                   },