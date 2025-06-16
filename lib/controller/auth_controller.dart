import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/admin/admin_nav.dart';
import 'package:new_dental/View/clinic/clinic_nav.dart';
import 'package:new_dental/View/doctor/doctor_nav.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/shared_prefs.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var selectedRole = 'admin'.obs;
  var isPasswordVisible = false.obs;
  var fullNameController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var registrationIdController =
      TextEditingController(); // Only for doctor role
  var agreePersonalData = false.obs;
  var keyController = TextEditingController();
  var clinicController = TextEditingController();

  void institutelogin() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedRole.value.isEmpty) {
      Get.snackbar("Notice", "Please fill all fields and select a role.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      return;
    }

    isLoading.value = true;
    var response = await ApiService.login(
      emailController.text,
      passwordController.text,
      selectedRole.value,
    );
    print(response);

    isLoading.value = false;
    if (response["status"] == "success") {
      await SharedPrefs.saveUserData(response['data']);

      // final userdata = await SharedPrefs.getUserData();
      // print(userdata);
      if (selectedRole.value == 'admin') {
        Get.offAll(() => AdminNav(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 550));
      } else if (selectedRole.value == 'doctor') {
        Get.offAll(() => DocotrNav(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 550));
      }
      Get.snackbar("Success", response["message"],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
    } else {
      Get.snackbar("Alert", response["message"],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
    }
  }

  // Register function
  void instituteregister() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedRole.value.isEmpty ||
        keyController.text.isEmpty ||
        (selectedRole.value == 'doctor' &&
            registrationIdController.text.isEmpty) ||
        passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
          'Notice', 'Please fill all fields and ensure passwords match.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      return;
    }
    if (keyController.text.trim() != 'Dental@2025') {
      Get.snackbar('Invalid', 'Invalid key',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      return;
    }
    if (!agreePersonalData.value) {
      Get.snackbar(
          'Attention!', 'Please agree to the processing of personal data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      return;
    }
    isLoading.value = true;

    var response = await ApiService.register(
      fullNameController.text,
      emailController.text,
      passwordController.text,
      selectedRole.value,
      registrationIdController.text,
      clinicController.text, // Only for clinic role
    );
    isLoading.value = false;

    if (response["status"] == "success") {
      await SharedPrefs.saveUserData(response['data']);

      // final userdata = await SharedPrefs.getUserData();
      // print(userdata);
      if (selectedRole.value == 'admin') {
        Get.offAll(() => AdminNav(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 550));
      } else if (selectedRole.value == 'doctor') {
        Get.offAll(() => DocotrNav(),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 550));
      } 

      // Get.offAll(() => MainPage(), transition: Transition.rightToLeft, duration: Duration(milliseconds: 550));
      Get.snackbar('Success', response["message"],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      // Navigate to Home Screen or another action
    } else {
      print(response);
      Get.snackbar('Uh-oh!', response["message"],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      return await SharedPrefs.getUserData();
    } catch (e) {
      print("Error fetching user kjhlkjh data: $e");
      return {};
    }
  }

  void cliniclogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Notice", "Please fill all fields and select a role.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      return;
    }

    isLoading.value = true;
    var response = await ApiService.login(
      emailController.text,
      passwordController.text,
      "clinic",
    );
    print(response);

    isLoading.value = false;
    if (response["status"] == "success") {
      await SharedPrefs.saveUserData(response['data']);

      // final userdata = await SharedPrefs.getUserData();
      // print(userdata);

      Get.offAll(() => ClinicNav(),
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: 550));
    }
    // Get.offAll(() => MainPage());
    Get.snackbar("Success", response["message"],
        snackPosition: SnackPosition.BOTTOM, backgroundColor: brightTurquoise);
  }

  void clinicregister() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        keyController.text.isEmpty ||
        registrationIdController.text.isEmpty ||
        clinicController.text.isEmpty ||
        passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
          'Notice', 'Please fill all fields and ensure passwords match.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      return;
    }
    if (keyController.text.trim() != 'Dental@2025') {
      Get.snackbar('Invalid', 'Invalid key',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      return;
    }
    if (!agreePersonalData.value) {
      Get.snackbar(
          'Attention!', 'Please agree to the processing of personal data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      return;
    }
    isLoading.value = true;

    var response = await ApiService.register(
      fullNameController.text,
      emailController.text,
      passwordController.text,
      "clinic",
      registrationIdController.text,
      clinicController.text,
    );
    isLoading.value = false;

    if (response["status"] == "success") {
      await SharedPrefs.saveUserData(response['data']);

      // final userdata = await SharedPrefs.getUserData();
      // print(userdata);
      Get.offAll(() => ClinicNav(),
          transition: Transition.rightToLeft,
          duration: Duration(milliseconds: 550));

      // Get.offAll(() => MainPage(), transition: Transition.rightToLeft, duration: Duration(milliseconds: 550));
      Get.snackbar('Success', response["message"],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
      // Navigate to Home Screen or another action
    } else {
      print(response);
      Get.snackbar('Uh-oh!', response["message"],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: brightTurquoise);
    }
  }
}
