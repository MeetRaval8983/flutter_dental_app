import 'package:get/get.dart';
import 'package:new_dental/services/api_services.dart';

class DoctorDetailController extends GetxController {
  final String doctorId;
  DoctorDetailController(this.doctorId);

  var doctorData = Rxn<Map<String, dynamic>>();
  var instituteStats = Rxn<Map<String, dynamic>>();
  var institutes = <String>[].obs;
  var selectedInstitute = RxnString();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctorDetails();
    fetchInstitutes();
  }

  Future<void> fetchDoctorDetails() async {
    isLoading.value = true;
    try {
      var response = await ApiService.getDoctorDetails(doctorId);
      if (response != null) {
        doctorData.value = response;
        if (response['assigned_institute'] != null &&
            response['assigned_institute'].toString().isNotEmpty) {
          fetchInstituteStats(response['assigned_institute']);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load doctor details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInstituteStats(String institute) async {
    try {
      var response = await ApiService.getInstituteStats(institute);
      if (response != null) {
        instituteStats.value = response;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load statistics: $e");
    }
  }

  Future<void> fetchInstitutes() async {
    try {
      var response = await ApiService.getInstitutes();
      if (response != null) {
        institutes.assignAll(response);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load institutes: $e");
    }
  }

  Future<void> assignInstitute() async {
    if (selectedInstitute.value == null) return;
    try {
      bool success = await ApiService.assignInstitute(
        doctorId, selectedInstitute.value!,
      );
      if (success) {
        fetchDoctorDetails();
        Get.snackbar("Success", "Institute assigned successfully");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to assign institute: $e");
    }
  }

  Future<void> removeAssignment() async {
    try {
      bool success = await ApiService.removeAssignment(doctorId);
      if (success) {
        fetchDoctorDetails();
        Get.snackbar("Success", "Assignment removed successfully");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to remove assignment: $e");
    }
  }
}
