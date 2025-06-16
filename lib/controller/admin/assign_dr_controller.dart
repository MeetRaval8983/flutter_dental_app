import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_dental/Model/doctor.dart';
import 'dart:convert';
import 'package:new_dental/services/api_services.dart';

class DoctorController extends GetxController {
  var isLoading = false.obs;
  var allDoctors = <Doctor>[].obs;
  var filteredDoctors = <Doctor>[].obs;
  var sortOption = 'Assigned'.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
    debounce(searchQuery, (_) => filterDoctors(), time: const Duration(milliseconds: 300));
  }

  void fetchDoctors() async {
    isLoading(true);
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/get_doctors.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Convert API response to List<Doctor>
          List<Doctor> doctorList = List<Doctor>.from(
            data['data'].map((item) => Doctor.fromJson(item)),
          );

          allDoctors.assignAll(doctorList);
          filterDoctors();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load doctors: $e');
    } finally {
      isLoading(false);
    }
  }

  void filterDoctors() {
    filteredDoctors.assignAll(
      allDoctors.where((doc) {
        return doc.fullName.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList(),
    );
  }

  void changeSortOption(String newOption) {
    sortOption.value = newOption;
    filteredDoctors.sort((a, b) {
      if (newOption == 'Assigned') {
        return a.status == 'AS' ? -1 : 1;
      } else {
        return a.status == 'AV' ? -1 : 1;
      }
    });
  }
}
