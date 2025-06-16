import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_dental/services/api_services.dart';

class ClinicPatientRegisterController extends GetxController {
  // Form controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ageController = TextEditingController();
  var selectedGender = Rxn<String>();
  var selectedBloodGroup = Rxn<String>();
  var isLoading = false.obs;

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    ageController.dispose();
    super.onClose();
  }

  Future<void> registerClinicPatient(String clinicId) async {
    // Validate only mandatory fields
    if (fullNameController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        selectedGender.value == null) {
      Get.snackbar("Missing Details", "Please fill in Full Name, Mobile, and select Gender.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);

      final patientData = {
        'clinic_id': clinicId,
        'full_name': fullNameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'gender': selectedGender.value,
        // Optional fields (included only if not empty)
        if (emailController.text.trim().isNotEmpty)
          'email': emailController.text.trim(),
        if (ageController.text.trim().isNotEmpty)
          'age': ageController.text.trim(),
        if (selectedBloodGroup.value != null)
          'blood_group': selectedBloodGroup.value
      };

      print("Sending: $patientData");

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/clinic/upload_clinic_patient.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(patientData),
      );

      final data = json.decode(response.body);
      print("Response: $data");

      if (response.statusCode == 200 && data['status'] == 'success') {
        Get.snackbar("Success", 'Patient registered successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        clearForm();
      } else {
        Get.snackbar("Failed", data['message'] ?? 'Something went wrong.',
            backgroundColor: Colors.orange, colorText: Colors.black);
      }
    } catch (e) {
      Get.snackbar("Error", 'Failed to register patient: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    fullNameController.clear();
    emailController.clear();
    mobileController.clear();
    ageController.clear();
    selectedGender.value = null;
    selectedBloodGroup.value = null;
  }
}
