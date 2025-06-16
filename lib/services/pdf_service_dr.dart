import 'dart:io';
import 'package:flutter/services.dart';
import 'file_handle_api.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfApiDr {
  Future<File> generate(
    Map<String, dynamic> studentInfo,
    String? frontImagePath,
    String? upperImagePath,
    String? lowerImagePath,
    Map<String, dynamic> teethData,
    // String treatmentDescription,
  ) async {
    final robotoRegular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final robotoBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    // Load images from file paths
    final frontImageFile = File(frontImagePath ?? '');
    final lowerImageFile = File(lowerImagePath ?? '');
    final upperImageFile = File(upperImagePath ?? '');

    final frontImage = frontImagePath != null ? await frontImageFile.readAsBytes() : Uint8List(0);
    final lowerImage = lowerImagePath != null ? await lowerImageFile.readAsBytes() : Uint8List(0);
    final upperImage = upperImagePath != null ? await upperImageFile.readAsBytes() : Uint8List(0);

    final pdf = pw.Document();

    // Convert teethData Map<String, dynamic> into a List<Map<String, dynamic>>
    List<Map<String, dynamic>> teethDataList = [];

    teethData.forEach((key, value) {
      teethDataList.add({
        'toothId': key,
        'disease': value['disease'] ?? 'No Disease',
        'imagePath': value['imagePath'] ?? '',
        'treatmentPlan': value['treatmentPlan'] ?? 'No Treatment Plan',
      });
    });

    // Chunk the teeth data into groups of 4 for easier display in the PDF
    List<List<Map<String, dynamic>>> teethChunks = _chunkList(teethDataList, 4);

    // Create PDF page with student and teeth info
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Title
            pw.Center(
              child: pw.Text('Student Dental Report',
                  style: pw.TextStyle(fontSize: 16, font: robotoBold)),
            ),
            pw.SizedBox(height: 15),

            // Student Information Table
            pw.Padding(
              padding: pw.EdgeInsets.all(0),
              child: pw.Table(
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                },
                border: pw.TableBorder.all(),
                children: [
                  _buildTableRow('Name', studentInfo['full_name'], robotoRegular),
                  _buildTableRow('Email', studentInfo['email'], robotoRegular),
                  _buildTableRow('Blood Group', studentInfo['blood_group'], robotoRegular),
                  _buildTableRow('Gender', studentInfo['gender'], robotoRegular),
                  _buildTableRow('Age', studentInfo['age'], robotoRegular),
                  _buildTableRow('Mobile Number', studentInfo['mobile'], robotoRegular),
                ],
              ),
            ),
            pw.SizedBox(height: 15),

            // Teeth Images
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 0),
              child: pw.Text('Teeth Images',
                  style: pw.TextStyle(fontSize: 14, font: robotoBold)),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageContainer(frontImage, robotoRegular),
                _buildImageContainer(lowerImage, robotoRegular),
                _buildImageContainer(upperImage, robotoRegular),
              ],
            ),
            pw.SizedBox(height: 15),

            // Teeth Information
            pw.Text('Teeth Information', style: pw.TextStyle(fontSize: 14, font: robotoBold)),
            for (var chunk in teethChunks)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: chunk.map((tooth) {
                  return pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 8),
                        tooth['imagePath'] != null && File(tooth['imagePath']).existsSync()
                            ? pw.Container(
                                width: 100,
                                height: 100,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(),
                                ),
                                child: pw.Image(
                                  pw.MemoryImage(
                                      File(tooth['imagePath']).readAsBytesSync()),
                                  fit: pw.BoxFit.cover,
                                ),
                              )
                            : pw.Text("No Image Available"),
                        pw.SizedBox(height: 5),
                        pw.Text('Tooth Number: ${tooth['toothId']}',
                            style: pw.TextStyle(font: robotoRegular)),
                        pw.Text('Clinical Findings: ${tooth['disease']}',
                            style: pw.TextStyle(font: robotoRegular)),
                        pw.Text('Treatment Plan: ${tooth['treatmentPlan']}',
                            style: pw.TextStyle(font: robotoRegular)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 20),

            // // Treatment Description
            // pw.Text('Treatment', style: pw.TextStyle(fontSize: 14, font: robotoBold)),
            // pw.SizedBox(height: 10),
            // pw.Text(treatmentDescription, style: pw.TextStyle(font: robotoRegular)),
          ],
        ),
      ),
    );

    // Save and return the PDF file
    return FileHandleApi.saveDocument(
        name: '${studentInfo['full_name']} report.pdf', pdf: pdf);
  }

  // Helper function to build table rows for student info
  pw.TableRow _buildTableRow(String label, dynamic value, pw.Font font) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text(label, style: pw.TextStyle(font: font)),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(4),
          child: pw.Text('$value', style: pw.TextStyle(font: font)),
        ),
      ],
    );
  }

  // Helper function to create an image container for the PDF
  pw.Widget _buildImageContainer(Uint8List imageData, pw.Font font) {
    return pw.Container(
      child: pw.Image(pw.MemoryImage(imageData), width: 100, height: 100, fit: pw.BoxFit.cover),
      decoration: pw.BoxDecoration(borderRadius: pw.BorderRadius.circular(25)),
    );
  }

  // Helper function to chunk a list into smaller lists of a specified size
  List<List<Map<String, dynamic>>> _chunkList(
      List<Map<String, dynamic>> list, int chunkSize) {
    List<List<Map<String, dynamic>>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}
