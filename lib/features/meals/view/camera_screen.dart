import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

/// Camera screen for taking food photos
class CameraScreen extends StatefulWidget {
  final Function(String) onPhotoTaken;

  const CameraScreen({super.key, required this.onPhotoTaken});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    CameraService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final success = await CameraService.initialize();
      setState(() {
        _isInitialized = success;
        _isLoading = false;
        _error = success ? null : 'Failed to initialize camera';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isInitialized = false;
        _error = 'Camera error: $e';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photoPath = await CameraService.takePhoto();
      if (photoPath != null) {
        widget.onPhotoTaken(photoPath);
        Navigator.pop(context);
      } else {
        _showErrorSnackBar('Failed to take photo');
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await CameraService.switchCamera();
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to switch camera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    try {
      await CameraService.toggleFlash();
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Failed to toggle flash: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
        actions: [
          if (CameraService.cameras != null &&
              CameraService.cameras!.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: Text(
          'Camera not available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(child: CameraService.getCameraPreview()),

        // Flash indicator
        if (CameraService.hasFlash)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                CameraService.flashMode == FlashMode.torch
                    ? Icons.flash_on
                    : Icons.flash_off,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

        // Focus indicator (center)
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: Icon(Icons.camera_alt, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flash toggle
          if (CameraService.hasFlash)
            IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                CameraService.flashMode == FlashMode.torch
                    ? Icons.flash_on
                    : Icons.flash_off,
                color: Colors.white,
                size: 32,
              ),
            )
          else
            const SizedBox(width: 48),

          // Capture button
          GestureDetector(
            onTap: _takePhoto,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Center(
                child: Icon(Icons.camera_alt, color: Colors.black, size: 32),
              ),
            ),
          ),

          // Placeholder for symmetry
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
