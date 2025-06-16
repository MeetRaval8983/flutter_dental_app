import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/controller/clinic/add_patient_controller.dart';

class RegisterSinglePatientScreen extends StatelessWidget {
  final ClinicPatientRegisterController controller =
      Get.put(ClinicPatientRegisterController());
  final String clinicId;
  RegisterSinglePatientScreen({Key? key, required this.clinicId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register New Patient')),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                  controller.fullNameController, 'Full Name', Icons.person),
              SizedBox(height: 16),
              _buildTextField(controller.emailController, 'Email', Icons.email,
                  inputType: TextInputType.emailAddress),
              SizedBox(height: 16),
              _buildTextField(
                  controller.mobileController, 'Mobile', Icons.phone,
                  inputType: TextInputType.phone),
              SizedBox(height: 16),
              _buildTextField(controller.ageController, 'Age', Icons.cake,
                  inputType: TextInputType.number),
              SizedBox(height: 16),
              _buildDropdownField('Gender', controller.selectedGender,
                  ['Male', 'Female', 'Other'], Icons.wc),
              SizedBox(height: 16),
              _buildDropdownField(
                  'Blood Group',
                  controller.selectedBloodGroup,
                  ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                  Icons.bloodtype),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  controller.registerClinicPatient(clinicId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, size: 20),
                    SizedBox(width: 8),
                    Text('Register Patient'),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      style: TextStyle(fontSize: 16, color: Colors.black),
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      keyboardType: inputType,
    );
  }

  Widget _buildDropdownField(String label, Rxn<String> selectedValue,
      List<String> options, IconData icon) {
    return DropdownButtonFormField<String>(
      value: selectedValue.value,
      style: TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) => selectedValue.value = value ?? '',
    );
  }
}
