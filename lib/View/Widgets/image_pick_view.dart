import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/test/test_1_controller.dart';
import 'package:new_dental/services/permission_service.dart';

class ImagePickerView extends StatefulWidget {
  final String label;

  const ImagePickerView({
    super.key,
    required this.label,
  });

  @override
  _ImagePickerViewState createState() => _ImagePickerViewState();
}

class _ImagePickerViewState extends State<ImagePickerView> {
  final TestOneController testController = Get.put(TestOneController());

  Future<void> _pickImage(ImageSource source) async {
    bool granted = await PermissionService.requestCameraAndGalleryPermissions();

    if (!granted) {
      _showPermissionDialog();
      return;
    }
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      testController.setImagePath(widget.label, pickedFile.path);
    }
    Navigator.pop(context);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
            'Please allow camera and gallery access to select an image.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await PermissionService.requestCameraAndGalleryPermissions();
            },
            child: const Text('Allow Permissions'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a picture'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => _pickImage(ImageSource.gallery),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showImageSourceBottomSheet(context);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 400,
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cerulean.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 50, color: Colors.black),
                const SizedBox(height: 10),
                Text('Select ${widget.label} Image',
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
              ],
            ),
          ),

          // Show Selected Image using GetX Observer
          Obx(() {
            String? imagePath;
            switch (widget.label) {
              case 'Front':
                imagePath = testController.frontImagePath.value;
                break;
              case 'Upper':
                imagePath = testController.upperImagePath.value;
                break;
              case 'Lower':
                imagePath = testController.lowerImagePath.value;
                break;
            }

            if (imagePath != null) {
              return Image.file(
                File(imagePath),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              );
            }
            return const SizedBox(); // Empty if no image selected
          }),

          // Dotted Border Overlay
          Align(
            alignment: Alignment.center,
            child: DottedBorder(
              color: Colors.black,
              strokeWidth: 2,
              dashPattern: [4, 4],
              child: Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
