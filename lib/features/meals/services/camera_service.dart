import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for handling camera operations for meal logging
class CameraService {
  static CameraController? _controller;
  static List<CameraDescription>? _cameras;
  static bool _isInitialized = false;

  /// Initialize camera service
  static Future<bool> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        return false;
      }

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing camera: $e');
      return false;
    }
  }

  /// Get camera controller
  static CameraController? get controller => _controller;

  /// Check if camera is initialized
  static bool get isInitialized => _isInitialized;

  /// Get available cameras
  static List<CameraDescription>? get cameras => _cameras;

  /// Take a photo and save it to temporary directory
  static Future<String?> takePhoto() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'meal_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(tempDir.path, fileName);

      final XFile photo = await _controller!.takePicture();

      // Copy to our desired location
      await photo.saveTo(filePath);

      return filePath;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  /// Dispose camera controller
  static Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
  }

  /// Switch between front and back camera
  static Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      throw Exception('No other camera available');
    }

    final currentCamera = _controller!.description;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentCamera.lensDirection,
    );

    await _controller!.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  /// Get camera preview widget
  static Widget getCameraPreview() {
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: Text(
          'Camera not initialized',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return CameraPreview(_controller!);
  }

  /// Check if flash is available
  static bool get hasFlash => _controller?.value.flashMode != null;

  /// Toggle flash
  static Future<void> toggleFlash() async {
    if (_controller != null && hasFlash) {
      final currentMode = _controller!.value.flashMode;
      final newMode = currentMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off;
      await _controller!.setFlashMode(newMode);
    }
  }

  /// Get current flash mode
  static FlashMode get flashMode =>
      _controller?.value.flashMode ?? FlashMode.off;
}
