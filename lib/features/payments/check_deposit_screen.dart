import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../core/constants/colors.dart';

class CheckDepositScreen extends StatefulWidget {
  const CheckDepositScreen({super.key});

  @override
  State<CheckDepositScreen> createState() => _CheckDepositScreenState();
}

class _CheckDepositScreenState extends State<CheckDepositScreen> {
  CameraController? _controller;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isCameraReady = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Check')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Align the front of your check within the frame',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _isCameraReady
                    ? CameraPreview(_controller!)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: ElevatedButton.icon(
              onPressed: _isCameraReady ? () => _captureCheck() : null,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Front'),
            ),
          ),
        ],
      ),
    );
  }

  void _captureCheck() async {
    // In a real app, you would process the image with OCR or send it to a server
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image captured! Processing...')),
    );
    Navigator.pop(context);
  }
}
