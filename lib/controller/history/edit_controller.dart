import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:new_dental/services/api_services.dart';

class EditStudentController extends GetxController {
  final Map<String, dynamic> studentData;
  final Map<String, dynamic>? selectedStudentData;

  // Controllers
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController bloodGroupController;
  late TextEditingController treatmentPlanController;

  // Observables
  final RxString frontImagePath = RxString('');
  final RxString upperImagePath = RxString('');
  final RxString lowerImagePath = RxString('');
  final Rx<String?> gender = Rx<String?>(null);
  final RxMap<String, dynamic> teethData = RxMap<String, dynamic>();
  final RxBool isLoading = RxBool(false);

  EditStudentController({
    required this.studentData, 
    this.selectedStudentData
  });

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    nameController = TextEditingController(text: studentData['full_name']);
    ageController = TextEditingController(text: studentData['age'].toString());
    bloodGroupController = TextEditingController(text: studentData['blood_group']);
    
    // Initialize treatment plan
    treatmentPlanController = TextEditingController(
      text: selectedStudentData?['treatmentPlan']?['treatment_description'] ?? ''
    );

    // Set initial gender
    gender.value = studentData['gender'];

    // Initialize dental images
    if (selectedStudentData != null && 
        selectedStudentData!['dentalImages'] != null) {
      frontImagePath.value = 
          selectedStudentData!['dentalImages']['front_image_path'] ?? '';
      upperImagePath.value = 
          selectedStudentData!['dentalImages']['upper_image_path'] ?? '';
      lowerImagePath.value = 
          selectedStudentData!['dentalImages']['lower_image_path'] ?? '';
    }

    // Initialize teeth data
    if (selectedStudentData != null && 
        selectedStudentData!['teethImages'] != null) {
      teethData.value = {
        for (var tooth in selectedStudentData!['teethImages'])
          tooth['tooth_number'].toString(): tooth
      };
    }
  }

  Future<String?> _compressImage(String imagePath) async {
    if (imagePath.isEmpty || !imagePath.startsWith('/')) {
      return null;
    }
    
    try {
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

      if (image == null) return null;

      final compressedImage = img.encodeJpg(image, quality: 85);
      return base64Encode(Uint8List.fromList(compressedImage));
    } catch (e) {
      print("Image compression error: $e");
      return null;
    }
  }

  Future<void> pickImage(String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    switch (type) {
      case 'front':
        frontImagePath.value = image.path;
        break;
      case 'upper':
        upperImagePath.value = image.path;
        break;
      case 'lower':
        lowerImagePath.value = image.path;
        break;
    }
  }

  Future<void> saveChanges() async {
    isLoading.value = true;

    try {
      // Prepare base64 images
      Map<String, dynamic> images = {};

      if (frontImagePath.value.startsWith('/')) {
        String? frontImageBase64 = await _compressImage(frontImagePath.value);
        if (frontImageBase64 != null) {
          images["front"] = frontImageBase64;
        }
      }
      
      if (upperImagePath.value.startsWith('/')) {
        String? upperImageBase64 = await _compressImage(upperImagePath.value);
        if (upperImageBase64 != null) {
          images["upper"] = upperImageBase64;
        }
      }
      
      if (lowerImagePath.value.startsWith('/')) {
        String? lowerImageBase64 = await _compressImage(lowerImagePath.value);
        if (lowerImageBase64 != null) {
          images["lower"] = lowerImageBase64;
        }
      }

      // Process teeth data
      List<Map<String, dynamic>> processedTeethData = [];
      for (var entry in teethData.entries) {
        final tooth = entry.value;
        String? base64Image;
        
        if (tooth['imagePath'] != null && 
            tooth['imagePath'].toString().startsWith('/')) {
          base64Image = await _compressImage(tooth['imagePath']);
        }

        processedTeethData.add({
          'toothNumber': entry.key,
          'disease': tooth['disease_name'] ?? tooth['disease'] ?? "",
          'imageBase64': base64Image,
        });
      }

      // Prepare request body
      final url = Uri.parse("${ApiService.baseUrl}/tests/update_test_data.php");

      Map<String, dynamic> requestData = {
        "student_id": studentData['id'],
        "college_name": studentData['institute'],
        "treatment_plan": treatmentPlanController.text,
        "teeth_data": processedTeethData,
        "student_info": {
          "full_name": nameController.text,
          "age": int.tryParse(ageController.text) ?? 0,
          "blood_group": bloodGroupController.text,
          "gender": gender.value,
        }
      };

      // Only include images if there are new/updated ones
      if (images.isNotEmpty) {
        requestData["images"] = images;
      }

      // Send the update request
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          Get.snackbar(
            'Success', 
            'Data updated successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.back(result: true); // Return success to previous screen
        } else {
          throw Exception(responseBody['message'] ?? "Update failed");
        }
      } else {
        throw Exception("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to update data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addNewTooth(String newToothId) {
    if (newToothId.isNotEmpty) {
      teethData[newToothId] = {
        'disease': '',
        'disease_name': '',
        'imagePath': null,
        'tooth_image_path': null,
      };
    }
  }

  void deleteTooth(String toothId) {
    teethData.remove(toothId);
  }

  void updateToothDisease(String toothId, String value) {
    if (teethData.containsKey(toothId)) {
      teethData[toothId]['disease_name'] = value;
    }
  }

  void pickToothImage(String toothId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    if (!teethData.containsKey(toothId)) {
      teethData[toothId] = {};
    }
    teethData[toothId]['imagePath'] = image.path;
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    bloodGroupController.dispose();
    treatmentPlanController.dispose();
    super.onClose();
  }
}