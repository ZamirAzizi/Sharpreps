import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../pickers/user_image_picker.dart';

class AuthForm extends StatefulWidget {
  const AuthForm(this.submitFn, this.isLoading, {super.key});

  final bool isLoading;
  final void Function(
    String firstname,
    String lastname,
    String number,
    String Gender,
    String email,
    String poassword,
    String username,
    XFile image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userFirstName = '';
  var _userLastName = '';
  var _userNumber = '';
  var _userGender = '';
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  XFile? _userImageFile;

  void _pickedImage(XFile image) {
    _userImageFile = image;
  }

  void _trysubmit() {
    final isValid = _formKey.currentState!.validate();

    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please pick an image'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
        _userFirstName.trim(),
        _userLastName.trim(),
        _userNumber,
        _userGender.trim(),
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        _userImageFile != null ? _userImageFile! : XFile(''),
        _isLogin,
        context,
      );
      // Use the values to send auth request
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Theme.of(context).colorScheme.background,
        elevation: 25,
        shadowColor: Colors.black,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (!_isLogin) UserImagePicker(_pickedImage),
                  if (!_isLogin)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const ValueKey('name'), // filter for profanity
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a name!';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            onSaved: (value) {
                              _userFirstName = value
                                  .toString(); // change this to be save to _userName
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextFormField(
                            key: const ValueKey(
                                'surname'), // filter for profanity
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a surname!';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Surname'),
                            onSaved: (value) {
                              _userLastName = value
                                  .toString(); // change this to be save to _userSurname
                            },
                          ),
                        ),
                      ],
                    ),
                  if (!_isLogin)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const ValueKey(
                                'Number'), // filter for profanity
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a phone number!';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Phone Number'),
                            onSaved: (value) {
                              _userNumber = value
                                  .toString(); // change this to be save to _userName
                            },
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextFormField(
                            key: const ValueKey(
                                'gender'), // filter for profanity
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a gender!';
                              }
                              return null;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Gender'),
                            onSaved: (value) {
                              _userGender = value
                                  .toString(); // change this to be save to _userSurname
                            },
                          ),
                        ),
                      ],
                    ),
                  TextFormField(
                    key: const ValueKey('email'),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address!';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(labelText: 'Email address'),
                    onSaved: (value) {
                      _userEmail = value.toString();
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: const ValueKey('username'),
                      autocorrect: true,
                      textCapitalization: TextCapitalization.words,
                      enableSuggestions: false,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters ';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Username'),
                      onSaved: (value) {
                        _userName = value.toString();
                      },
                    ),
                  TextFormField(
                    key: const ValueKey('password'),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long!';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value.toString();
                    },
                  ),
                  const SizedBox(height: 12),
                  if (widget.isLoading) const CircularProgressIndicator(),
                  if (!widget.isLoading &&
                      defaultTargetPlatform == TargetPlatform.android)
                    ElevatedButton(
                      onPressed: _trysubmit,
                      child: Text(_isLogin ? 'Login' : 'Signup'),
                    ),
                  if (!widget.isLoading &&
                      defaultTargetPlatform == TargetPlatform.iOS)
                    CupertinoButton.filled(
                      child: Text(_isLogin ? 'Login' : 'Signup'),
                      onPressed: _trysubmit,
                    ),
                  if (widget.isLoading) const CircularProgressIndicator(),
                  if (!widget.isLoading &&
                      defaultTargetPlatform == TargetPlatform.android)
                    TextButton(
                      style: TextButtonTheme.of(context).style,
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin
                          ? 'Create new account'
                          : 'I already have an account'),
                    ),
                  if (!widget.isLoading &&
                      defaultTargetPlatform == TargetPlatform.iOS)
                    CupertinoButton(
                      child: Text(_isLogin
                          ? 'Create new account'
                          : 'I already have an account'),
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
