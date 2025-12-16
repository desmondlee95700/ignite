import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/pip_material_app.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/screens/appdata_bloc/appdata_bloc.dart';
import 'package:ignite/screens/lyrics/thumbnail_cubit_bloc/generate_thumbnail_cubit.dart';
import 'package:ignite/screens/pip_bloc/pip_bloc.dart';
import 'package:ignite/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();



  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // runApp(const MyApp());
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => PipBloc()),
      BlocProvider(create: (_) => AppDataBloc()),
      BlocProvider(create: (_) => PdfThumbnailsCubit()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light().copyWith(
        scaffoldBackgroundColor: darkThemeColor,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: darkThemeColor,
          backgroundColor: darkThemeColor,
        ),
      ),
      //dark: ThemeData.dark(useMaterial3: true),
      dark: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkThemeColor,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: darkThemeColor,
          backgroundColor: darkThemeColor,
        ),
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => PiPMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
