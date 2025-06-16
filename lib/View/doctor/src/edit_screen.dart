import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/controller/history/edit_controller.dart';
class EditStudentScreen extends GetView<EditStudentController> {
  final Map<String, dynamic> studentData;
  final Map<String, dynamic>? selectedStudentData;

  EditStudentScreen({
    Key? key, 
    required this.studentData, 
    this.selectedStudentData
  }) : super(key: key) {
    // Initialize the controller
    Get.put(EditStudentController(
      studentData: studentData, 
      selectedStudentData: selectedStudentData
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Define a common input decoration
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
      labelStyle: TextStyle(
        color: Colors.black
      ),
      filled: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Student Data'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(Icons.save),
            onPressed: controller.isLoading.value ? null : controller.saveChanges,
          )),
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: controller.nameController,
                    style: TextStyle(
                      color:Colors.black,
                    ),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Name',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: controller.ageController,
                    style: TextStyle(
                      color:Colors.black,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Age',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: controller.bloodGroupController,
                    style: TextStyle(
                      color:Colors.black,
                    ),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Blood Group',
                    ),
                  ),
                  SizedBox(height: 12),
                  Obx(() => DropdownButtonFormField<String>(
                    value: controller.gender.value,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Gender',
                      filled: false, 
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(
                                g,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) => controller.gender.value = value,
                    style: TextStyle(color: Colors.white),
                  )),

                  // Images Section
                  SizedBox(height: 24),
                  Text(
                    'Dental Images',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildImageCard('Front View', controller.frontImagePath.value, () => controller.pickImage('front')),
                        _buildImageCard('Upper View', controller.upperImagePath.value, () => controller.pickImage('upper')),
                        _buildImageCard('Lower View', controller.lowerImagePath.value, () => controller.pickImage('lower')),
                      ],
                    ),
                  ),

                  // Teeth Data Section
                  _buildTeethDataSection(context),

                  // Treatment Plan Section
                  SizedBox(height: 24),
                  Text(
                    'Treatment Plan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: controller.treatmentPlanController,
                    style: TextStyle(
                      color:Colors.black,
                    ),
                    maxLines: 4,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Treatment Plan',
                    ),
                  ),
                  
                  // Submit Button
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.saveChanges,
                    child: Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            )),
    );
  }

  Widget _buildImageCard(String title, String? imagePath, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(right: 12),
      child: Container(
        width: 150,
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:Colors.black,
                )),
            SizedBox(height: 8),
            InkWell(
              onTap: onTap,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _getImageWidget(imagePath),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.add_a_photo, size: 40, color: Colors.grey);
    } else if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    } else {
      return Image.file(
        File(imagePath),
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildTeethDataSection(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Text(
          'Teeth Analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16),
        ...controller.teethData.entries.map((entry) {
          String toothId = entry.key;
          Map<String, dynamic> toothData =
              Map<String, dynamic>.from(entry.value);

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tooth #$toothId",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.deleteTooth(toothId),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextField(
                    style: TextStyle(
                      color:Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Disease',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                        text: toothData['disease_name'] ?? toothData['disease'] ?? ''),
                    onChanged: (value) => controller.updateToothDisease(toothId, value),
                  ),
                  SizedBox(height: 12),
                  InkWell(
                    onTap: () => controller.pickToothImage(toothId),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8)),
                      child: _getToothImageWidget(toothData, toothId),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        ElevatedButton.icon(
          onPressed: () => _showAddToothDialog(context),
          icon: Icon(Icons.add),
          label: Text('Add New Tooth'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    ));
  }

  Widget _getToothImageWidget(Map<String, dynamic> toothData, String toothId) {
    // Check if we have a new local image
    if (toothData['imagePath'] != null && toothData['imagePath'].toString().startsWith('/')) {
      return Image.file(
        File(toothData['imagePath']),
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } 
    // Check if we have an existing remote image
    else if (toothData['tooth_image_path'] != null) {
      return CachedNetworkImage(
        imageUrl: toothData['tooth_image_path'],
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 40, color: Colors.grey),
      );
    } 
    // Otherwise show placeholder
    else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 40),
          SizedBox(height: 8),
          Text('Add Tooth Image')
        ],
      );
    }
  }

  void _showAddToothDialog(BuildContext context) {
    String newToothId = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Tooth'),
          content: TextField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Tooth Number',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => newToothId = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newToothId.isNotEmpty) {
                  controller.addNewTooth(newToothId);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}