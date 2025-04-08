import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ignite/screens/app_body.dart';
import 'package:ignite/screens/appdata_bloc/appdata_bloc.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AppDataBloc _appDataBloc;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    _appDataBloc = context.read<AppDataBloc>();
    _appDataBloc.add(FetchAndCacheAppData());

    // Listen for the state and navigate when loaded
    _listenAndNavigate();
  }

  void _listenAndNavigate() {
    // Wait for success or failure
    _appDataBloc.stream.listen((state) {
      if (state.status == AppDataStatus.success ||
          state.status == AppDataStatus.failure) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 600),
              reverseDuration: const Duration(milliseconds: 600),
              isIos: true,
              child: const AppBody(),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Image.asset(
            "assets/images/ignite_icon.jpg",
          ),
        ),
      ),
    );
  }
}
