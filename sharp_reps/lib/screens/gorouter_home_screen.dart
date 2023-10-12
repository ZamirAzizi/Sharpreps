// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sharp_reps/screens/dashboard_screen.dart';
import 'package:sharp_reps/screens/main_screen.dart';
import 'package:sharp_reps/screens/profile_screen.dart';
import 'package:sharp_reps/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _sectionANavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'sectionANav');

// This example demonstrates how to setup nested navigation using a
// BottomNavigationBar, where each bar item uses its own persistent navigator,
// i.e. navigation state is maintained separately for each item. This setup also
// enables deep linking into nested pages.

// void main() {
//   runApp(NestedTabNavigationExampleApp());
// }

/// A dialog page with Material entrance and exit animations, modal barrier color,
/// and modal barrier behavior (dialog is dismissible with a tap on the barrier).
class DialogPage<T> extends Page<T> {
  final Offset? anchorPoint;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool useSafeArea;
  final CapturedThemes? themes;
  final WidgetBuilder builder;

  const DialogPage({
    required this.builder,
    this.anchorPoint,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
      context: context,
      settings: this,
      builder: builder,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      themes: themes);
}

/// An example demonstrating how to use nested navigators
class NestedTabNavigationExampleApp extends StatelessWidget {
  /// Creates a NestedTabNavigationExampleApp
  NestedTabNavigationExampleApp({super.key});

  final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/a',
    routes: <RouteBase>[
      // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          // Return the widget that implements the custom shell (in this case
          // using a BottomNavigationBar). The StatefulNavigationShell is passed
          // to be able access the state of the shell and to navigate to other
          // branches in a stateful way.
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // The route branch for the first tab of the bottom navigation bar.
          StatefulShellBranch(
            navigatorKey: _sectionANavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the first tab of the
                // bottom navigation bar.
                path: '/a',
                builder: (BuildContext context, GoRouterState state) =>
                    const DashboardScreen(),
                // routes: <RouteBase>[
                // The details screen to display stacked on navigator of the
                // first tab. This will cover screen A but not the application
                // shell (bottom navigation bar).
                // GoRoute(
                //   path: 'details',
                //   builder: (BuildContext context, GoRouterState state) =>
                //       const DetailsScreen(label: 'A'),
                // ),
                // ],
              ),
            ],
          ),

          // The route branch for the second tab of the bottom navigation bar.
          StatefulShellBranch(
            // It's not necessary to provide a navigatorKey if it isn't also
            // needed elsewhere. If not provided, a default key will be used.
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the second tab of the
                // bottom navigation bar.
                path: '/',
                builder: (BuildContext context, GoRouterState state) =>
                    MainScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'dialog',
                    builder: (BuildContext context, GoRouterState state) {
                      return AlertDialog();
                    },
                  ),
                ],
              ),
            ],
          ),

          // The route branch for the third tab of the bottom navigation bar.
          // StatefulShellBranch(
          //   routes: <RouteBase>[
          //     GoRoute(
          //       // The screen to display as the root in the third tab of the
          //       // bottom navigation bar.
          //       path: '/c',
          //       builder: (BuildContext context, GoRouterState state) =>
          //           // {
          //           // return SensorPage(device: FlutterBlue.instance.state);

          //           // if (FlutterBlue.instance.state == ConnectionState.active) {
          //           //   return SensorPage(device: device);
          //           // } else {
          //           //   return Center(child: CircularProgressIndicator());
          //           // }
          //           FlutterBlueApp(),
          //       // },
          //       // FlutterBlueApp(),
          //       // routes: <RouteBase>[
          //       // GoRoute(
          //       //   path: 'details',
          //       //   builder: (BuildContext context, GoRouterState state) =>
          //       //       DetailsScreen(
          //       //     label: 'C',
          //       //     extra: state.extra,
          //       //   ),
          //       // ),
          //       // ],
          //     ),
          //   ],
          // ),
          // The route branch for the third tab of the bottom navigation bar.
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the third tab of the
                // bottom navigation bar.
                path: '/d',
                builder: (BuildContext context, GoRouterState state) =>
                    ProfileScreen(),
                // routes: <RouteBase>[
                // GoRoute(
                //   path: 'details',
                //   builder: (BuildContext context, GoRouterState state) =>
                //       DetailsScreen(
                //     label: 'C',
                //     extra: state.extra,
                //   ),
                // ),
                // ],
              ),
            ],
          ),
          // The route branch for the third tab of the bottom navigation bar.
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the third tab of the
                // bottom navigation bar.
                path: '/e',
                builder: (BuildContext context, GoRouterState state) =>
                    SettingsScreen(),
                // FlutterBlueApp(),
                // routes: <RouteBase>[
                // GoRoute(
                //   path: 'details',
                //   builder: (BuildContext context, GoRouterState state) =>
                //       DetailsScreen(
                //     label: 'C',
                //     extra: state.extra,
                //   ),
                // ),
                // ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sharp Reps',
      routerConfig: _router,
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
    );
  }
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        // Here, the items of BottomNavigationBar are hard coded. In a real
        // world scenario, the items would most likely be generated from the
        // branches of the shell route, which can be fetched using
        // `navigationShell.route.branches`.
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: 'Dashboard',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.home,
          //     color: Theme.of(context).colorScheme.onPrimary,
          //   ),
          //   label: 'Home',
          //   backgroundColor: Theme.of(context).colorScheme.primary,
          // ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.fitness_center_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: 'Workout',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: 'Profile',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: 'Settings',
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        selectedItemColor: Colors.black,

        onTap: (int index) => _onTap(context, index),
      ),
    );
  }

  /// Navigate to the current location of the branch at the provided index when
  /// tapping an item in the BottomNavigationBar.
  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so makes sure the last navigation state of the
    // Navigator for the branch is restored.
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
