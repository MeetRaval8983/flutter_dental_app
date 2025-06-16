import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:new_dental/controller/test/test_2_controller.dart'; // Import TestTwoController

class TreatmentPlanController extends GetxController {
  late stt.SpeechToText speech;

  RxMap<int, TextEditingController> treatmentControllers = <int, TextEditingController>{}.obs;
  RxMap<int, bool> isListeningMap = <int, bool>{}.obs;

  // We'll pull these from TestTwoController
  RxList<String> selectedTeeth = <String>[].obs;
  RxMap<int, String?> imagePaths = <int, String?>{}.obs;
  RxMap<int, String> diseases = <int, String>{}.obs;

  int? currentlyListeningTo;

  @override
  void onInit() {
    super.onInit();
    speech = stt.SpeechToText();
    setupTeethFromTest2(); // Important
  }

  void setupTeethFromTest2() {
    final testTwoController = Get.find<TestTwoController>();

    selectedTeeth.assignAll(testTwoController.selectedTeeth);
    imagePaths.assignAll(testTwoController.imagePaths);
    for (var id in testTwoController.selectedTeeth) {
      int toothId = int.parse(id);
      diseases[toothId] = testTwoController.diseaseControllers[toothId]?.text ?? '';
      treatmentControllers[toothId] = TextEditingController();
      isListeningMap[toothId] = false;
    }
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
        if (treatmentControllers[toothId] != null) {
          treatmentControllers[toothId]!.text = result.recognizedWords;
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

  Map<String, dynamic> getTreatmentPlanData() {
    Map<String, dynamic> data = {};

    for (var idStr in selectedTeeth) {
      int id = int.parse(idStr);
      String? plan = treatmentControllers[id]?.text.trim();
      if (plan != null && plan.isNotEmpty) {
        data[idStr] = {
          'disease': diseases[id] ?? '',
          'imagePath': imagePaths[id],
          'treatmentPlan': plan,
        };
      }
    }
    return data;
  }
}
