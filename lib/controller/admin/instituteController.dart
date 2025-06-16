import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:new_dental/Model/institute.dart';
import 'package:new_dental/services/api_services.dart';

class InstituteController extends GetxController {
  var isLoading = false.obs;
  var instituteList = <Institute>[].obs;
  var institutes = <String>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchInstitutes();
  }

  // void fetchInstitutes() async {
  //   isLoading(true);
  //   try {
  //     final response = await http.get(
  //       Uri.parse('${ApiService.baseUrl}/admin/get_institutes.php'),
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       print(data);
  //       if (data['status'] == 'success') {
  //         List<Institute> institutes = List<Institute>.from(
  //             data['data'].map((item) => Institute.fromJson(item)));
  //         instituteList.assignAll(institutes);
  //       }
  //     }
  //   } catch (e) {
  //     print(e);
  //     Get.snackbar('Error', 'Failed to load institutes: $e');
  //   } finally {
  //     isLoading(false);
  //   }
  // }

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

  void deleteInstitute(String name) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/admin/delete_institute.php'),
        body: {'id': name},
      );

      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        instituteList.removeWhere((inst) => inst.id == name);
        Get.snackbar('Success', 'Institute deleted');
      } else {
        Get.snackbar('Failed', data['message']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Delete failed: $e');
    }
  }

  void addInstitute(String name) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/admin/add_institute.php'),
        body: {'name': name},
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        fetchInstitutes();
        Get.snackbar('Success', 'Institute added');
      } else {
        Get.snackbar('Error', data['message']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Add failed: $e');
    }
  }
}
