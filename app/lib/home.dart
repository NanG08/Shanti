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

class _VoiceHomeState extends State<VoiceHome> {
	final TtsService _tts = TtsService();
	final OcrService _ocr = OcrService();
	final TextEditingController _textController = TextEditingController();
	String _ocrResult = '';

	@override
	void initState() {
		super.initState();
		_initializeServices();
	}

	Future<void> _initializeServices() async {
		final permService = PermissionService();
		final ok = await permService.ensureCorePermissions();
		await _tts.init();
		if (!ok) {
			// Inform the user via TTS and a visual snackbar
			await _tts.speakSlowClear('Some permissions were not granted. Please enable microphone, camera and location in app settings for full functionality.');
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone, Camera or Location permission not granted')));
			}
		}
	}

	@override
	void dispose() {
		_tts.stop();
		_ocr.dispose();
		_textController.dispose();
		super.dispose();
	}

	Future<void> _simulateWake() async {
		await _tts.speakSlowClear('Shanti here. How can I help you? Please speak slowly.');
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

	@override
	Widget build(BuildContext context) {
		final colors = Theme.of(context).colorScheme;
		return Scaffold(
			appBar: AppBar(
				title: Text('Shanti', style: Theme.of(context).textTheme.titleLarge),
				backgroundColor: colors.surface,
			),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							// Status row
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Row(
										children: [
											Container(
												padding: const EdgeInsets.all(8),
												decoration: BoxDecoration(
													color: colors.primary,
													borderRadius: BorderRadius.circular(8),
												),
												child: const Icon(Icons.headset_mic, color: Colors.white, size: 28),
											),
											const SizedBox(width: 12),
											Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text('Voice Assistant', style: Theme.of(context).textTheme.labelLarge),
													const SizedBox(height: 4),
													Text('Tap the circle to wake Shanti', style: Theme.of(context).textTheme.bodyMedium),
												],
											),
										],
									),
									// Online / Offline badge placeholder
									Container(
										padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
										decoration: BoxDecoration(
											color: colors.secondary,
											borderRadius: BorderRadius.circular(12),
										),
										child: Text('Offline', style: TextStyle(color: colors.onSecondary, fontWeight: FontWeight.bold)),
									)
								],
							),

							const SizedBox(height: 18),

							// Big orb / primary action
							Center(
								child: Semantics(
									button: true,
									label: 'Wake Shanti',
									child: GestureDetector(
										onTap: _simulateWake,
										child: Container(
											width: 140,
											height: 140,
											decoration: BoxDecoration(
												shape: BoxShape.circle,
												gradient: RadialGradient(
													colors: [colors.primary, colors.surface],
												),
												boxShadow: [
													BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0,6)),
												],
											),
											child: const Center(
												child: Icon(Icons.mic, size: 56, color: Colors.white),
											),
										),
									),
								),
							),

							const SizedBox(height: 18),

							// Action cards (large)
							Expanded(
								child: GridView.count(
									crossAxisCount: 1,
									childAspectRatio: 4.5,
									mainAxisSpacing: 12,
									physics: const NeverScrollableScrollPhysics(),
									children: [
										ElevatedButton.icon(
											onPressed: _pickImageAndOcr,
											icon: const Icon(Icons.photo, size: 36),
											label: const Text('Read Photo Aloud', style: TextStyle(fontSize: 20)),
											style: ElevatedButton.styleFrom(
												backgroundColor: colors.surface,
												foregroundColor: colors.onSurface,
												padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
												shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
											),
										),

										ElevatedButton.icon(
											onPressed: _speakText,
											icon: const Icon(Icons.volume_up, size: 36),
											label: const Text('Speak Text (clear)', style: TextStyle(fontSize: 20)),
											style: ElevatedButton.styleFrom(
												backgroundColor: colors.surface,
												foregroundColor: colors.onSurface,
												padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
												shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
											),
										),

										ElevatedButton.icon(
											onPressed: () async {
												await _tts.speakSlowClear('Emergency help is on the way.');
												// placeholder for emergency action
											},
											icon: const Icon(Icons.warning_amber_sharp, size: 36),
											label: const Text('Emergency', style: TextStyle(fontSize: 20)),
											style: ElevatedButton.styleFrom(
												backgroundColor: Colors.redAccent,
												foregroundColor: Colors.white,
												padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
												shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
											),
										),
									],
								),
							),

							// OCR result / small controls at bottom
							const SizedBox(height: 8),
							const Divider(color: Colors.white24),
							const SizedBox(height: 8),
							Text('OCR Result', style: Theme.of(context).textTheme.labelLarge),
							const SizedBox(height: 8),
							Container(
								constraints: const BoxConstraints(minHeight: 80, maxHeight: 200),
								padding: const EdgeInsets.all(12),
								decoration: BoxDecoration(
									color: Theme.of(context).colorScheme.surface,
									borderRadius: BorderRadius.circular(10),
								),
								child: SingleChildScrollView(
									child: Text(
										_ocrResult.isEmpty ? 'No text detected yet. Use "Read Photo Aloud" to pick an image.' : _ocrResult,
										style: Theme.of(context).textTheme.bodyLarge,
									),
								),
							),
						],
					),
				),
			),
		);
	}
}

