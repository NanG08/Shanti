// STT service stub — integrate offline STT (Vosk) or platform channels later.
class SttService {
  SttService();

  Future<void> init() async {
    // Initialize offline STT engine here (Vosk or platform-specific)
  }

  Future<String> transcribeFromMic({int timeoutSeconds = 5}) async {
    // Placeholder implementation for milestone 1.
    return 'transcription (stub)';
  }
}
