import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:movie_app/Watch%20Screen/watchScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WatchScreen(),
    );
  }
}
