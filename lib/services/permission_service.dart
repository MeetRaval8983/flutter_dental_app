import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request all necessary permissions
  static Future<bool> requestAllPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.photos, // iOS only
      Permission.storage, // Android only
      Permission.accessMediaLocation, // Optional
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted) {
      print("One or more permissions denied.");
    }

    return allGranted;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Request gallery/photos permission
  static Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }
static Future<bool> requestCsvFilePermission() async {
    final status = await Permission.storage.status;

    if (status.isGranted) {
      return true; // ✅ Already granted
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings(); // ❗ Open settings if permanently denied
      return false;
    }

    final result = await Permission.storage.request();
    return result.isGranted;
  }
  /// ✅ New: Request Camera + Gallery/Storage together
static Future<bool> requestMicPermWithHandling() async {
  final micStatus = await Permission.microphone.status;

  if (micStatus.isGranted) return true;

  if (micStatus.isPermanentlyDenied) {
    openAppSettings(); // Or show a dialog
    return false;
  }

  final result = await Permission.microphone.request();
  return result.isGranted;
}


  /// ✅ New: Request Camera + Gallery/Storage together
  static Future<bool> requestCameraAndGalleryPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final photosStatus = await Permission.photos.status; // iOS
    final storageStatus = await Permission.storage.status; // Android

    if (cameraStatus.isGranted && (photosStatus.isGranted || storageStatus.isGranted)) {
      return true;
    }

    final result = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();

    return result[Permission.camera]!.isGranted &&
        (result[Permission.photos]?.isGranted ?? false || result[Permission.storage]!.isGranted);
  }
  
}
