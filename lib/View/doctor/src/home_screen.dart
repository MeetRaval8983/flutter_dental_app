import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/Widgets/dental_image_section.dart';
import 'package:new_dental/View/Widgets/doctor_delegate_searchbar.dart';
import 'package:new_dental/View/Widgets/tooth_card_section.dart';
import 'package:new_dental/View/Widgets/user_profile_section.dart';
import 'package:new_dental/View/doctor/src/edit_screen.dart';
import 'package:new_dental/View/tests/test_1.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/doctor_home_controller.dart';
import 'package:new_dental/controller/test/report_controller.dart';
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/file_handle_api.dart';
import 'package:new_dental/services/pdf_service_net.dart';

class DoctorHomeScreen extends StatelessWidget {
  final DoctorHomeController controller = Get.put(DoctorHomeController());
  final ReportController reportController = Get.put(ReportController());
  Future<void> _fetchStudentDetails(
      Map<String, dynamic> student, BuildContext context) async {
    try {
      // Show loading dialog
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator()),
        ),
        barrierDismissible: false,
      );

      // Fetch data from API
      final dentalImages = await ApiService.fetchDentalImages(student['id']);
      final teethImages = await ApiService.fetchTeethImages(student['id']);
      // final treatmentPlan = await ApiService.fetchTreatmentPlan(student['id']);

      // Close loading dialog
      Get.back();

      // Create a new map containing student data + fetched details
      final Map<String, dynamic> studentData = {
        "student": student, // Keep the original student data
        'dentalImages': dentalImages['data'],
        'teethImages': teethImages['data'],
        // 'treatmentPlan': treatmentPlan['data'],
      };

      // Pass the complete data to bottom sheet
      // print(studentData);
      // print(treatmentPlan);
      _showStudentDetails(studentData, context);
    } catch (e) {
      // Close loading dialog if error occurs
      if (Get.isDialogOpen ?? false) Get.back();

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to fetch student details: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              CircleAvatar(
                  backgroundImage: AssetImage(ImageConstant.logo),
                  ),
              SizedBox(width: 10),
              Obx(() => Text(
                    'Hello Dr. ${controller.userName.value}',
                    style:
                        TextStyle(color: purple, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: purple),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: DoctorSearchDelegate(
                    controller: controller,
                    onStudentSelected: (student) => _fetchStudentDetails(student, context),
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
            Expanded(
              child: DefaultTabController(
                length: 2, // Adjusted to 2 for Completed and Pending
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          // color: grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TabBar(
                          // indicatorColor: Colors.white,
                          unselectedLabelColor: black.withOpacity(0.5),
                          labelColor: Colors.white,
                          indicator: BoxDecoration(
                            color: purple,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          tabs: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Tab(
                                text: 'Pending',
                                icon: Icon(Icons.pending),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Tab(
                                text: 'Completed',
                                icon: Icon(Icons.done),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildPendingList(),
                          _buildCompletedList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],  
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
  return Obx(() {
    // Check if data is still loading
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Container(
      height: 200,
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
        children: [
          Text(
            'Statistics',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Total Patients',
                controller.totalStudentsCount.value.toString(),
                Colors.white,
              ),
              _buildStatItem(
                'Completed Tests',
                controller.completedStudentsCount.value.toString(),
                Colors.white,
              ),
              _buildStatItem(
                'Pending Tests',
                (controller.totalStudentsCount.value -
                        controller.completedStudentsCount.value)
                    .toString(),
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  });
}


  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Icon(Icons.person, color: color, size: 30),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCompletedList() {
    return Obx(() {
      final completedStudents = controller.filteredStudents
          .where((student) => student['is_test_completed'] == true)
          .toList();

      return completedStudents.isEmpty
          ? Center(
              child: Text('No completed tests yet.',
                  style: TextStyle(color: Colors.black54)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: completedStudents.length,
              itemBuilder: (context, index) {
                final student = completedStudents[index];
                return _buildStudentCard(student, context);
              },
            );
    });
  }

  Widget _buildPendingList() {
    return Obx(() {
      final pendingStudents = controller.filteredStudents
          .where((student) => student['is_test_completed'] == false)
          .toList();

      return pendingStudents.isEmpty
          ? Center(
              child: Text('No pending tests.',
                  style: TextStyle(color: Colors.black54)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: pendingStudents.length,
              itemBuilder: (context, index) {
                final student = pendingStudents[index];
                return _buildStudentCard(student, context);
              },
            );
    });
  }

  Widget _buildStudentCard(Map<String, dynamic> student, BuildContext context) {
    return InkWell(
      onTap: () async {
        if (student['is_test_completed']) {
          // Fetch additional data for completed tests
          print(student);
          await _fetchStudentDetails(student, context);
        } else {
          // Navigate to the upload page for pending tests
          Get.to(() => UploadTeethImagePagewifi(studentInfo: student), transition: Transition.rightToLeft, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
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
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: purple,
              child: Icon(Icons.person_outlined, color: Colors.white, size: 30),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['full_name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    student['email'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    student['is_test_completed'] ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                student['is_test_completed'] ? 'Completed' : 'Pending',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
      reportController.sendPdfByEmail(studentData["email"],pdfFile as String);

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

      print('Error in PDF generation: $e');

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
