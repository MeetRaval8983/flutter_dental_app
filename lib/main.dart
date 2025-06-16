import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/auth/splach_screen.dart';
import 'package:new_dental/controller/auth_controller.dart';

void main() {
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dentipic',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        colorScheme: ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Colors.black),
          headlineMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
          elevation: 0,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
