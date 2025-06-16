import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/permission_service.dart';

class StudentDataUploadController extends GetxController with GetSingleTickerProviderStateMixin{
  // State variables
  late TabController tabController;
  var isLoading = false.obs;
  var loadingMessage = ''.obs;
  var csvData = <Map<String, dynamic>>[].obs;
  var institutes = <String>[].obs;
  var selectedInstitute = Rxn<String>();

  // Form controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ageController = TextEditingController();
  var selectedGender = Rxn<String>();
  var selectedBloodGroup = Rxn<String>();

  @override
  void onInit() async {
    super.onInit();
    fetchInstitutes();
    tabController = TabController(length: 2, vsync: this);
    await PermissionService.requestCsvFilePermission();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    ageController.dispose();
    tabController.dispose();
    super.onClose();
  }

  /// Fetch Institutes from API
  Future<void> fetchInstitutes() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/get_institutes.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          institutes.value = List<String>.from(data.map((item) => item['name']));
        } else {
          Get.snackbar("Alert", "No institutes found. Please add an institute first.",backgroundColor: Colors.blue);
        }
      } else {
        throw Exception('Failed to fetch institutes');
      }
    } catch (e) {
      print('Error fetching institutes: $e');
      Get.snackbar("Alert", 'Error fetching institutes: $e',backgroundColor: Colors.blue);
    } finally {
      isLoading(false);
    }
  }

  /// Upload CSV File
  Future<void> uploadCSVFile() async {
    if (selectedInstitute.value == null) {
      Get.snackbar("Alert", 'Please select an institute',backgroundColor: Colors.blue);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        isLoading(true);
        loadingMessage.value = 'Reading CSV file...';

        final file = File(result.files.single.path!);
        final input = file.openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();

        csvData.clear();
        List<String> invalidRows = [];

        // Check if CSV has headers (first row)
        if (fields.isEmpty) {
          throw Exception('CSV file is empty');
        }

        // Start from index 1 to skip headers
        for (var i = 1; i < fields.length; i++) {
          if (fields[i].length >= 6) {
            var row = fields[i];

            var studentData = {
              'full_name': row[0]?.toString().trim() ?? '',
              'email': row[1]?.toString().trim() ?? '',
              'mobile': row[2]?.toString().trim() ?? '',
              'age': row[3]?.toString().trim() ?? '',
              'gender': row[4]?.toString().trim() ?? '',
              'blood_group': row[5]?.toString().trim() ?? '',
              'institute': selectedInstitute.value,
            };

            bool isValid = true;
            studentData.forEach((key, value) {
              if (value!.isEmpty) {
                isValid = false;
                invalidRows.add('Row ${i + 1}: Empty $key');
              }
            });

            if (isValid) {
              csvData.add(studentData);
            }
          } else {
            invalidRows.add('Row ${i + 1}: Insufficient columns');
          }
        }

        if (csvData.isEmpty) {
          throw Exception(
              'No valid data found in CSV file.\nErrors:\n${invalidRows.join("\n")}');
        }

        // loadingMessage.value = 'Uploading student data...';
        // await uploadStudents();
      }
    } catch (e) {
      print('Error uploading CSV: $e');
      Get.snackbar("Alert", 'Error uploading CSV: $e',backgroundColor: Colors.blue);
    } finally {
      isLoading(false);
    }
  }

  /// Upload Students to API
  Future<void> uploadStudents() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/admin/upload_students.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'students': csvData}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Get.snackbar("Alert", 'Successfully added ${csvData.length} students',backgroundColor: Colors.blue);
        csvData.clear(); // Clear the data after successful upload
      } else {
        throw Exception(responseData['message'] ?? 'Failed to upload students');
      }
    } catch (e) {
      print('Error uploading students: $e');
      Get.snackbar("Alert", 'Error uploading students: $e',backgroundColor: Colors.blue);
    }
  }

  /// Add Institute to API
  Future<void> addInstitute(String name) async {
    try {
      isLoading(true);

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/admin/add_institute.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'institute_name': name}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        institutes.add(name);
        selectedInstitute.value = name;
        Get.snackbar("Alert", 'Institute added successfully');
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add institute');
      }
    } catch (e) {
      print('Error adding institute: $e');
      Get.snackbar("Alert", 'Error adding institute: $e',backgroundColor: Colors.blue);
    } finally {
      isLoading(false);
    }
  }

  /// Register a single student manually
  Future<void> registerSingleStudent() async {
    if (selectedGender.value == null ||
        selectedBloodGroup.value == null ||
        selectedInstitute.value == null) {
      Get.snackbar("Alert", 'Please select Gender, Blood Group, and Institute', backgroundColor: Colors.blue);
      return;
    }

    try {
      isLoading(true);
      loadingMessage.value = 'Registering student...';

      // Create student data object
      final studentData = {
        'full_name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'mobile': mobileController.text.trim(),
        'age': ageController.text.trim(),
        'gender': selectedGender.value!,
        'blood_group': selectedBloodGroup.value!,
        'institute': selectedInstitute.value!,
      };

      // Use the same upload endpoint with a single student
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/admin/upload_students.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'students': [studentData]}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        Get.snackbar("Alert", 'Student registered successfully');
        clearForm(); // Clear form after successful registration
      } else {
        throw Exception(responseData['message'] ?? 'Failed to register student');
      }
    } catch (e) {
      print('Error registering student: $e');
      Get.snackbar("Alert", 'Error registering student: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Clear the form fields
  void clearForm() {
    fullNameController.clear();
    emailController.clear();
    mobileController.clear();
    ageController.clear();
    selectedGender.value = null;
    selectedBloodGroup.value = null;
  }
  /// Reset all fields and state variables
void reset() {
  // Clear form fields
  fullNameController.clear();
  emailController.clear();
  mobileController.clear();
  ageController.clear();
  selectedGender.value = null;
  selectedBloodGroup.value = null;

  // Reset CSV data and institute selection
  csvData.clear();
  selectedInstitute.value = null;
}
}