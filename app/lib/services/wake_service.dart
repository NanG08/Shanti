// Wake-word detection service stub.
// Real deployment should implement a native continuous audio listener
// (Android foreground service) or use a supported SDK (Porcupine/Picovoice)
// with attention to licensing.
class WakeService {
  WakeService();

  Future<void> init() async {
    // load wake-word model and start listener when ready
  }

  /// Simulate the wake-word being detected (for demo purposes)
  Future<void> simulateWake() async {
    // In demo, trigger the UI to start listening or respond
  }
}
