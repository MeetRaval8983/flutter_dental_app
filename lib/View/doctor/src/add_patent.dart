import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/controller/admin/patient_data_upload_controller.dart';

class StudentDataUploadScreen extends StatelessWidget {
  final StudentDataUploadController controller =
      Get.put(StudentDataUploadController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Data Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: () {
              controller.reset(); // Reset all form fieldsr
            },
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          tabs: [
            Tab(icon: Icon(Icons.upload_file), text: 'CSV Upload'),
            Tab(icon: Icon(Icons.person_add), text: 'Manual Entry'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildCsvUploadTab(),
          _buildManualEntryTab(),
        ],
      ),
    );
  }

  Widget _buildCsvUploadTab() {
    return Obx(() {
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedInstitute.value,
                      hint: const Text(
                        "Select an institute",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.black),
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      items: controller.institutes.map((String institute) {
                        return DropdownMenuItem<String>(
                          value: institute,
                          child: Text(
                            institute,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        controller.selectedInstitute.value = newValue;
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: controller.csvData.isEmpty
                    ? Center(
                        child: GestureDetector(
                          onTap: controller.uploadCSVFile,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 80,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Select CSV File',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.csvData.length,
                        itemBuilder: (context, index) {
                          final student = controller.csvData[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(student['full_name'] ?? 'N/A'),
                              subtitle: Text(student['email'] ?? 'N/A'),
                              trailing: Text(student['age'] ?? 'N/A'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: controller.csvData.isEmpty
                    ? null
                    : controller.uploadStudents, // Disable button if no data
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  elevation: 5, // Shadow effect
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload_file,
                        size: 20, color: Colors.white), // Upload icon
                    SizedBox(width: 8), // Space between icon and text
                    Text('Upload CSV'),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildManualEntryTab() {
    return Obx(() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: TextStyle(fontSize: 16, color: Colors.black),
              controller: controller.fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                prefixIcon: Icon(Icons.person, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(fontSize: 16, color: Colors.black),
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                prefixIcon: Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(fontSize: 16, color: Colors.black),
              controller: controller.mobileController,
              decoration: InputDecoration(
                labelText: 'Mobile',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                prefixIcon: Icon(Icons.phone, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(fontSize: 16, color: Colors.black),
              controller: controller.ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                prefixIcon: Icon(Icons.cake, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              style: TextStyle(fontSize: 16, color: Colors.black),
              value: controller.selectedGender.value,
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                prefixIcon: Icon(Icons.wc, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                controller.selectedGender.value = value;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              style: TextStyle(fontSize: 16, color: Colors.black),
              value: controller.selectedBloodGroup.value,
              decoration: InputDecoration(
                labelText: 'Blood Group',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                prefixIcon: Icon(Icons.bloodtype, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                  .map((bloodGroup) => DropdownMenuItem(
                        value: bloodGroup,
                        child: Text(bloodGroup),
                      ))
                  .toList(),
              onChanged: (value) {
                controller.selectedBloodGroup.value = value;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              style: TextStyle(fontSize: 16, color: Colors.black),
              value: controller.selectedInstitute.value,
              decoration: InputDecoration(
                labelText: 'Institute',
                labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                prefixIcon: Icon(Icons.school, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              items: controller.institutes
                  .map((institute) => DropdownMenuItem(
                        value: institute,
                        child: Text(institute),
                      ))
                  .toList(),
              onChanged: (value) {
                controller.selectedInstitute.value = value;
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: controller.registerSingleStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add, size: 20),
                  SizedBox(width: 8),
                  Text('Register Student'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
