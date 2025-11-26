import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'services/tts_service.dart';
import 'services/ocr_service.dart';

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
		_tts.init();
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
		return Scaffold(
			appBar: AppBar(
				title: const Text('Shanti - Demo'),
			),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: SingleChildScrollView(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							ElevatedButton.icon(
								onPressed: _simulateWake,
								icon: const Icon(Icons.mic),
								label: const Text('Simulate "Shanti" wake'),
							),
							const SizedBox(height: 16),
							TextField(
								controller: _textController,
								decoration: const InputDecoration(
									labelText: 'Text to speak',
									border: OutlineInputBorder(),
								),
								minLines: 1,
								maxLines: 4,
							),
							const SizedBox(height: 8),
							ElevatedButton(
								onPressed: _speakText,
								child: const Text('Speak text (slow & clear)'),
							),
							const SizedBox(height: 16),
							ElevatedButton.icon(
								onPressed: _pickImageAndOcr,
								icon: const Icon(Icons.photo),
								label: const Text('Pick image & OCR'),
							),
							const SizedBox(height: 12),
							const Text('OCR Result:', style: TextStyle(fontWeight: FontWeight.bold)),
							const SizedBox(height: 8),
							Container(
								padding: const EdgeInsets.all(12),
								decoration: BoxDecoration(
									border: Border.all(color: Colors.grey.shade300),
									borderRadius: BorderRadius.circular(6),
								),
								child: Text(_ocrResult.isEmpty ? 'No result yet.' : _ocrResult),
							),
						],
					),
				),
			),
		);
	}
}

