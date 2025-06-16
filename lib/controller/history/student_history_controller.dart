// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:new_dental/Model/student.dart';
// import 'dart:convert';

// import 'package:new_dental/services/api_services.dart';
// import 'package:new_dental/services/file_handle_api.dart';
// import 'package:new_dental/services/pdf_service_net.dart';
// class StudentHistoryController extends GetxController {
//   final isLoading = false.obs;
//   final isFetchingDetails = false.obs;
//   final selectedStudentData = Rxn<Map<String, dynamic>>();

//   Future<Map<String, dynamic>> fetchStudentDetails(String studentId) async {
//     try {
//       isFetchingDetails.value = true;

//       // Fetch dental images
//       final dentalImagesResponse = await http.get(
//         Uri.parse('${ApiService.baseUrl}/doctor/get_dental_images.php?student_id=$studentId'),
//         headers: {'Content-Type': 'application/json'},
//       );
//       final dentalImages = json.decode(dentalImagesResponse.body);

//       // Fetch teeth images
//       final teethImagesResponse = await http.get(
//         Uri.parse('${ApiService.baseUrl}/doctor/get_teeth_images.php?student_id=$studentId'),
//         headers: {'Content-Type': 'application/json'},
//       );
//       final teethImages = json.decode(teethImagesResponse.body);

//       // Fetch treatment plan
//       final treatmentPlanResponse = await http.get(
//         Uri.parse('${ApiService.baseUrl}/doctor/get_treatment_plan.php?student_id=$studentId'),
//         headers: {'Content-Type': 'application/json'},
//       );
//       final treatmentPlan = json.decode(treatmentPlanResponse.body);

//       selectedStudentData.value = {
//         'dentalImages': dentalImages['data'],
//         'teethImages': teethImages['data'],
//         'treatmentPlan': treatmentPlan['data'],
//       };

//       isFetchingDetails.value = false;
//       return selectedStudentData.value!;
//     } catch (e) {
//       isFetchingDetails.value = false;
//       Get.snackbar('Error', 'Failed to fetch student details: $e',
//           backgroundColor: Colors.red, colorText: Colors.white);
//       rethrow;
//     }
//   }

//   Future<void> generatePDF(StudentModel studentData) async {
//     try {
//       Get.dialog(
//         Center(
//           child: Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 Text('Generating PDF...'),
//               ],
//             ),
//           ),
//         ),
//         barrierDismissible: false,
//       );

//       // Prepare teeth images map
//       final teethImagesMap = <String, dynamic>{};
//       if (selectedStudentData.value?['teethImages'] != null) {
//         for (var tooth in selectedStudentData.value!['teethImages']) {
//           teethImagesMap[tooth['tooth_number'].toString()] = {
//             'disease_name': tooth['disease_name'],
//             'tooth_image_path': tooth['tooth_image_path'],
//           };
//         }
//       }

//       final pdfApi = PdfApi();
//       final pdfFile = await pdfApi.generate(
//         studentData.toJson(),
//         selectedStudentData.value?['dentalImages']?['front_image_path'] ?? '',
//         selectedStudentData.value?['dentalImages']?['upper_image_path'] ?? '',
//         selectedStudentData.value?['dentalImages']?['lower_image_path'] ?? '',
//         teethImagesMap
//       );

//       // Close the loading dialog
//       Get.back();

//       // Open the PDF
//       await FileHandleApi.openFile(pdfFile);

//       Get.snackbar('Success', 'PDF generated successfully!',
//           backgroundColor: Colors.green, colorText: Colors.white);
//     } catch (e) {
//       // Close the loading dialog if it's open
//       if (Get.isDialogOpen ?? false) Get.back();

//       Get.snackbar('Error', 'Failed to generate PDF: $e',
//           backgroundColor: Colors.red, colorText: Colors.white);
//     }
//   }
// }