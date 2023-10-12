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
        // backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBar(
          title: const Text('Settings'),
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
                })
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: ListView(
              padding: EdgeInsets.all(24),
              children: [
                SettingsGroup(
                  title: 'General',
                  titleTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  children: <Widget>[
                    buildAccount(context),
                    buildContactUs(context),
                  ],
                ),
                SettingsGroup(
                  title: 'Feedback',
                  titleTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  children: <Widget>[
                    buildFeedback(context),
                    buildReportABug(context, _formKey, _controller),
                  ],
                ),
              ],
            ),
          ),
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

Widget buildFeedback(BuildContext ctx) => SimpleSettingsTile(
      leading: Icon(
        Icons.feedback,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      title: 'Feedback',
      subtitle: 'Tell us what we can do better',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Feedback Settings',
          ),
        ),
      ),
      onTap: () {},
    );

Widget buildContactUs(BuildContext ctx) => SimpleSettingsTile(
      leading: Icon(
        Icons.contact_mail,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      title: 'Contact US',
      subtitle: 'Get in touch with us',
      child: Scaffold(
        backgroundColor: Theme.of(ctx).colorScheme.secondary,
        appBar: AppBar(
          title: Text(
            'Contact Information',
          ),
        ),
      ),
      onTap: () {},
    );

Widget buildReportABug(BuildContext ctx, GlobalKey _formKey,
        TextEditingController _controller) =>
    SimpleSettingsTile(
        leading: Icon(
          Icons.bug_report,
          color: Theme.of(ctx).colorScheme.primary,
        ),
        title: 'Reprot A Bug',
        subtitle: 'Report an issue',
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Bug Reporting',
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/background_image.png",
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: 15,
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
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      width: 50,
                    ),
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