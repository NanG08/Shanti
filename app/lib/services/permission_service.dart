import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request microphone, camera and location permissions.
  Future<Map<Permission, PermissionStatus>> requestCorePermissions() async {
    final perms = [
      Permission.microphone,
      Permission.camera,
      Permission.locationWhenInUse,
    ];

    final results = await perms.request();
    return results;
  }

  Future<bool> ensureCorePermissions() async {
    final results = await requestCorePermissions();
    // Return true only if all required permissions are granted or limited (platform dependent)
    bool ok = true;
    for (final status in results.values) {
      if (!(status.isGranted || status.isLimited)) {
        ok = false;
        break;
      }
    }
    return ok;
  }
}
