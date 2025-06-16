import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://app.dentipic.tech/api';

  static Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password, "role": role}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
    String userType,
    String registrationId,
    String clinicName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register.php"),
        body: json.encode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'user_type': userType,
          'reg_id': registrationId,
          'clinic_name': clinicName,
        }),
      );
      return jsonDecode(response.body);

      // if (response.statusCode == 200) {
      //   return json.decode(response.body);
      // } else {
      //   return {'status': 'error', 'message': 'Failed to register'};
      // }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadImagesApi(
    String studentId,
    String collegeName,
    Map<String, String> images, // Map of base64-encoded images
    String clinicId,
    String userType, // 'clinic' or 'student'
    String clinicName,
  ) async {
    print("in upload imagse");
    final String url = '$baseUrl/tests/upload_images.php';
    print("Uploading images for $userType");

    try {
      // Construct the base request body
      final Map<String, dynamic> requestBody = {
        'user_type': userType,
        'images': images,
      };

      if (userType.toLowerCase() == 'clinic') {
        requestBody['clinic_id'] = clinicId;
        requestBody['clinic_name'] = clinicName;
        requestBody['patient_id'] =
            studentId; // In clinic context, studentId is patientId
      } else {
        requestBody['college_name'] = collegeName;
        requestBody['student_id'] = studentId;
      }
      print(jsonEncode(requestBody)); // ADD THIS TO DEBUG
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print(e);
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> uploadTeethData(
    String clinicId,
    String contextName, // clinic_name or college_name
    String userType,
    String studentId,
    Map<String, dynamic> teethData,
  ) async {
    final url = Uri.parse('$baseUrl/tests/upload_tooth_data.php');

    List<Map<String, dynamic>> formattedTeethData = [];

    teethData.forEach((toothNumber, data) {
      final base64 = data["imageBase64"];
      final disease = data["disease"];
      final toothId = data["toothNumber"];

      if (base64 == null || disease == null || toothId == null) return;

      formattedTeethData.add({
        "toothNumber": toothId,
        "disease": disease,
        "imageBase64": base64,
      });
    });

    final Map<String, dynamic> payload = {
      "user_type": userType,
      "teethData": formattedTeethData,
    };

    if (userType.toLowerCase() == 'clinic') {
      payload["patient_id"] = studentId;
      payload["clinic_name"] = contextName;
      payload["clinic_id"] = clinicId;
    } else {
      payload["student_id"] = studentId;
      payload["college_name"] = contextName;
    }

    print("Sending payload: ${jsonEncode(payload)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Upload failed: ${response.body}");
      return {'status': 'error', 'message': 'Failed to upload teeth data'};
    }
  }

  static Future<Map<String, dynamic>> uploadTreatmentPlan(
      Map<String, dynamic> requestData) async {
    final url =
        Uri.parse("${ApiService.baseUrl}/tests/upload_treatment_plan.php");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(response.body);
        return {'status': 'error', 'message': 'Failed to upload teeth data'};
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      print(e);
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> fetchDentalImages(
      String studentId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiService.baseUrl}/doctor/get_dental_images.php?student_id=$studentId'),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> fetchTeethImages(String studentId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiService.baseUrl}/doctor/get_teeth_images.php?student_id=$studentId'),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> fetchDentalImagesClinic(
      String patientId, String clinicId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiService.baseUrl}/clinic/fetch_clinic_images.php?patient_id=$patientId&clinic_id=$clinicId'),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.body);
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> fetchTeethImagesClinic(
      String patientId, String clinicId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiService.baseUrl}/clinic/fetch_clinic_teeth_data.php?patient_id=$patientId&clinic_id=$clinicId'),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.body);
    return json.decode(response.body);
  }

  // Fetch total students count and completed test count
  static Future<Map<String, String>> fetchTotalStudentCounts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/get_total_student_counts.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return {
            'total_students': data['total_students'],
            'test_completed_students': data['test_completed_students']
          };
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load student counts');
      }
    } catch (e) {
      print('Error fetching total students count: $e');
      return {'total_students': '0', 'test_completed_students': '0'};
    }
  }

  static Future<Map<String, dynamic>?> getDoctorDetails(String id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/admin/get_doctor_details.php?id=$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success' ? data['data'] : null;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getInstituteStats(
      String institute) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/admin/get_institute_stats.php?institute=$institute'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success' ? data['data'] : null;
    }
    return null;
  }

  static Future<List<String>?> getInstitutes() async {
    final response =
        await http.get(Uri.parse('$baseUrl/admin/get_institutes_list.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success'
          ? List<String>.from(
              data['data'].map((item) => item['name'].toString()))
          : null;
    }
    return null;
  }

  static Future<bool> assignInstitute(String doctorId, String institute) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/assign_institute.php'),
      body: json.encode({'doctor_id': doctorId, 'institute': institute}),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200 &&
        json.decode(response.body)['status'] == 'success';
  }

  static Future<bool> removeAssignment(String doctorId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/remove_institute_assignment.php'),
      body: json.encode({'doctor_id': doctorId}),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200 &&
        json.decode(response.body)['status'] == 'success';
  }
}
