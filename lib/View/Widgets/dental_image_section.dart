import 'package:flutter/material.dart';

class DentalImageSection extends StatelessWidget {
  final Map<String, dynamic> dentalImages;

  DentalImageSection({required this.dentalImages});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> images = [
      {'title': 'Front View', 'path': dentalImages['front_image_path']?.toString() ?? ''},
      {'title': 'Upper View', 'path': dentalImages['upper_image_path']?.toString() ?? ''},
      {'title': 'Lower View', 'path': dentalImages['lower_image_path']?.toString() ?? ''},
    ];

    List<Widget> imageWidgets = images
        .where((img) => img['path'] != null && img['path']!.isNotEmpty)
        .map((img) => _buildImageCard(context, img['title']!, img['path']!))
        .toList();

    if (imageWidgets.isEmpty) {
      return Center(
        child: Text("No images available", style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: imageWidgets),
    );
  }

  Widget _buildImageCard(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, title, imagePath),
      child: Card(
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Image.network(imagePath, height: 100, width: 100, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String title, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Image.network(imagePath, fit: BoxFit.cover),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
      ),
    );
  }
}