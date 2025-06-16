import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/Widgets/custom_scaffold.dart';
import 'package:new_dental/View/auth/clinic/signin_screen_clinic.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/auth_controller.dart';

class SignupScreenClinic extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final _formSignupKey = GlobalKey<FormState>();

  SignupScreenClinic({super.key});
  
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 2,
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
              child: Form(
                key: _formSignupKey,
                child: Column(
                  children: [
                    // Scrollable fields
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Register Clinic',
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: cerulean,
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            // Full Name
                            TextFormField(
                              style: const TextStyle(color: Colors.black),
                              validator: (value) =>
                                  (value?.isEmpty ?? true) ? 'Please enter Full Name' : null,
                              controller: authController.fullNameController,
                              decoration: InputDecoration(
                                label: const Text('Full Name'),
                                hintText: 'Enter Full Name',
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            // Email
                            TextFormField(
                              style: const TextStyle(color: Colors.black),
                              controller: authController.emailController,
                              validator: (value) =>
                                  (value?.isEmpty ?? true) ? 'Please enter Email' : null,
                              decoration: InputDecoration(
                                label: const Text('Email'),
                                hintText: 'Enter Email',
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            // Password
                            Obx(() => TextFormField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: authController.passwordController,
                                  obscureText: !authController.isPasswordVisible.value,
                                  validator: (value) =>
                                      (value?.isEmpty ?? true) ? 'Please enter Password' : null,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(authController.isPasswordVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        authController.isPasswordVisible.value =
                                            !authController.isPasswordVisible.value;
                                      },
                                    ),
                                    label: const Text('Password'),
                                    hintText: 'Enter Password',
                                    hintStyle: const TextStyle(color: Colors.black26),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 25.0),
                            // Confirm Password
                            Obx(() => TextFormField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: authController.confirmPasswordController,
                                  obscureText: !authController.isPasswordVisible.value,
                                  validator: (value) => (value?.isEmpty ?? true)
                                      ? 'Please confirm your password'
                                      : null,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(authController.isPasswordVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        authController.isPasswordVisible.value =
                                            !authController.isPasswordVisible.value;
                                      },
                                    ),
                                    label: const Text('Confirm Password'),
                                    hintText: 'Enter Password',
                                    hintStyle: const TextStyle(color: Colors.black26),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 25.0),
                            // Key
                            TextFormField(
                              style: const TextStyle(color: Colors.black),
                              controller: authController.keyController,
                              validator: (value) =>
                                  (value?.isEmpty ?? true) ? 'Please enter Key' : null,
                              decoration: InputDecoration(
                                label: const Text('Key'),
                                hintText: 'Enter Key',
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            // Registration Number
                            TextFormField(
                              style: const TextStyle(color: Colors.black),
                              controller: authController.registrationIdController,
                              validator: (value) => (value?.isEmpty ?? true)
                                  ? 'Please enter Registration Number'
                                  : null,
                              decoration: InputDecoration(
                                label: const Text('Registration Number'),
                                hintText: 'Enter Registration Number',
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            // Clinic Name
                            TextFormField(
                              style: const TextStyle(color: Colors.black),
                              controller: authController.clinicController,
                              validator: (value) =>
                                  (value?.isEmpty ?? true) ? 'Please enter Clinic Name' : null,
                              decoration: InputDecoration(
                                label: const Text('Clinic Name'),
                                hintText: 'Clinic Name',
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Agree checkbox
                            Row(
                              children: [
                                Obx(() {
                                  return Checkbox(
                                    value: authController.agreePersonalData.value,
                                    onChanged: (value) {
                                      authController.agreePersonalData.value = value!;
                                    },
                                  );
                                }),
                                const Expanded(
                                  child: Text(
                                    'I agree to the processing of Personal data',
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 50), // spacing so last field isn't hidden by button
                          ],
                        ),
                      ),
                    ),
                    // Static Register button below scroll area
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cerulean,
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: authController.isLoading.value
                                ? null
                                : authController.clinicregister,
                            child: authController.isLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Register',
                                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                                    ],
                                  ),
                          ),
                        )),
                    const SizedBox(height: 20),
                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.black45),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(SigninScreenClinic(),
                                transition: Transition.downToUp,
                                duration: const Duration(milliseconds: 550));
                          },
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cerulean,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
