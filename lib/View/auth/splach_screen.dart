import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/admin/admin_nav.dart';
import 'package:new_dental/View/auth/welcome_screen.dart';
import 'package:new_dental/View/clinic/clinic_nav.dart';
import 'package:new_dental/View/doctor/doctor_nav.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), checkUserRoleAndNavigate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CustomImageView(
            //   imagePath: ImageConstant.imgImage3,
            //   height: 180,
            // ),
            Image.asset(
              'assets/logo/new-removebg-preview.png',
              height: 180,
            ),
            const SizedBox(height: 20),
            const Text(
              'D E N T I P I C',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w600,
                color: cerulean,
              ),
            ),
            SizedBox(
              height: 20,
              width: 20,
              child: const CircularProgressIndicator(
                color: cerulean,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(color: cerulean),
            ),
          ],
        ),
      ),
    );
  }

  /// Check user role and navigate using GetX
  Future<void> checkUserRoleAndNavigate() async {
    try {
      final userData = await authController.getUserData(); // Fetch user data
      String userRole = userData['user_type']?.toLowerCase() ?? '';

      switch (userRole) {
        case 'doctor':
          Get.off(() => const DocotrNav()); // Navigate using GetX
          break;
        case 'admin':
          Get.off(() => const AdminNav());
          break;
        case 'clinic':
          Get.off(() => const ClinicNav());
          break;
        default:
          Get.off(() => const WelcomeScreen()); // Default to Login screen
          break;
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      Get.off(() => const WelcomeScreen()); // Show login screen as fallback
    }
  }
}
