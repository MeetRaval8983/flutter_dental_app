import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeethDataCard extends StatelessWidget {
  final String toothId;
  final Map<String, dynamic> toothData;

  TeethDataCard({required this.toothId, required this.toothData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tooth #$toothId",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                    toothData['disease_name']?.toString() ??
                        "No disease specified",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w500)),
              ],
            ),
            if (toothData['tooth_image_path'] != null) ...[
              SizedBox(height: 8),
              InkWell(
                onTap: () => _showImageDialog(context, "Tooth #$toothId",
                    toothData['tooth_image_path'].toString()),
                child: CachedNetworkImage(
                  imageUrl: toothData['tooth_image_path'].toString(),
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ],
            if (toothData['treatment_plan'] != null) ...[
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    // mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.medical_services, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        "Treatment Plan:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${toothData['treatment_plan']}",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    softWrap: true,
                  ),
                ],
              )
            ],
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
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Close"))
        ],
      ),
    );
  }
}
