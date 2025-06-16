import 'package:flutter/material.dart';
import 'package:new_dental/Model/doctor.dart';
import 'package:new_dental/const.dart';

class DoctorItem extends StatelessWidget {
  final Doctor doctor;

  const DoctorItem({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage:AssetImage(ImageConstant.logo),
        ),
        title: Text(
          doctor.fullName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(doctor.assignedInstitute),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Handle doctor tap (e.g., navigate to details)
        },
      ),
    );
  }
}
