import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/auth/institute/signup_screen_institute.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/auth_controller.dart';
import 'package:new_dental/View/Widgets/custom_scaffold.dart';

class SignInScreenInstitute extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  SignInScreenInstitute({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Institution Sign In',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: cerulean,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // Email Input
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        controller: authController.emailController,
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Password Input
                      Obx(
                        () => TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: authController.passwordController,
                          obscureText: !authController.isPasswordVisible.value,
                          decoration: InputDecoration(
                            label: const Text('Password'),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(color: Colors.black26),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                authController.isPasswordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black26,
                              ),
                              onPressed: () {
                                authController.isPasswordVisible.value =
                                    !authController.isPasswordVisible
                                        .value; // Toggle visibility
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Role Selection Checkboxes
                      Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Role:",
                                  style:
                                      TextStyle(fontSize: 16.0, color: black)),
                              Radio<String>(
                                value: "admin",
                                groupValue: authController.selectedRole.value,
                                onChanged: (String? value) {
                                  authController.selectedRole.value = value!;
                                },
                              ),
                              Text("Admin",
                                  style:
                                      TextStyle(fontSize: 16.0, color: black)),
                              Radio<String>(
                                value: "doctor",
                                groupValue: authController.selectedRole.value,
                                onChanged: (String? value) {
                                  authController.selectedRole.value = value!;
                                },
                              ),
                              Text("Doctor",
                                  style:
                                      TextStyle(fontSize: 16.0, color: black)),
                            ],
                          )),
                      const SizedBox(height: 15.0),

                      // Remember Me Checkbox
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Implement forgot password
                            },
                            child: Text(
                              'Forget password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: purple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // Sign In Button
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    cerulean,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 0.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: authController.isLoading.value
                                  ? null
                                  : authController.institutelogin,
                              child: authController.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Sign In',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded,
                                            size: 20, color: Colors.white),
                                      ],
                                    ),
                            ),
                          )),
                      const SizedBox(height: 25.0),

                      // Don't Have an Account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(SignUpScreen(),
                                  transition: Transition.downToUp,
                                  duration: Duration(milliseconds: 550));
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: purple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
