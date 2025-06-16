import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/shared_prefs.dart';

class ClinicHomeController extends GetxController {
  var clinicName = ''.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var clinicId = ''.obs;
  var totalPatientsCount = 0.obs;
  var patients = <Map<String, dynamic>>[].obs;
  var filteredPatients = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isFirstLoad = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (isFirstLoad.value) {
      loadClinicData();
    }
  }

  Future<void> loadClinicData() async {
    if (!isFirstLoad.value) return;

    isLoading(true);
    try {
      final userData = await SharedPrefs.getUserData();
      userName.value = userData['full_name'] ?? '';
      userEmail.value = userData['email'] ?? '';
      clinicId.value = userData['clinic_id'].toString();
      clinicName.value = userData['clinic_name'] ?? '';
      final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/clinic/fetch_clinic_patients.php?clinic_id=${clinicId.value}'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        clinicName.value = data['data']['clinic_name'];
        totalPatientsCount.value =
            data['data']['total_patients']; // Removed int.parse
        // patients.value =
        //     List<Map<String, dynamic>>.from(data['data']['patients']);
        patients.value =
            List<Map<String, dynamic>>.from(data['data']['patients'])
              ..sort((a, b) => (a['is_test_completed'] == 0 ? 0 : 1)
                  .compareTo(b['is_test_completed'] == 0 ? 0 : 1));

        filteredPatients.value = patients;

        print('Patients: $patients');
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      print('Error loading clinic data: $e');
    } finally {
      isLoading(false);
      isFirstLoad(false);
    }
  }

  void onSearchChanged(String query) {
    filteredPatients.value = patients
        .where((patient) => patient['full_name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

  void reset() {
    isFirstLoad.value = true;
  }
}
