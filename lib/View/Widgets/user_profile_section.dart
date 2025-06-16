import 'package:flutter/material.dart';
import 'package:new_dental/View/Widgets/detail_row.dart';

class UserProfileSection extends StatelessWidget {
  final Map<String, dynamic> studentData;

  UserProfileSection({required this.studentData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        DetailRow(title: 'Name', value: studentData['full_name'].toString()),
        DetailRow(title: 'Gender', value: studentData['gender'].toString()),
        DetailRow(title: 'Age', value: studentData['age'].toString()),
        DetailRow(title: 'Blood Group', value: studentData['blood_group'].toString()),
      ],
    );
  }
}
