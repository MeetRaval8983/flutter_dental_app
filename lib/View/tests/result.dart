import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:new_dental/View/Widgets/card_user_profile.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/controller/test/report_controller.dart';
import 'package:new_dental/controller/test/test_1_controller.dart';
import 'package:new_dental/controller/test/test_2_controller.dart';
import 'package:new_dental/controller/test/test_3_controller.dart';

class CombinedReportPage extends StatelessWidget {
  final Map<String, dynamic> studentInfo;
  final TestOneController test1Controller = Get.put(TestOneController());
  final TestTwoController test2Controller = Get.put(TestTwoController());
  final TreatmentPlanController test3Controller =
      Get.put(TreatmentPlanController());
  final ReportController reportController = Get.put(ReportController());

  CombinedReportPage({super.key, required this.studentInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            // Using Obx to observe changes in the loading state
            return reportController.isLoading.value
                ? Center(
                    child: Lottie.asset('assets/lottie/loader.json',
                        height: 100, width: 100),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient Details",
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      UserProfileWidget(studentInfo: studentInfo),
                      Divider(),
                      Text("Images",
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImageTile('Front Image',
                              test1Controller.frontImagePath.value, context),
                          _buildImageTile('Upper Image',
                              test1Controller.upperImagePath.value, context),
                          _buildImageTile('Lower Image',
                              test1Controller.lowerImagePath.value, context),
                        ],
                      ),
                      Divider(),
                      Text("Teeth Data",
                          style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 8),
                      Obx(() {
                        final treatmentPlanData =
                            test3Controller.getTreatmentPlanData();

                        return treatmentPlanData.isNotEmpty
                            ? Column(
                                children:
                                    treatmentPlanData.entries.map((entry) {
                                  final toothId = entry
                                      .key; // This is string '11', '12', etc
                                  final disease = entry.value['disease'] ?? '';
                                  final imagePath =
                                      entry.value['imagePath'] ?? '';
                                  final treatmentPlan =
                                      entry.value['treatmentPlan'] ?? '';

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: ListTile(
                                      title: Text("Tooth Number: $toothId"),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),

                                          Text("Clinical Findings: $disease",style: TextStyle(fontSize: 16),),
                                          const SizedBox(height: 8),
                                          Text(
                                              "Treatment Plan: $treatmentPlan",style: TextStyle(fontSize: 16)),
                                          const SizedBox(height: 8),
                                          Text("Tooth Image:"),
                                          const SizedBox(height: 4),
                                          imagePath.isNotEmpty
                                              ? GestureDetector(
                                                  onTap: () {
                                                    _openImageDialog(
                                                        context, imagePath);
                                                  },
                                                  child: Image.file(
                                                    File(imagePath),
                                                    height: 100,
                                                    width: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Text("No image found."),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            : Text("No teeth data available.");
                      }),
                      Divider(),
                      Obx(() => Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: purple,
                                value: reportController.mailReport.value,
                                onChanged: (value) {
                                  reportController.sendByMAil(value!);
                                },
                              ),
                              Text("Send report via email",
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ],
                          )),
                    ],
                  );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showConfirmationDialog(context);
        },
        backgroundColor: cerulean,
        child: Icon(Icons.done, color: Colors.white, size: 40),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Confirm Submit",
      middleText: "Are you sure you want to submit this report?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      middleTextStyle: TextStyle(
        color: Colors.black,
      ),
      onConfirm: () {
        // Process and submit the report using GetX
        Get.back();
          // Build the treatment plan list
  // final treatmentPlanList = <Map<String, dynamic>>[];

  final treatmentPlanData = test3Controller.getTreatmentPlanData();
  // treatmentPlanData.forEach((toothNumberStr, values) {
  //   treatmentPlanList.add({
  //     "toothNumber": int.parse(toothNumberStr),
  //     "treatmentPlan": values['treatmentPlan'],
  //   });
  // });
        reportController.submitReport(
          studentInfo,
          treatmentPlanData,
          test1Controller.frontImagePath.value,
          test1Controller.upperImagePath.value,
          test1Controller.lowerImagePath.value,
        );
      },
    );
  }

  Widget _buildImageTile(
      String label, String? imagePath, BuildContext context) {
    return imagePath != null
        ? GestureDetector(
            onTap: () => _openImageDialog(context, imagePath),
            child: Column(
              children: [
                Text(label),
                SizedBox(height: 8),
                Image.file(File(imagePath),
                    width: 120, height: 120, fit: BoxFit.cover),
              ],
            ),
          )
        : Container();
  }

  void _openImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Image Preview"),
          content: Image.file(File(imagePath)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close")),
          ],
        );
      },
    );
  }
}
