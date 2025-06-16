import 'package:flutter/material.dart';
import 'package:new_dental/const.dart';

class UserProfileWidget extends StatelessWidget {
  final Map<String, dynamic> studentInfo;

  const UserProfileWidget({Key? key, required this.studentInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
      decoration: BoxDecoration(
        color: cerulean,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 1),
                child: Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Text(studentInfo['full_name'].toString()),
              ),
              const SizedBox(height: 12),
              const Text("Blood Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(studentInfo['blood_group'].toString()),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 32, bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Gender", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(studentInfo['gender'].toString()),
                const SizedBox(height: 12),
                const Text("Age", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(studentInfo['age'].toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
