import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_dental/View/Widgets/card_user_profile.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/test/test_2_controller.dart';
import 'package:teeth_selector/teeth_selector.dart';

class SelectDiseasesStep extends StatefulWidget {
  final Map<String, dynamic> studentInfo;

  const SelectDiseasesStep({super.key, required this.studentInfo});

  @override
  // ignore: library_private_types_in_public_api
  _UploadTeethImagePagewifiState createState() =>
      _UploadTeethImagePagewifiState();
}

class _UploadTeethImagePagewifiState extends State<SelectDiseasesStep> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestTwoController>(
      init: TestTwoController(), // Initialize controller
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Select Tooth Diseases'),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            // Wrap body in SingleChildScrollView to avoid overflow
            child: Column(
              children: [
                _buildContent(controller),
                SizedBox(height: 30),
                _buildToothDiseaseList(controller),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (_allDiseasesEntered(controller) &&
                  _allImagesSelected(controller)) {
                await controller.uploadTeethData(widget.studentInfo);
              } else {
                Get.snackbar("Required!",
                    "Please fill clinical findings and select images.",
                    backgroundColor: Colors.orange);
              }
            },
            backgroundColor: cerulean,
            child: const Icon(Icons.done, color: Colors.white, size: 40),
          ),
        );
      },
    );
  }

  bool _allDiseasesEntered(TestTwoController controller) {
    // Check if all selected teeth have a disease entered
    for (var toothId in controller.selectedTeeth) {
      if (controller.diseaseControllers[int.parse(toothId)]?.text.isEmpty ??
          true) {
        return false;
      }
    }
    return true;
  }

  bool _allImagesSelected(TestTwoController controller) {
    // Check if all selected teeth have an image
    for (var toothId in controller.selectedTeeth) {
      if (controller.imagePaths[int.parse(toothId)] == null) {
        return false;
      }
    }
    return true;
  }

  Widget _buildContent(TestTwoController controller) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(height: 30),
          UserProfileWidget(studentInfo: widget.studentInfo),
          SizedBox(height: 30),
          Text(
            'Step 1: Select Tooth Diseases',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: cerulean),
          ),
          SizedBox(height: 30),
          Container(
            height: 500,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cerulean.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: TeethSelector(
                onChange: (selected) {
                  controller.updateSelectedTeeth(selected);
                },
                initiallySelected: controller.selectedTeeth.toList(),
                multiSelect: true,
                unselectedColor: Colors.white,
                selectedColor: Colors.black,
                showPermanent: true,
                showPrimary: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToothDiseaseList(TestTwoController controller) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.selectedTeeth.length,
      itemBuilder: (context, index) {
        final toothId = int.parse(controller.selectedTeeth[index]);
        controller.diseaseControllers
            .putIfAbsent(toothId, () => TextEditingController());

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tooth #${controller.selectedTeeth[index]}',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    // Call updateDisease to store the disease in the controller
                    controller.updateDisease(toothId, value);
                  },
                  cursorColor: purple,
                  controller: controller.diseaseControllers[toothId],
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusColor: Colors.green,
                    labelText: "Disease",
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isListeningMap[toothId] == true
                            ? Icons.mic
                            : Icons.mic_none,
                        color: controller.isListeningMap[toothId] == true
                            ? Colors.red
                            : Colors.black, // 👈 black by default
                      ),
                      onPressed: () {
                        controller.toggleListening(toothId);
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: () => _showImageSourceBottomSheet(
                          context, toothId, controller),
                    ),
                    if (controller.imagePaths[toothId] != null)
                      Image.file(
                        File(controller.imagePaths[toothId]!),
                        width: 50,
                        height: 50,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show image source bottom sheet (example function, implement as needed)
  void _showImageSourceBottomSheet(
      BuildContext context, int toothId, TestTwoController controller) {
    // Implement the logic to show image source options
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () =>
                    _selectImage(toothId, controller, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImage(toothId, controller,
                      ImageSource.gallery); // Choose image from gallery
                },
              ),
              ListTile(
              leading: const Icon(Icons.wifi_tethering),
              title: const Text('Upload from WiFi Camera'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Available Soon'),
                    content: const Text(
                        'This feature will be available soon.'),
                    actions: [
                      // TextButton(
                      //   onPressed: () async {
                      //     Navigator.of(context).pop(); // Close dialog
                      //     await PermissionService
                      //         .requestCameraAndGalleryPermissions();
                      //   },
                      //   child: const Text('Allow Permissions'),
                      // ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('ok'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectImage(
      int toothId, TestTwoController controller, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final imagePath = image.path;
      controller.updateImagePath(toothId, imagePath);
    }
  }
}
