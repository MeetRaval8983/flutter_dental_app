import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';
import 'package:new_dental/View/tests/test_2.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/shared_prefs.dart';

String? _compressBase64Image(String imagePath) {
  try {
    final imageFile = File(imagePath);
    if (!imageFile.existsSync()) return null;

    final imageBytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    final resized = img.copyResize(image, width: 750);
    final compressed = img.encodeJpg(resized, quality: 80);

    return base64Encode(compressed);
  } catch (e) {
    print("Isolate compression error: $e");
    return null;
  }
}

class TestOneController extends GetxController {
  Rx<String?> frontImagePath = Rx<String?>(null);
  Rx<String?> upperImagePath = Rx<String?>(null);
  Rx<String?> lowerImagePath = Rx<String?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  var userType = ''.obs;
  var clinicId = ''.obs;
  var clinicName = ''.obs;

@override
  void onInit() {
    super.onInit();
    lodeData();
  }
  void lodeData() async {
    final userData = await SharedPrefs.getUserData();
    clinicId.value = userData['clinic_id'].toString();
    clinicName.value = userData['clinic_name'] ?? '';
    userType.value = userData['user_type'] ?? '';
  }
  // Method to set image path for each image (front, upper, lower)
  void setImagePath(String label, String path) {
    switch (label) {
      case 'Front':
        frontImagePath.value = path;
        break;
      case 'Upper':
        upperImagePath.value = path;
        break;
      case 'Lower':
        lowerImagePath.value = path;
        break;
    }
    update();
  }

  Future<String?> compressImageInIsolate(String path) async {
    return await compute(_compressBase64Image, path);
  }

  // Method to upload images to the server
  Future<void> uploadImagesController(final Map<String, dynamic> studentInfo) async {
    if (frontImagePath.value == null ||
        upperImagePath.value == null ||
        lowerImagePath.value == null) {
      // await Future.delayed(Duration(milliseconds: 500));
      // Get.back();
      Get.snackbar('Missing Images', 'Please select all images',
          backgroundColor: purple);
      return;
    }
    Future.delayed(Duration.zero, () {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/lottie/loader.json',
                    height: 100, width: 100),
                SizedBox(height: 20),
                Text(
                  'Uploading images...',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false, // Prevent user from closing manually
      );
    });

    try {
      // Compress images before uploading
      String? compressedFront =
          await compressImageInIsolate(frontImagePath.value!);
      String? compressedUpper =
          await compressImageInIsolate(upperImagePath.value!);
      String? compressedLower =
          await compressImageInIsolate(lowerImagePath.value!);

      // Check if any image compression failed
      if (compressedFront == null ||
          compressedUpper == null ||
          compressedLower == null) {
        errorMessage.value = 'Image processing failed';
        return;
      }

      // Prepare base64 encoded images
      Map<String, String> images = {
        'front': compressedFront,
        'upper': compressedUpper,
        'lower': compressedLower,
      };
    
      // Call the API service to upload images
      var response = await ApiService.uploadImagesApi(studentInfo['id'].toString(),
          studentInfo['institute']??'', images, clinicId.value.toString(), userType.value, clinicName.value);
      print(response);
      if (response['status'] == 'success') {
        // Get.back();
        Get.snackbar('Success', 'Images uploaded successfully');
        Get.to(SelectDiseasesStep(studentInfo: studentInfo),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut);
      } else {
        // Get.back();
        errorMessage.value = response['message'] ?? 'Unknown error';
      }
    } catch (e) {
      Get.back();
      errorMessage.value = e.toString();
      print(e); 
    } 
  }
}
