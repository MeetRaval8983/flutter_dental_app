import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_dental/View/admin/src/instituteDetailScreen.dart';

import '../../../controller/admin/instituteController.dart';

class InstituteDataScreen extends StatelessWidget {
  final InstituteController controller = Get.put(InstituteController());
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.defaultDialog(
              title: 'Add Institute',
              content: TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Institute Name'),
              ),
              textConfirm: 'Add',
              onConfirm: () {
                if (nameController.text.isNotEmpty) {
                  controller.addInstitute(nameController.text.trim());
                  nameController.clear();
                  Get.back();
                }
              },
            );
          },
          child: Icon(Icons.add),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "Institutes",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.institutes.length,
                  itemBuilder: (context, index) {
                    final institute = controller.institutes[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(InstituteDetailScreen(institute: institute));
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6,
                              color: Colors.black12,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                institute,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                controller.deleteInstitute(institute);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
