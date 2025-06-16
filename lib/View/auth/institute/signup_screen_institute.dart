import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/Widgets/custom_scaffold.dart';
import 'package:new_dental/View/auth/institute/signin_screen_institute.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/auth_controller.dart';
// ignore: must_be_immutable
class SignUpScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = false;

  SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
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
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: cerulean,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      // full name
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter Full Name'
                            : null,
                        controller: authController.fullNameController,
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // email
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        controller: authController.emailController,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter Email'
                            : null,
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // password
                      Obx(
                        () => TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: authController.passwordController,
                          obscureText: !authController.isPasswordVisible.value,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please enter Password'
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
                            label: const Text('Password'),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Obx(
                        () => TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: authController.confirmPasswordController,
                          obscureText: !authController.isPasswordVisible.value,
                          validator: (value) => value?.isEmpty ?? true
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
                            label: const Text('Password'),
                            hintText: 'Enter Password',
                            hintStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black12, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        controller: authController.keyController,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Please enter Key' : null,
                        decoration: InputDecoration(
                          label: const Text('Key'),
                          hintText: 'Enter Key',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          style: const TextStyle(color: Colors.black),

                          value: authController.selectedRole.value.isNotEmpty
                              ? authController.selectedRole.value
                              : null, // Set null initially
                          items: ['admin', 'doctor'].map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role
                                  .capitalizeFirst!), // Capitalize first letter
                            );
                          }).toList(),
                          onChanged: (value) {
                            authController.selectedRole.value = value!;
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Role',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                          ),
                          validator: (value) =>
                              value == null ? 'Please select a role' : null,
                        );
                      }),
                       const SizedBox(
                              height: 25.0,
                            ),
                      Obx(() {
                        return Column(
                          children: [
                           
                            authController.selectedRole.value == 'doctor'
                                ? TextFormField(
                                    style: const TextStyle(color: Colors.black),
                                    controller:
                                        authController.registrationIdController,
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Please enter Registration Number'
                                        : null,
                                    decoration: InputDecoration(
                                      label: const Text('Registration Number'),
                                      hintText: 'Enter Registration Number',
                                      hintStyle: const TextStyle(
                                        color: Colors.black26,
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors
                                              .black12, // Default border color
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 0,
                                  ),
                          ],
                        );
                      }),
                      // i agree to the processing
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
                          const Text(
                            'I agree to the processing of Personal data',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
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
                                  : authController.instituteregister,
                              child: authController.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Register',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded,size: 20,
                                            color: Colors.white),
                                      ],
                                    ),
                            ),
                          )),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(SignInScreenInstitute(),
                                  transition: Transition.downToUp,
                                  duration: Duration(milliseconds: 550));
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
                      const SizedBox(
                        height: 20.0,
                      ),
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
