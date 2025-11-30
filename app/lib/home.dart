import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'services/tts_service.dart';
import 'services/ocr_service.dart';
import 'services/permission_service.dart';

class VoiceHome extends StatefulWidget {
  const VoiceHome({super.key});

  @override
  State<VoiceHome> createState() => _VoiceHomeState();
}

class _VoiceHomeState extends State<VoiceHome> with TickerProviderStateMixin {
  final TtsService _tts = TtsService();
  final OcrService _ocr = OcrService();
  final TextEditingController _textController = TextEditingController();
  String _ocrResult = '';
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isOnline = false;
  String _transcribedText = '';
  String _listeningStatus = 'Tap to speak';
  late AnimationController _pulseController;
  late AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  Future<void> _initializeServices() async {
    final permService = PermissionService();
    final ok = await permService.ensureCorePermissions();
    await _tts.init();
    if (!ok) {
      await _tts.speakSlowClear('Some permissions were not granted. Please enable microphone, camera and location in app settings for full functionality.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Permissions needed for full functionality',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF8B7355),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _ocr.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  Future<void> _simulateWake() async {
    if (_isListening) return; // Prevent multiple activations
    
    setState(() {
      _isListening = true;
      _listeningStatus = 'Initializing...';
      _transcribedText = '';
    });
    
    _pulseController.forward(from: 0);
    
    // Wake response
    await _tts.speakSlowClear('Shanti here. How can I help you?');
    
    if (!mounted) return;
    
    setState(() => _listeningStatus = 'Listening... Speak now');
    
    // Simulate listening period with countdown
    for (int i = 5; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _listeningStatus = 'Listening... $i seconds');
    }
    
    if (!mounted) return;
    
    setState(() {
      _isListening = false;
      _isProcessing = true;
      _listeningStatus = 'Processing speech...';
    });
    
    // Simulate speech-to-text processing
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    // Simulated transcription - replace with actual STT
    final sampleCommands = [
      'Read the text on my medicine bottle',
      'What time is it',
      'Call my daughter',
      'Read my messages',
      'What\'s the weather today',
    ];
    
    final randomCommand = sampleCommands[DateTime.now().second % sampleCommands.length];
    
    setState(() {
      _transcribedText = randomCommand;
      _isProcessing = false;
      _listeningStatus = 'Processing command...';
    });
    
    // Respond to the command
    await _tts.speakSlowClear('You said: $randomCommand');
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Process the command
    await _processCommand(randomCommand);
    
    if (mounted) {
      setState(() {
        _listeningStatus = 'Tap to speak';
        _transcribedText = '';
      });
    }
  }
  
  Future<void> _processCommand(String command) async {
    final lowerCommand = command.toLowerCase();
    
    if (lowerCommand.contains('read') && lowerCommand.contains('text')) {
      await _tts.speakSlowClear('Opening camera to capture text.');
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _capturePhotoAndOcr();
      }
    } else if (lowerCommand.contains('time')) {
      final now = DateTime.now();
      final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      await _tts.speakSlowClear('The time is $timeStr');
    } else if (lowerCommand.contains('weather')) {
      await _tts.speakSlowClear('Let me check the weather for you.');
      await Future.delayed(const Duration(milliseconds: 800));
      await _tts.speakSlowClear('It is currently 27 degrees and partly cloudy.');
    } else if (lowerCommand.contains('call')) {
      await _tts.speakSlowClear('Calling your emergency contact.');
    } else if (lowerCommand.contains('message')) {
      await _tts.speakSlowClear('You have no new messages.');
    } else {
      await _tts.speakSlowClear('I heard your command. This feature is coming soon.');
    }
  }
  
  Future<void> _startContinuousListening() async {
    if (_isListening) {
      // Stop listening
      setState(() {
        _isListening = false;
        _listeningStatus = 'Tap to speak';
      });
      return;
    }
    
    // Start listening
    setState(() {
      _isListening = true;
      _listeningStatus = 'Say "Shanti" to wake me up';
    });
    
    // Simulate wake word detection
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted && _isListening) {
      await _tts.speakSlowClear('Wake word detected!');
      await _simulateWake();
    }
  }

  Future<void> _speakText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      await _tts.speakSlowClear('Please type or paste text to speak.');
      return;
    }
    await _tts.speakSlowClear(text);
  }

  Future<void> _pickImageAndOcr() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Processing image...', style: TextStyle(fontSize: 16)),
            ],
          ),
          backgroundColor: const Color(0xFF8B7355),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
    
    final file = File(picked.path);
    final text = await _ocr.recognizeTextFromFile(file);
    setState(() => _ocrResult = text);
    
    if (text.trim().isNotEmpty) {
      await _tts.speakSlowClear('I found the following text.');
      await _tts.speakSlowClear(text);
    } else {
      await _tts.speakSlowClear('No text detected in the selected image.');
    }
  }

  Future<void> _capturePhotoAndOcr() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Processing photo...', style: TextStyle(fontSize: 16)),
            ],
          ),
          backgroundColor: const Color(0xFF8B7355),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
    
    final file = File(picked.path);
    final text = await _ocr.recognizeTextFromFile(file);
    setState(() => _ocrResult = text);
    
    if (text.trim().isNotEmpty) {
      await _tts.speakSlowClear('I found the following text.');
      await _tts.speakSlowClear(text);
    } else {
      await _tts.speakSlowClear('No text detected in the photo.');
    }
  }

  Future<void> _showTextInputDialog() async {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: const Color(0xFFF5F5F5),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A574),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_note, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Enter Text to Speak',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D3D3D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _textController,
                  maxLines: 5,
                  autofocus: true,
                  style: const TextStyle(fontSize: 18, color: Color(0xFF3D3D3D)),
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 18, color: Color(0xFF8B7355)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _speakText();
                        },
                        icon: const Icon(Icons.volume_up, size: 20),
                        label: const Text('Speak', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A574),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMenuDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B8573).withOpacity(0.95),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(5, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 40),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                              iconSize: 28,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hi Vaishali',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildMenuItem(Icons.people_outline, 'Manage Users'),
                      _buildMenuItem(Icons.devices_outlined, 'Devices'),
                      _buildMenuItem(Icons.meeting_room_outlined, 'Rooms'),
                      _buildMenuItem(Icons.music_note_outlined, 'Music'),
                      _buildMenuItem(Icons.settings_outlined, 'Settings'),
                      _buildMenuItem(Icons.help_outline, 'Help'),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.white, size: 24),
                                  SizedBox(width: 16),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A574),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D3D3D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _showMenuDrawer,
                    icon: Icon(Icons.menu, color: Colors.grey.shade700),
                    iconSize: 28,
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A574),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Greeting
              const Text(
                'Hi Vaishali',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D3D3D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome to Shanti AI',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 32),

              // Wake word activation orb
              Center(
                child: Column(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Wake Shanti',
                      child: GestureDetector(
                        onTap: _simulateWake,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_pulseController, _breatheController]),
                          builder: (context, child) {
                            final breatheValue = _breatheController.value;
                            return Container(
                              width: 154 + (breatheValue * 8),
                              height: 154 + (breatheValue * 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: _isListening
                                      ? [
                                          const Color(0xFFD4A574),
                                          const Color(0xFFB89068),
                                        ]
                                      : [
                                          const Color(0xFFE8D5C4),
                                          const Color(0xFFD4A574),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4A574).withOpacity(
                                      _isListening ? 0.4 * _pulseController.value : 0.2 + (breatheValue * 0.15),
                                    ),
                                    blurRadius: _isListening ? 40 : 25,
                                    spreadRadius: _isListening ? _pulseController.value * 12 : breatheValue * 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  _isListening ? Icons.graphic_eq : Icons.mic,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        key: ValueKey(_isListening),
                        _isListening ? 'Listening...' : 'Say "Shanti" or tap to activate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _isListening ? const Color(0xFFD4A574) : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Features Section Header
              const Text(
                'Features',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D3D3D),
                ),
              ),
              const SizedBox(height: 20),

              // Feature Cards
              _buildFeatureCard(
                icon: Icons.photo_library_rounded,
                title: 'Read Photo',
                subtitle: 'Pick image from gallery',
                onTap: _pickImageAndOcr,
              ),

              _buildFeatureCard(
                icon: Icons.camera_alt_rounded,
                title: 'Capture & Read',
                subtitle: 'Take photo and read aloud',
                onTap: _capturePhotoAndOcr,
              ),

              _buildFeatureCard(
                icon: Icons.volume_up_rounded,
                title: 'Speak Text',
                subtitle: 'Type text to hear it spoken',
                onTap: _showTextInputDialog,
              ),

              _buildFeatureCard(
                icon: Icons.emergency_rounded,
                title: 'Emergency Alert',
                subtitle: 'Quick emergency assistance',
                onTap: () async {
                  await _tts.speakSlowClear('Emergency help is on the way. Stay calm.');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'Emergency alert activated',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFFE86252),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                  }
                },
                backgroundColor: const Color(0xFFE86252),
              ),

              const SizedBox(height: 24),

              // OCR Result section
              if (_ocrResult.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.text_fields, color: Color(0xFFD4A574), size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Detected Text',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3D3D3D),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.grey.shade600,
                            onPressed: () => setState(() => _ocrResult = ''),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(minHeight: 100, maxHeight: 250),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _ocrResult,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Color(0xFF3D3D3D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _tts.speakSlowClear(_ocrResult),
                          icon: const Icon(Icons.play_arrow_rounded, size: 22),
                          label: const Text('Read Again', style: TextStyle(fontSize: 17)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A574),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}