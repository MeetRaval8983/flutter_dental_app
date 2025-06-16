import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/controller/test/test_3_controller.dart';
import 'package:new_dental/View/Widgets/card_user_profile.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/View/tests/result.dart';

class TreatmntPlan extends StatelessWidget {
  final Map<String, dynamic> studentInfo;
  final controller = Get.put(TreatmentPlanController());

  TreatmntPlan({super.key, required this.studentInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treatment Plan'),
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  UserProfileWidget(studentInfo: studentInfo),
                  const SizedBox(height: 20),
                  Text('Step 3: Treatment Plan for Each Tooth',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cerulean)),
                  const SizedBox(height: 20),
                  ListView.builder(
                    itemCount: controller.selectedTeeth.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) {
                      int toothId = int.parse(controller.selectedTeeth[index]);
                      return _buildToothCard(controller, toothId);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final treatmentData = controller.getTreatmentPlanData();
          if (treatmentData.isEmpty) {
            Get.snackbar('Notice', 'Please fill at least one treatment plan');
            return;
          }
          Get.to(() => CombinedReportPage(studentInfo: studentInfo));
        },
        backgroundColor: cerulean,
        child: const Icon(Icons.done, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildToothCard(TreatmentPlanController controller, int toothId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tooth #$toothId",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black)),
            if (controller.imagePaths[toothId] != null) ...[
              const SizedBox(height: 8),
              Image.file(File(controller.imagePaths[toothId]!), height: 100),
            ],
            const SizedBox(height: 8),
            Text("Disease: ${controller.diseases[toothId] ?? 'N/A'}"),
            const SizedBox(height: 8),
            TextField(
              style: TextStyle(color: Colors.black),
              controller: controller.treatmentControllers[toothId],
              decoration: InputDecoration(
                labelText: "Treatment Plan (optional)",
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(
                  () => IconButton(
                    icon: Icon(
                      controller.isListeningMap[toothId] == true
                          ? Icons.mic
                          : Icons.mic_none,
                      color: controller.isListeningMap[toothId] == true
                          ? Colors.red
                          : Colors.black,
                    ),
                    onPressed: () => controller.toggleListening(toothId),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
