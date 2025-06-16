import 'package:get/get.dart';

class PdfGenerationController extends GetxController {
  var isLoading = false.obs;
  var statusMessage = ''.obs;

  // Method to show loading state
  void showLoading() {
    isLoading.value = true;
    statusMessage.value = "Generating PDF...";
  }

  // Method to hide loading state
  void hideLoading() {
    isLoading.value = false;
    statusMessage.value = '';
  }

  // Method to show success message
  void showSuccess(String message) {
    Get.snackbar("Success", message, snackPosition: SnackPosition.BOTTOM);
  }

  // Method to show error message
  void showError(String message) {
    Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
  }
}
