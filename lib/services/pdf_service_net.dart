import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'file_handle_api.dart';

class PdfApi {
  Future<Uint8List> _fetchImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching image: $e');
      // Return a placeholder image or throw
      throw Exception('Failed to load image: $e');
    }
  }

  Future<File> generate(
    Map<String, dynamic> studentData,
    String frontImagePath,
    String upperImagePath,
    String lowerImagePath,
    Map<String, dynamic> teethData,
  ) async {
    // Load fonts
    final robotoRegular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final robotoBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

    // Create PDF document
    final pdf = pw.Document();

    // Fetch dental images
    List<Uint8List> dentalImages = await Future.wait([
      if (frontImagePath.isNotEmpty) _fetchImageBytes(frontImagePath),
      if (upperImagePath.isNotEmpty) _fetchImageBytes(upperImagePath),
      if (lowerImagePath.isNotEmpty) _fetchImageBytes(lowerImagePath),
    ]);

    // Process teeth data
    List<Map<String, dynamic>> teethList = [];
    teethData.forEach((key, value) {
      print(value);
      if (value is Map) {
        teethList.add({
          'toothId': key,
          'description': value['disease_name'] ?? 'No disease specified',
          'imagePath': value['tooth_image_path'] ?? '',
          'treatmentPlan': value['treatment_plan'] ?? 'No treatment plan',
        });
      }
    });
    List<List<Map<String, dynamic>>> teethChunks = chunkList(teethList, 4);

    // Fetch teeth images
    List<Uint8List?> teethImages = await Future.wait(
      teethList.map((tooth) async {
        if (tooth['imagePath']?.isNotEmpty == true) {
          try {
            return await _fetchImageBytes(tooth['imagePath']);
          } catch (e) {
            print('Error loading tooth image: $e');
            return null;
          }
        }
        return null;
      }),
    );

    // Create PDF page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Center(
              child: pw.Text(
                'Student Dental Report',
                style: pw.TextStyle(fontSize: 20, font: robotoBold),
              ),
            ),
            pw.SizedBox(height: 20),

            // Student Information Table
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                _buildTableRow(
                    'Name', studentData['full_name'] ?? '', robotoRegular),
                _buildTableRow(
                    'Gender', studentData['gender'] ?? '', robotoRegular),
                _buildTableRow(
                    'Age', studentData['age']?.toString() ?? '', robotoRegular),
                _buildTableRow('Blood Group', studentData['blood_group'] ?? '',
                    robotoRegular),
              ],
            ),
            pw.SizedBox(height: 20),

            // Dental Images Section
            if (dentalImages.isNotEmpty) ...[
              pw.Text('Teeth Images',
                  style: pw.TextStyle(fontSize: 16, font: robotoBold)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  for (var imageBytes in dentalImages)
                    pw.Expanded(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Image(pw.MemoryImage(imageBytes),
                            height: 100, width: 100, fit: pw.BoxFit.cover
                            // fit: pw.BoxFit.contain,
                            ),
                      ),
                    ),
                ],
              ),
            ],
            pw.SizedBox(height: 20),

            pw.SizedBox(height: 15),
            pw.Text('Teeth Information',
                style: pw.TextStyle(fontSize: 14, font: robotoBold)),
            for (var chunk in teethChunks)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: chunk.map((tooth) {
                  return pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 8),
                        pw.Container(
                          width: 100,
                          height: 100,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(),
                          ),
                          child: pw.Image(
                            pw.MemoryImage(
                                teethImages[teethList.indexOf(tooth)]!),
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                        pw.Text('Tooth: ${tooth['toothId']}',
                            style: pw.TextStyle(font: robotoRegular)),
                        pw.Text('Description: ${tooth['description']}',
                            style: pw.TextStyle(font: robotoRegular)),
                        pw.Text('Treatment Plan: ${tooth['treatmentPlan']}',
                            style: pw.TextStyle(font: robotoRegular)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            pw.SizedBox(height: 20),
          ],
        ),
      ),
    );

    // Save and return the PDF file
    return FileHandleApi.saveDocument(
      name: '${studentData['full_name']} report.pdf',
      pdf: pdf,
    );
  }

  pw.TableRow _buildTableRow(String label, String value, pw.Font font) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(label, style: pw.TextStyle(font: font)),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(5),
          child: pw.Text(value, style: pw.TextStyle(font: font)),
        ),
      ],
    );
  }
}

List<List<Map<String, dynamic>>> chunkList(
    List<Map<String, dynamic>> list, int chunkSize) {
  List<List<Map<String, dynamic>>> chunks = [];
  for (var i = 0; i < list.length; i += chunkSize) {
    chunks.add(list.sublist(
        i, i + chunkSize > list.length ? list.length : i + chunkSize));
  }
  return chunks;
}
