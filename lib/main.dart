import 'dart:async';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/splash_screen.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
        ),
      ),
      dark: ThemeData.dark(useMaterial3: true),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
