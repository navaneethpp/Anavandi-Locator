import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:anavandi_locator/app.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Disable screen rotation and force portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(const App());
  });
}
