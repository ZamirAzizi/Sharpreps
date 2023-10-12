import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/auth/auth_form.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

final _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLoading = false;

  void _submitAuthForm(
    String firstname,
    String lastname,
    String number,
    String gender,
    String email,
    String password,
    String username,
    XFile image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    final UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(authResult.user!.uid + '.jpg');

        await ref.putFile(File(image.path)).whenComplete(() => null);

        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.uid)
            .set({
          'first name': firstname,
          'last name': lastname,
          'number': number,
          'gender': gender,
          'username': username,
          'email': email,
          'image_url': url
        });
      }
    } on FirebaseAuthException catch (err) {
      var message = 'An error occured, please check your credentials';
      if (err.message != null) {
        message = err.message.toString();
      }

      var snackbar = SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(ctx).colorScheme.error,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      setState(() {
        _isLoading = false;
      });
    }
    // catch (err) {
    //   // print(err);
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/app_loading_icon.png",
              scale: 4,
            ),
            SizedBox(
              width: 5,
            ),
            AuthForm(_submitAuthForm, _isLoading),
          ],
        ),
      ),
    );
  }
}
