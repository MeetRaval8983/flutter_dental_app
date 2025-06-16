import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';
import 'package:new_dental/View/clinic/clinic_nav.dart';
import 'package:new_dental/View/doctor/doctor_nav.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/clinic/clinic_home_controlle.dart';
import 'package:new_dental/controller/doctor_home_controller.dart';
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/file_handle_api.dart';
import 'package:new_dental/services/pdf_service_dr.dart';
import 'package:new_dental/services/shared_prefs.dart';
import 'test_1_controller.dart';
import 'test_2_controller.dart';
import 'test_3_controller.dart';

class ReportController extends GetxController {
  var isLoading = false.obs;
  var mailReport = false.obs;
  var statusMessage = ''.obs;
  var userType = ''.obs;
  var clinicId = ''.obs;
  var clinicName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() async {
    final userData = await SharedPrefs.getUserData();
    clinicId.value = userData['clinic_id'].toString();
    clinicName.value = userData['clinic_name'] ?? '';
    userType.value = userData['user_type'] ?? '';
    if (kDebugMode) {
      print('User Type: ${userType.value}');print('Clinic ID: ${clinicId.value}');
    print('Clinic Name: ${clinicName.value}');
    }
    
  }

  // Toggle the mail report option
  void sendByMAil(bool mail) {
    mailReport.value = mail;
    if (kDebugMode) {
      print(mailReport.value);
    }
    update();
  }

  // Compress image and convert to base64
  Future<String?> compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(Uint8List.fromList(imageBytes));

      if (image == null) return null;

      final compressedImage = img.encodeJpg(image, quality: 85);
      return base64Encode(Uint8List.fromList(compressedImage));
    } catch (e) {
      if (kDebugMode) {
        print("Image compression error: $e");
      }
      return null;
    }
  }

  Future<void> submitReport(
    Map<String, dynamic> studentInfo,
    Map<String, dynamic> teethData,
    String? frontImagePath,
    String? upperImagePath,
    String? lowerImagePath,
  ) async {
    Get.dialog(
      Dialog(
        backgroundColor: cerulean,
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
                'Saving data...',
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

    try {
      final treatmentPlanList = <Map<String, dynamic>>[];

      teethData.forEach((toothNumberStr, values) {
        if (values['treatmentPlan'] != null &&
            values['treatmentPlan'].toString().trim().isNotEmpty) {
          treatmentPlanList.add({
            "toothNumber": int.parse(toothNumberStr),
            "treatmentPlan": values['treatmentPlan'],
          });
        }
      });

// Check if treatmentPlanList is not empty before proceeding
      if (treatmentPlanList.isEmpty) {
        Get.snackbar("Error", "No treatment plans to upload.",
            backgroundColor: cerulean);
        return;
      }

      // // Organize request data
      // final Map<String, dynamic> requestData = {
      //   "student_id": studentInfo['id'],
      //   "treatmentData": treatmentPlanList,
      // };
      // print(requestData);
      // // Start upload process
      // final uploadResponse = await ApiService.uploadTreatmentPlan(requestData);
// Prepare final request body based on user type
      final Map<String, dynamic> requestData = {
        "user_type": userType.value,
        "treatmentData": treatmentPlanList,
      };

      if (userType.toString() == "clinic") {
        requestData["clinic_id"] = clinicId.toString();
        requestData["patient_id"] = studentInfo["id"].toString();
      } else {
        requestData["student_id"] = studentInfo["id"].toString();
      }

      final response = await ApiService.uploadTreatmentPlan(requestData);
      if (response['status'] == 'success') {
        Get.back(); // Close the loading dialog before PDF generation

        // Proceed to generate the PDF
        await _generateAndSharePdf(studentInfo, frontImagePath, upperImagePath,
            lowerImagePath, teethData);

        statusMessage.value = "Data uploaded and PDF generated successfully!";
        Get.snackbar("Success", "Data uploaded and PDF generated successfully!",
            backgroundColor: cerulean);
      } else {
        throw Exception(response['message'] ?? "Data upload failed.");
      }
    } catch (e) {
      statusMessage.value = "Failed to upload data: $e";
      Get.snackbar("Error", "Failed to upload data: $e",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: cerulean);
    } finally {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Ensure the dialog is closed
      }
    }
  }

  Future<void> _generateAndSharePdf(
      Map<String, dynamic> studentInfo,
      String? frontImagePath,
      String? upperImagePath,
      String? lowerImagePath,
      Map<String, dynamic> teethData) async {
    try {
      PdfApiDr pdf = PdfApiDr();
      final pdfFile = await pdf.generate(studentInfo, frontImagePath,
          upperImagePath, lowerImagePath, teethData);
      await FileHandleApi.openFile(pdfFile);

      if (mailReport.value) {
        sendPdfByEmail(pdfFile, studentInfo['email']);
      }

      Get.snackbar("Success", 'Pdf Generatde Successfully..',
          backgroundColor: cerulean);
      // Navigate to the main screen after successful PDF generation
      Future.delayed(Duration(seconds: 2), () {
        Get.delete<TestOneController>();
        Get.delete<TestTwoController>();
        Get.delete<TreatmentPlanController>();
        Get.delete<ReportController>();
        if (userType.value == 'clinic') {
          final homeController = Get.find<ClinicHomeController>();
          homeController.reset();
          homeController.loadClinicData();
          Get.offAll(() => ClinicNav(),
              transition: Transition.rightToLeft,
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut);
        } else {
          final homeController = Get.find<DoctorHomeController>();
          homeController.reset();
          homeController.loadUserData();
          Get.offAll(() => DocotrNav(),
              transition: Transition.rightToLeft,
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      Get.snackbar("error", 'Failed to generate PDF: $e',
          backgroundColor: cerulean);
    }
  }

  Future<void> sendPdfByEmail(File pdfFile, String email) async {
    try {
      final url = Uri.parse("${ApiService.baseUrl}/tests/mail_report.php");
      final request = http.MultipartRequest("POST", url);
      request.fields["email"] = email;
      request.files.add(await http.MultipartFile.fromPath("pdf", pdfFile.path));
      print(request);

      final response = await request.send();
      final responseStream = await response.stream.bytesToString();
      print('Status code: ${response.statusCode}');
      print('Response body: $responseStream');

      if (response.statusCode != 200) {
        print(response);
        throw Exception("Failed to send email");
        
      }
    } catch (e) {
        Get.snackbar(
        'error',
        e.toString(),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
     print(e);
      // Handle email error
    }
  }
}
