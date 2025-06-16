import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/shared_prefs.dart';

class AdminHomeController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;
  var allInstitutes = <Map<String, dynamic>>[].obs;
  var filteredStudents = <Map<String, dynamic>>[].obs;
  var selectedInstitute = ''.obs;
  var isLoading = false.obs;
  var totalStudentsCount = '0'.obs;
  var completedStudentsCount = '0'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchInstitutesData();
    fetchStudentCounts();
  }

  Future<void> loadUserData() async {
    try {
      final userData = await SharedPrefs.getUserData();
      userName.value = userData['full_name'] ?? '';
      userEmail.value = userData['email'] ?? '';
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> fetchInstitutesData() async {
  isLoading.value = true;
  try {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/admin/get_institutes.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print(data );
      if (response.statusCode == 200) {
        allInstitutes.assignAll(List<Map<String, dynamic>>.from(data));
        if (allInstitutes.isNotEmpty) {
          selectedInstitute.value = allInstitutes.first['name'];
          fetchStudentsForInstitute(selectedInstitute.value); // ✅ Correct call
        }
      }
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to load institutes: $e');
  } finally {
    isLoading.value = false;
  }
}


   /// **Fetch students for a selected institute**
  Future<void> fetchStudentsForInstitute(String instituteName) async {
    selectedInstitute.value = instituteName;

    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse('${ApiService.baseUrl}/admin/get_students_by_institute.php?institute=$instituteName'));
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          filteredStudents.assignAll(List<Map<String, dynamic>>.from(data['data']));
          // print(filteredStudents);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading students: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void fetchStudentCounts() async {
    try {
      isLoading.value = true;
      final data = await ApiService.fetchTotalStudentCounts();
      totalStudentsCount.value = data['total_students']!;
      completedStudentsCount.value = data['test_completed_students']!;
    } catch (e) {
      print('Error fetching student counts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // void filterStudentsByInstitute(String instituteName) {
  //   selectedInstitute.value = instituteName;
  //   filteredStudents.assignAll(
  //     allInstitutes.where((student) => student['name'] == instituteName).toList(),
  //   );
  // }
}
