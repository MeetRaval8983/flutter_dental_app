import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/shared_prefs.dart';

class DoctorHomeController extends GetxController {
  var userName = ''.obs;
  var userEmail = ''.obs;
  var instituteName = ''.obs;
  var totalStudentsCount = 0.obs;
  var completedStudentsCount = 0.obs;
  var students = <Map<String, dynamic>>[].obs;
  var filteredStudents = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isFirstLoad = true.obs; // Flag to check first-time loading

  @override
  void onInit() {
    super.onInit();
    if (isFirstLoad.value) {
      loadUserData();
    }
  }

  Future<void> loadUserData() async {
    if (!isFirstLoad.value) return; // If it's not first-time, don't fetch again

    isLoading(true);
    try {
      final userData = await SharedPrefs.getUserData();
      userName.value = userData['full_name'] ?? '';
      userEmail.value = userData['email'] ?? '';

      final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/doctor/get_students.php?doctor_id=${userData['user_id']}'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        instituteName.value = data['data']['institute_name'];
        totalStudentsCount.value = data['data']['total_students'];
        completedStudentsCount.value = data['data']['completed_students'];
        students.value =
            List<Map<String, dynamic>>.from(data['data']['students']);
        filteredStudents.value = students;
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      print('Error loading user data in home screen: $e');
    } finally {
      isLoading(false);
      isFirstLoad(false); // After first load, set flag to false
    }
  }

  void onSearchChanged(String query) {
    filteredStudents.value = students
        .where((student) => student['full_name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

  void reset() {
    isFirstLoad.value = true;
  }
}
