import 'package:flutter/material.dart';
import 'package:new_dental/View/Widgets/custom_scaffold.dart';
import 'package:new_dental/View/Widgets/welcome_button.dart';
import 'package:new_dental/View/auth/clinic/signin_screen_clinic.dart';
import 'package:new_dental/View/auth/institute/signin_screen_institute.dart';
import 'package:new_dental/const.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 40.0,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Image.asset(ImageConstant.logoBgRemoved, // Replace with your actual logo path
                        width: 250,
                        height: 250,
                      ),
                      const Text(
                        'D E N T I P I C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Clinic',
                      onTap: SigninScreenClinic(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                      icon: Icons.local_hospital, // Example icon for clinic
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Institution',
                      onTap:  SignInScreenInstitute(),
                      color: Colors.white,
                      textColor: cerulean,
                      icon: Icons.school, // Example icon for institute
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}