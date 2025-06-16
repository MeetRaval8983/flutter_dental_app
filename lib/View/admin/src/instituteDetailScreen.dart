import 'package:flutter/material.dart';

class InstituteDetailScreen extends StatelessWidget {
  final String institute;

  InstituteDetailScreen({required this.institute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(institute)),
      body: Center(
        child: Text('Stats for ${institute} will be shown here.'),
      ),
    );
  }
}
