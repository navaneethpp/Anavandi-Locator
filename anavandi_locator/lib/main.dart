// main.dart

// This is the main entry point of the Flutter application 'Anavandi Locator'.
// It sets up the Flutter environment, initializes Firebase, defines the app's theme,
// and specifies the splash screen as the initial screen to be displayed when the app starts.

// Documentation:
//
// File Purpose:
// The `main.dart` file is the starting point for the entire Flutter application. It's responsible for:
// - Setting up the Flutter framework and application environment.
// - Initializing Firebase, which is likely used for backend services such as database (Firestore) and potentially authentication or push notifications.
// - Defining the overall theme of the application (using `ThemeData`).
// - Specifying the root widget of the application, which is set to `SplashScreen`. This means the `SplashScreen` widget will be the first screen displayed when the app is launched.
// - Locking the app orientation to portrait mode only using `SystemChrome.setPreferredOrientations`.
//
// Working:
// - `void main() async { ... }`: The main function is the entry point of the Dart application. The `async` keyword allows the use of `await` inside the function for asynchronous operations.
// - `WidgetsFlutterBinding.ensureInitialized();`:  Ensures that the Flutter framework is properly initialized, especially necessary when performing native operations before `runApp` (like Firebase initialization). It's called *before* Firebase is initialized.
// - `await Firebase.initializeApp();`: Initializes Firebase for the application. This line is crucial for connecting the Flutter app to the Firebase project. `await` ensures that Firebase is fully initialized before proceeding.
// - `WidgetsFlutterBinding.ensureInitialized();`:  Redundant call. `WidgetsFlutterBinding.ensureInitialized()` is already called before `Firebase.initializeApp()`. It's not needed again immediately after. It is generally called once at the very beginning of the `main` function.
// - `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);`: Sets the preferred device orientation to portrait mode only. This line ensures that the app will only run in portrait orientation, and prevents rotation to landscape.
// - `runApp(const MyApp());`:  Runs the Flutter application, starting from the `MyApp` widget, which is defined as a `StatelessWidget` below.
//
// MyApp Widget:
// - `class MyApp extends StatelessWidget { ... }`: Defines the root widget of the application, `MyApp`.
// - `const MyApp({super.key});`: Constructor for `MyApp`.
// - `@override Widget build(BuildContext context) { ... }`:  The `build` method defines the UI structure for `MyApp`.
// - `return MaterialApp(...)`: Returns a `MaterialApp` widget, which is the foundation for Material Design apps in Flutter.
//     - `debugShowCheckedModeBanner: false,`:  Removes the debug banner that is typically shown in debug builds.
//     - `title: 'Anavandi Locator',`: Sets the title of the application, which might be displayed in the app switcher or window title bar.
//     - `theme: ThemeData(primarySwatch: Colors.blue),`: Defines the default theme for the application using a blue primary color swatch. This sets the overall color scheme for UI elements.
//     - `home: const SplashScreen(),`:  Sets the `SplashScreen` widget as the home (initial) screen of the application. This specifies that the splash screen will be the first screen users see when the app launches.
//
// Dependencies:
// - `flutter/material.dart`: For Flutter UI framework and widgets.
// - `firebase_core/firebase_core.dart`: For Firebase initialization.
// - `flutter/services.dart`: For `SystemChrome` to control system-level settings like device orientation.
// - `splash_screen.dart`: (Imported)  The `SplashScreen` widget that is set as the home screen.
//
// Usage:
// This file is automatically executed when the Flutter application starts. It initializes the necessary components and launches the `SplashScreen`, which then controls the initial user experience.

import 'package:anavandi_locator/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // WidgetsFlutterBinding.ensureInitialized(); // Redundant call, removed
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anavandi Locator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}
