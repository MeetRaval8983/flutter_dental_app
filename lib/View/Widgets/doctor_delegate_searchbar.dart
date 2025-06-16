import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/tests/test_1.dart';
import 'package:new_dental/controller/doctor_home_controller.dart';

class DoctorSearchDelegate extends SearchDelegate<String> {
  final DoctorHomeController controller;
  final Function(Map<String, dynamic>) onStudentSelected; // Callback function

  DoctorSearchDelegate({required this.controller, required this.onStudentSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Colors.grey),
        onPressed: () {
          query = '';
          controller.onSearchChanged(query); // Clear the search filter
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, ''); // Close the search bar
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredStudents = controller.filteredStudents;
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentTile(student);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredSuggestions = controller.students.where((student) {
      return student['full_name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10),
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) {
        final student = filteredSuggestions[index];
        return _buildStudentTile(student);
      },
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student) {
    return InkWell(
      onTap: () {
        if (student['is_test_completed']) {
          onStudentSelected(student); // Call the callback function
        } else {
          Get.to(() => UploadTeethImagePagewifi(studentInfo: student));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
              radius: 30,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.white),
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
                color: student['is_test_completed'] ? Colors.green : Colors.orange,
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

  @override
  TextStyle? get searchFieldStyle => TextStyle(
        color: Colors.white,
      );

  @override
  InputDecorationTheme get searchFieldDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.8),
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
