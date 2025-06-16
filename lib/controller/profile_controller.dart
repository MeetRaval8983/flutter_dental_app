import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:new_dental/View/auth/welcome_screen.dart';
import 'package:new_dental/services/api_services.dart';
import 'dart:convert';

import 'package:new_dental/services/shared_prefs.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var isEditing = false.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userType = ''.obs;
  var instituteName = ''.obs;
  var registrationId = ''.obs;
  var clinicId = ''.obs;
  var profileImageUrl = ''.obs;
  var totalStudents = 0.obs;
  var completedTests = 0.obs;
  var remainingTests = 0.obs;
  var isDarkMode = false.obs;

   
  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    isLoading.value = true;
    try {
      final userData = await SharedPrefs.getUserData();
      userName.value = userData['full_name'] ?? '';
      userEmail.value = userData['email'] ?? '';
      userType.value = userData['user_type'] ?? '';
      registrationId.value = userData['reg_id'] ?? '';
      // clinicId.value = userData['clinic_id'].toString();


      // ignore: unrelated_type_equality_checks
      if(userType == "doctor"){
        final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/doctor/get_profile.php?doctor_id=${userData['user_id']}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          instituteName.value = data['data']['assigned_institute'] ?? 'No Institute Assigned';
          registrationId.value = data['data']['registration_id'] ?? '';
          profileImageUrl.value = data['data']['profile_image'] ?? '';
          totalStudents.value = data['data']['stats']['total_students'] ?? 0;
          completedTests.value = data['data']['stats']['completed_tests'] ?? 0;
          remainingTests.value = data['data']['stats']['remaining_tests'] ?? 0;
        }
      }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      Get.snackbar('Error', 'Failed to load user data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    
    isLoading.value = true;
    try {
      final userData = await SharedPrefs.getUserData();
      var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/doctor/update_profile_image.php'));
      request.fields['doctor_id'] = userData['user_id'];
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      
      if (jsonResponse['status'] == 'success') {
        profileImageUrl.value = jsonResponse['data']['image_url'];
        Get.snackbar('Success', 'Profile image updated');
      } else {
        throw Exception(jsonResponse['message']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image');
    } finally {
      isLoading.value = false;
    }
  }
    void toggleTheme(bool value) {
    isDarkMode.value = value;
    // SharedPrefs.setThemeMode(value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

 Future<void> logout() async {
  Get.defaultDialog(
    title: "Logout",
    middleText: "Are you sure you want to logout?",
    textConfirm: "Yes",
    textCancel: "No",
    confirmTextColor: Colors.white,
    buttonColor: Colors.blue,
    onConfirm: () async {
      await SharedPrefs.clearUserData();
      Get.offAll(() => const WelcomeScreen());
    },
  );
}

}
