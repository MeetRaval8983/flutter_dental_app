import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/Widgets/dental_image_section.dart';
import 'package:new_dental/View/Widgets/tooth_card_section.dart';
import 'package:new_dental/View/Widgets/user_profile_section.dart';
import 'package:new_dental/View/admin/src/stats.dart';
import 'package:new_dental/View/doctor/src/edit_screen.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/admin_home_controller.dart';
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/file_handle_api.dart';
import 'package:new_dental/services/pdf_service_net.dart';
class AdminHomeScreen extends StatelessWidget {
  final AdminHomeController controller = Get.put(AdminHomeController());
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

      // Close loading dialog
      Get.back();

      // Create a new map containing student data + fetched details
      final Map<String, dynamic> studentData = {
        "student": student, // Keep the original student data
        'dentalImages': dentalImages['data'],
        'teethImages': teethImages['data'],
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
              CircleAvatar(backgroundImage: AssetImage(ImageConstant.logo)),
              SizedBox(width: 10),
              Obx(() => Text(
                    'Welcome, ${controller.userName.value}',
                    style: TextStyle(color: cerulean, fontWeight: FontWeight.bold),
                  )),

            ],
          ),
          actions: [
            IconButton(onPressed: (){
              Get.to(StatisticsPage());
            }, icon: Icon(Icons.bar_chart, color: cerulean)),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsCard(),
              SizedBox(height: 20),
              _buildInstituteDropdown(),
              SizedBox(height: 10),
              Expanded(child: _buildStudentList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ceruleanlowop,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4))],
      ),
      child: Column(
        children: [
          Text('Statistics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Obx(() => _buildPieChart()),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    int total = int.parse(controller.totalStudentsCount.value);
    int completed = int.parse(controller.completedStudentsCount.value);
    int pending = total - completed;

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(color: Colors.green, value: completed.toDouble(), title: '$completed', radius: 50),
                    PieChartSectionData(color: Colors.red, value: pending.toDouble(), title: '$pending', radius: 50),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
              Center(
                child: Text('$total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegend('Completed', Colors.green),
            _buildLegend('Pending', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildInstituteDropdown() {
    return Obx(() => Row(
          children: [
            Text('Select Institute:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cerulean, width: 1.5),
                ),
                child: DropdownButton<String>(
                  value: controller.selectedInstitute.value,
                  isExpanded: true,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      controller.fetchStudentsForInstitute(newValue);
                    }
                  },
                  items: controller.allInstitutes.map((institute) {
                    return DropdownMenuItem<String>(
                      value: institute['name'],
                      child: Text(institute['name'], style: TextStyle(color: cerulean)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ));
  }

Widget _buildStudentList() {
  return Obx(() {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.filteredStudents.isEmpty) {
      return Center(
        child: Text(
          'No students found.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.filteredStudents.length,
      itemBuilder: (context, index) {
        final student = controller.filteredStudents[index];
        return _buildStudentCard(student, context);
      },
    );
  });
}


  Widget _buildStudentCard(Map<String, dynamic> student, BuildContext context) {
    return InkWell(
      onTap: () {
        print(student);
        if (student['is_test_completed']== "1") {
          _fetchStudentDetails(student, context);
        } else {
          Get.snackbar('Test Pending', 'This student has not completed the test.', backgroundColor: Colors.red, colorText: Colors.white);
        }
      },
      child: Card(
        child: ListTile(
          title: Text(student['full_name']?? 'No Name'),
          subtitle: Text(student['email']?? 'No Name'),
          trailing: Icon(student['is_test_completed'] == "1" ? Icons.check_circle : Icons.error, color: student['is_test_completed'] == "1" ? Colors.green : Colors.red),
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
                          UserProfileSection(
                            studentData: studentData['student'],
                          ),
                          // _buildUserProfile(
                          //   context,
                          //   Map<String, dynamic>.from(studentData),
                          // ),
                          SizedBox(height: 20),

                          // Images Section
                          Text(
                            "Dental Images",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 10),

                          // Displaying images dynamically
                          // _buildImageSection(
                          //     selectedStudentData!['dentalImages']),
                          DentalImageSection(
                              dentalImages: studentData['dentalImages']),
                          SizedBox(height: 20),

                          // Teeth Data Section
                          Text(
                            "Teeth Analysis",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 10),
                          if (studentData['teethImages'] != null)
                            ...(List<Map<String, dynamic>>.from(
                                    studentData['teethImages']))
                                .map(
                              (entry) => TeethDataCard(
                                toothId: entry['tooth_number'].toString(),
                                toothData: entry,
                              ),
                            ),

                          // // Treatment Plan Section
                          // SizedBox(height: 20),
                          // Text(
                          //   "Treatment Plan",
                          //   style: Theme.of(context)
                          //       .textTheme
                          //       .titleLarge
                          //       ?.copyWith(
                          //         color: Colors.black,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          // ),
                          // SizedBox(height: 10),
                          // Container(
                          //   padding: EdgeInsets.all(12),
                          //   decoration: BoxDecoration(
                          //     // color: Theme.of(context).cardColor,
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: Text(
                          //     studentData['treatmentPlan']
                          //                 ['treatment_description']
                          //             ?.toString() ??
                          //         "No treatment plan available",
                          //     style:
                          //         TextStyle(color: Colors.black, fontSize: 16),
                          //   ),
                          // ),

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
                                _handleEdit(studentData['student'],
                                    studentData as Map<String, dynamic>);
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
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
                              onPressed: () => _generatePDF(
                                  studentData['student'],
                                  studentData.cast<String, dynamic>()),
                              icon: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.white,
                              ),
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
