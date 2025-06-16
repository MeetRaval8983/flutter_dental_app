import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:new_dental/View/Widgets/dental_image_section.dart';
import 'package:new_dental/View/Widgets/tooth_card_section.dart';
import 'package:new_dental/View/Widgets/user_profile_section.dart';
import 'package:new_dental/View/clinic/src/add_patient.dart';
import 'package:new_dental/View/clinic/src/search_clinic.dart';
import 'package:new_dental/View/doctor/src/edit_screen.dart';
import 'package:new_dental/View/tests/test_1.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/clinic/clinic_home_controlle.dart';
import 'package:new_dental/controller/test/report_controller.dart';
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/file_handle_api.dart';
import 'package:new_dental/services/pdf_service_net.dart';

class ClinicHomeScreen extends StatelessWidget {
  final ClinicHomeController controller = Get.put(ClinicHomeController());
  final ReportController reportController = Get.put(ReportController());

  ClinicHomeScreen({super.key});

  Future<void> _fetchStudentDetails(
      Map<String, dynamic> student, BuildContext context,String clientId) async {
    try {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        ),
        barrierDismissible: false,
      );

      final dentalImages = await ApiService.fetchDentalImagesClinic(student['id'].toString(),clientId );
      final teethImages = await ApiService.fetchTeethImagesClinic(student['id'].toString(),clientId);

      Get.back();

      final Map<String, dynamic> studentData = {
        "student": student,
        'dentalImages': dentalImages['data'],
        'teethImages': teethImages['data'],
      };

      _showStudentDetails(studentData, context);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Failed to fetch patient details: $e',
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(ImageConstant.logo),
              ),
              SizedBox(width: 10),
              Text(
                'DentiPic',
                style: TextStyle(color: purple, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: purple),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ClinicSearchDelegate(
                    controller: controller,
                    onPatientSelected: (student) =>
                        _fetchStudentDetails(student, context, controller.clinicId.value),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStatisticsCard(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Text(
                    'Hello Dr. ${controller.userName.value}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: purple),
                  )),
            ),
            Expanded(
              child: Obx(() {
                final allPatients = controller.filteredPatients;
                return RefreshIndicator(
                  onRefresh: () async {
                    controller.reset(); // reset the first-load flag
                    await controller.loadClinicData(); // reload data
                  },
                  child: allPatients.isEmpty
                      ? ListView(
                          // Ensures RefreshIndicator works even if list is empty
                          children: [
                            SizedBox(height: 200),
                            Center(
                              child: Text('No patients found.',
                                  style: TextStyle(color: Colors.black54)),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: allPatients.length,
                          itemBuilder: (context, index) {
                            final student = allPatients[index];
                            return _buildStudentCard(student, context);
                          },
                        ),
                );
              }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(() => RegisterSinglePatientScreen(
                clinicId: controller.clinicId.value,
              )),
          backgroundColor: purple,
          child: Icon(Icons.person_add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: Colors.white));
      }

      return Container(
        height: 180,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [purple, brightTurquoise],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  controller.clinicName.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(
                  "Dr. ${controller.userName.value}",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            // Total Patients Stat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.people, color: Colors.white, size: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${controller.totalPatientsCount.value}",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Total Patients",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStudentCard(Map<String, dynamic> student, BuildContext context) {
    final createdAt = DateTime.tryParse(student['created_at'] ?? '');
    final formattedDate = createdAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(createdAt)
        : 'Unknown';

    return InkWell(
      onTap: () async {
        if (student['is_test_completed'] == 1) {
          await _fetchStudentDetails(student, context, controller.clinicId.value);
        } else {
          Get.to(() => UploadTeethImagePagewifi(studentInfo: student),
              transition: Transition.rightToLeft,
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
                radius: 25,
                backgroundColor: purple,
                child:
                    Icon(Icons.person_outlined, color: Colors.white, size: 30)),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student['full_name'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87)),
                  SizedBox(height: 4),
                  Text(student['email'],
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Text(
                    'Added on: $formattedDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: student['is_test_completed'] == 1
                    ? Colors.green
                    : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                student['is_test_completed'] == 1 ? 'Completed' : 'Pending',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

void _showStudentDetails(Map studentData, BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final student = studentData['student'];
          // final treatmentPlan = studentData['treatmentPlan'];
          final dentalImages = studentData['dentalImages'];
          final teethImages = studentData['teethImages'];

          return Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Basic Info
                        student != null
                            ? UserProfileSection(studentData: student)
                            : Center(child: Text("Student data not available")),

                        SizedBox(height: 20),

                        // Dental Images
                        Text(
                          "Dental Images",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 10),
                        dentalImages != null
                            ? DentalImageSection(dentalImages: dentalImages)
                            : Center(child: Text("Dental images not available")),

                        SizedBox(height: 20),

                        // Teeth Analysis
                        Text(
                          "Teeth Analysis",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 10),
                        if (teethImages != null &&
                            teethImages is List &&
                            teethImages.isNotEmpty)
                          ...List<Map<String, dynamic>>.from(teethImages).map(
                            (entry) => TeethDataCard(
                              toothId: entry['tooth_number'].toString(),
                              toothData: entry,
                            ),
                          )
                        else
                          Center(child: Text("Teeth images not available")),

                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              if (student != null) {
                                _handleEdit(studentData['student'],
                                    studentData as Map<String, dynamic>);
                              } else {
                                Get.snackbar("Error", "Student data not available",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                              }
                            },
                            icon: Icon(Icons.edit, color: Colors.white),
                            label: Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (student != null) {
                                _generatePDF(student, studentData.cast<String, dynamic>());
                              } else {
                                Get.snackbar("Error", "Cannot generate PDF, student data is missing",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                              }
                            },
                            icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                            label: Text('Generate PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  void _handleEdit(
      Map<String, dynamic> student, Map<String, dynamic> studentData) {
    // Navigate to the edit screen
    Get.to(() => EditStudentScreen(
          studentData: student,
          selectedStudentData: studentData,
        ));
  }

  Future<void> _generatePDF(
      Map studentData, Map<String, dynamic>? selectedStudentData) async {
    try {
      // Show loading dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Generating PDF...',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Cast the student data to the correct type
      final Map<String, dynamic> typedStudentData =
          Map<String, dynamic>.from(studentData);

      // Convert teeth images list to map with tooth number as key
      final List<dynamic> teethImagesList =
          selectedStudentData?['teethImages'] ?? [];
      final Map<String, dynamic> teethImagesMap = {};

      for (var tooth in teethImagesList) {
        teethImagesMap[tooth['tooth_number'].toString()] = {
          'disease_name': tooth['disease_name'],
          'tooth_image_path': tooth['tooth_image_path'],
          'treatment_plan': tooth['treatment_plan'],
        };
      }

      final pdfApi = PdfApi();
      final pdfFile = await pdfApi.generate(
        typedStudentData,
        selectedStudentData?['dentalImages']?['front_image_path'] ?? '',
        selectedStudentData?['dentalImages']?['upper_image_path'] ?? '',
        selectedStudentData?['dentalImages']?['lower_image_path'] ?? '',
        teethImagesMap
      );

      // Remove loading dialog
      Get.back();

      // Open the generated PDF
      await FileHandleApi.openFile(pdfFile);
      reportController.sendPdfByEmail( pdfFile, studentData["email"]);

      // Show success message
      Get.snackbar(
        'Success',
        'PDF generated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Remove loading dialog if it's still open
      if (Get.isDialogOpen ?? false) Get.back();

      // print('Error in PDF generation: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
    }
  }
}
