import 'package:provider/provider.dart';
import 'package:sharp_reps/data/workout_data.dart';
import 'package:sharp_reps/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/screens/home_screen.dart';
import '/screens/auth_screen.dart';
import '/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutData(),
      child: MaterialApp(
        title: 'Flutter Chat',
        theme: ThemeData(
          colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: Color.fromARGB(255, 230, 188, 63),
              onPrimary: Colors.black,
              secondary: Colors.black,
              onSecondary: Color.fromARGB(255, 230, 188, 63),
              error: Colors.red,
              onError: Colors.white,
              background: Color.fromARGB(255, 0, 0, 0),
              onBackground: Color.fromARGB(255, 228, 210, 53),
              surface: Color.fromARGB(255, 230, 188, 63),
              onSurface: Colors.black),
          buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: Colors.red,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (userSnapshot.hasData) {
              return const HomeScreen();
            }
            return const AuthScreen();
          },
        ),
      ),
    );
  }
}
