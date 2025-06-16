import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/doctor/src/doctor_detail_screen.dart';
import 'package:new_dental/controller/admin/assign_dr_controller.dart';

class DoctorDataScreen extends StatelessWidget {
  final DoctorController controller = Get.put(DoctorController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "Doctor Assignment",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
             
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Doctors List",
                        style: Theme.of(context).textTheme.titleMedium),
                    DropdownButton<String>(
                      value: controller.sortOption.value,
                      items: ['Assigned', 'Available'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) =>
                          controller.changeSortOption(newValue!),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    itemCount: controller.filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = controller.filteredDoctors[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(DoctorDetailScreen(doctor: doctor),transition: Transition.rightToLeft, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.fullName,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      doctor.email,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (doctor.status == 'AS') ...[
                                      SizedBox(height: 4),
                                      Text(
                                        'Assigned to: ${doctor.assignedInstitute}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: doctor.status == 'AS'
                                          ? Colors.blue
                                          : doctor.status == 'AV'
                                              ? Colors.green
                                              : Colors.orange,
                                      borderRadius: BorderRadius.circular(21),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    doctor.status == 'AS'
                                        ? 'Assigned'
                                        : doctor.status == 'AV'
                                            ? 'Available'
                                            : 'Not Available',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
