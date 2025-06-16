import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/Model/doctor.dart';
import 'package:new_dental/const.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:new_dental/controller/admin/dr_detail_controller.dart';

class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;

  DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorDetailController(doctor.id));

    return Scaffold(
      backgroundColor: purple,
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  doctor.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  doctor.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Assign Institute",
                            style: TextStyle(
                              fontSize: 18,
                              color: black,
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Dynamic UI based on institute assignment
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (controller.doctorData
                                        .value?['assigned_institute'] ==
                                    null ||
                                controller
                                    .doctorData.value!['assigned_institute']
                                    .toString()
                                    .isEmpty) {
                              // No institute assigned, show dropdown
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1),
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
                                          value: controller
                                              .selectedInstitute.value,
                                          hint: const Text(
                                            "Select an institute",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16),
                                          ),
                                          isExpanded: true,
                                          icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black),
                                          dropdownColor: Colors.white,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                          items: controller.institutes
                                              .map((String institute) {
                                            return DropdownMenuItem<String>(
                                              value: institute,
                                              child: Text(
                                                institute,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            controller.selectedInstitute.value =
                                                newValue;
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            } else {
                              // Institute assigned, show Pie Chart
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.doctorData
                                            .value?['assigned_institute'] ??
                                        "N/A",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      letterSpacing: 0,
                                      color: black,
                                    ),
                                  ),
                                  const SizedBox(height: 80),

                                  // Pie Chart for Institute Stats
                                  Obx(() {
                                    if (controller.instituteStats.value ==
                                        null) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    Map<String, dynamic> stats =
                                        controller.instituteStats.value!;
                                    return SizedBox(
                                      height: 350,
                                      child: PieChart(
                                        PieChartData(
                                          sections: stats.entries.map((entry) {
                                            return PieChartSectionData(
                                              value: double.parse(
                                                  entry.value.toString()),
                                              title: entry.key,
                                              color: Colors.primaries[stats.keys
                                                      .toList()
                                                      .indexOf(entry.key) %
                                                  Colors.primaries.length],
                                              radius: 100,
                                              titleStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              );
                            }
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: grey.withOpacity(0.3),
              blurRadius: 5,
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic Button based on Institute Assignment
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.doctorData.value?['assigned_institute'] == null ||
                  controller.doctorData.value!['assigned_institute']
                      .toString()
                      .isEmpty) {
                // No Institute Assigned → Show Assign Button
                return ElevatedButton(
                  onPressed: controller.selectedInstitute.value != null
                      ? controller.assignInstitute
                      : null, // Disable button if no institute is selected
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Center(
                    child: Text(
                      "Assign Institute",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              } else {
                // Institute Assigned → Show Remove Button
                return ElevatedButton(
                  onPressed: controller.removeAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Center(
                    child: Text(
                      "Remove Institute",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
