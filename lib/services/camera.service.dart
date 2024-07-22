import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => this._cameraController;

  InputImageRotation? _cameraRotation;
  InputImageRotation? get cameraRotation => this._cameraRotation;

  String? _imagePath;
  String? get imagePath => this._imagePath;

  Future<void> initialize() async {
    if (_cameraController != null && _cameraController!.value.isInitialized)
      return;

    CameraDescription description = await _getCameraDescription();
    await _setupCameraController(description: description);
    this._cameraRotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
  }

  Future<CameraDescription> _getCameraDescription() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere((CameraDescription camera) =>
        camera.lensDirection == CameraLensDirection.front);
  }

  Future<void> _setupCameraController({
    required CameraDescription description,
  }) async {
    this._cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController?.initialize();
      // Adding a check here to ensure the camera is initialized properly
      if (!_cameraController!.value.isInitialized) {
        throw CameraException('CameraError', 'Camera not initialized properly');
      }
    } catch (e) {
      print("Error initializing camera: $e");
      this._cameraController = null;
    }
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<XFile?> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print('Camera controller not initialized');
      return null;
    }

    try {
      await _cameraController?.stopImageStream();
      XFile? file = await _cameraController?.takePicture();
      _imagePath = file?.path;
      return file;
    } catch (e) {
      print("Error taking picture: $e");
      return null;
    }
  }

  Size getImageSize() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw AssertionError('Camera controller not initialized');
    }
    if (_cameraController!.value.previewSize == null) {
      throw AssertionError('Preview size is null');
    }
    return Size(
      _cameraController!.value.previewSize!.height,
      _cameraController!.value.previewSize!.width,
    );
  }

  dispose() async {
    await this._cameraController?.dispose();
    this._cameraController = null;
  }
}
