import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:susthiram/features/scan/data/gemini_service.dart';
import 'package:susthiram/features/scan/data/scan_repository.dart';
import 'package:susthiram/features/scan/domain/garment_analysis.dart';
import 'package:uuid/uuid.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;

  Future<void> _pickImage(bool isFront, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  void _showSourceSheet(bool isFront) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(isFront, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.white),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(isFront, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _analyzeGarment() async {
    if (_frontImage == null || _backImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      // In a real app, we would use a Provider to get the service
      final service = GeminiService();
      final rawAnalysis = await service.analyzeGarment(
        _frontImage!,
        _backImage!,
      );

      // Add ID and timestamp
      final analysis = GarmentAnalysis(
        id: const Uuid().v4(),
        itemName: rawAnalysis.itemName,
        qualityAssessment: rawAnalysis.qualityAssessment,
        tags: rawAnalysis.tags,
        classification: rawAnalysis.classification,
        score: rawAnalysis.score,
        reasoning: rawAnalysis.reasoning,
        timestamp: DateTime.now(),
      );

      // Save to Firestore
      // TODO: Get actual user ID
      await ScanRepository().addScan(analysis, 'user_123');

      if (mounted) {
        context.push('/results', extra: analysis);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Garment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upload Photos',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We need both front and back views for accurate analysis.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildImageSlot(
                    title: 'Front View',
                    image: _frontImage,
                    onTap: () => _showSourceSheet(true),
                    delay: 200.ms,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSlot(
                    title: 'Back View',
                    image: _backImage,
                    onTap: () => _showSourceSheet(false),
                    delay: 400.ms,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed:
                    (_frontImage != null && _backImage != null && !_isAnalyzing)
                        ? _analyzeGarment
                        : null,
                child:
                    _isAnalyzing
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Analyzing with Gemini...'),
                          ],
                        )
                        : const Text('Analyze Garment'),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlot({
    required String title,
    File? image,
    required VoidCallback onTap,
    required Duration delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      image != null
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white24,
                  width: image != null ? 2 : 1,
                ),
                image:
                    image != null
                        ? DecorationImage(
                          image: FileImage(image),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  image == null
                      ? const Center(
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.white54,
                          size: 32,
                        ),
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).scale();
  }
}
