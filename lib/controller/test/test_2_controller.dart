import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:lottie/lottie.dart';
import 'package:new_dental/View/tests/test_3.dart';
import 'package:new_dental/const.dart';
import 'package:new_dental/services/api_services.dart';
import 'package:new_dental/services/shared_prefs.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

String? _compressBase64Image(String imagePath) {
  try {
    final imageFile = File(imagePath);
    if (!imageFile.existsSync()) return null;

    final imageBytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    final resized = img.copyResize(image, width: 750);
    final compressed = img.encodeJpg(resized, quality: 80);

    return base64Encode(compressed);
  } catch (e) {
    print("Isolate compression error: $e");
    return null;
  }
}

class TestTwoController extends GetxController {
  RxList<String> selectedTeeth = <String>[].obs;
  RxMap<int, TextEditingController> diseaseControllers =
      <int, TextEditingController>{}.obs;
  RxMap<int, String?> imagePaths = <int, String?>{}.obs;
  RxMap<int, bool> isListeningMap = <int, bool>{}.obs;
  late stt.SpeechToText speech;
  int? currentlyListeningTo;
  var userType = ''.obs;
  var clinicId = ''.obs;
  var clinicName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    speech = stt.SpeechToText();
  }

  void loadUserData() async {
    final userData = await SharedPrefs.getUserData();
    clinicId.value = userData['clinic_id'].toString();
    clinicName.value = userData['clinic_name'] ?? '';
    userType.value = userData['user_type'] ?? '';
    print('User Type: ${userType.value}');
  }

  void updateSelectedTeeth(List<String> teeth) {
    selectedTeeth.value = teeth;
    update();
  }

  void updateDisease(int toothId, String disease) {
    diseaseControllers[toothId]!.text = disease;
    update();
  }

  void toggleListening(int toothId) async {
    if (!speech.isAvailable) {
      bool available = await speech.initialize();
      if (!available) {
        Get.snackbar('Error', 'Speech recognition not available.');
        return;
      }
    }
    if (currentlyListeningTo == toothId && speech.isListening) {
      await speech.stop();
      isListeningMap[toothId] = false;
      currentlyListeningTo = null;
      update();
      return;
    }
    if (currentlyListeningTo != null && speech.isListening) {
      await speech.stop();
      isListeningMap[currentlyListeningTo!] = false;
    }
    currentlyListeningTo = toothId;
    isListeningMap[toothId] = true;
    update();

    speech.listen(
      onResult: (result) async {
        if (diseaseControllers[toothId] != null) {
          diseaseControllers[toothId]!.text = result.recognizedWords;
          update();
        }
        if (result.finalResult) {
          await speech.stop();
          isListeningMap[toothId] = false;
          currentlyListeningTo = null;
          update();
        }
      },
      listenMode: stt.ListenMode.confirmation,
      localeId: 'en_IN',
    );
  }

  void updateImagePath(int toothId, String path) {
    imagePaths[toothId] = path;
    update();
  }

  // Future<String?> compressImage(String imagePath) async {
  //   try {
  //     File imageFile = File(imagePath);
  //     if (!imageFile.existsSync()) return null;

  //     Uint8List imageBytes = await imageFile.readAsBytes();
  //     img.Image? decoded = img.decodeImage(imageBytes);
  //     if (decoded == null) return null;

  //     img.Image resized = img.copyResize(decoded, width: 800);
  //     List<int> compressed = img.encodeJpg(resized, quality: 85);

  //     return base64Encode(compressed);
  //   } catch (e) {
  //     print('Compression error: $e');
  //     return null;
  //   }
  // }

  Future<Map<String, dynamic>> getCombinedTeethDataCompressed() async {
    Map<String, dynamic> combinedData = {};

    for (var toothIdStr in selectedTeeth) {
      int id = int.parse(toothIdStr);
      String disease = diseaseControllers[id]?.text ?? 'No Disease';
      String? imagePath = imagePaths[id];

      if (imagePath == null) continue; // Skip if no image

      String? compressedImage = await compressImageInIsolate(imagePath);

      if (compressedImage == null) continue; // Skip if compression fails

      combinedData[toothIdStr] = {
        'disease': disease,
        'imageBase64': compressedImage,
        'toothNumber': id,
      };
    }

    return combinedData;
  }

  Future<String?> compressImageInIsolate(String path) async {
    return await compute(_compressBase64Image, path);
  }

  Future<void> uploadTeethData(Map<String, dynamic> studentInfo) async {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/lottie/loader.json',
                  height: 100, width: 100),
              SizedBox(height: 20),
              Text('Uploading teeth data...',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
      print(userType.value);
    try {
      final dataList = await getCombinedTeethDataCompressed();
      var response = await ApiService.uploadTeethData(
        clinicId.value,
        userType.value == 'clinic'
            ? clinicName.value
            : studentInfo['institute'].toString(),
        userType.value,
        studentInfo['id'].toString(),
        dataList,
      );
      print(response);
      Get.back();

      if (response['status'] == 'success') {
        Get.snackbar('Success', 'Teeth data uploaded successfully',
            backgroundColor: cerulean);
        Get.to(TreatmntPlan(studentInfo: studentInfo),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Unknown error',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
      print('Errorksddsgiu: $e');
    }
  }
}
