import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../components/loading_infinity.dart';
import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_toggle_button.dart';
import '../../utils/toast_utils.dart';
import 'dart:io'; // For File when displaying captured image

/// Màn hình Camera với 2 chế độ: Chụp ảnh và Quét QR Code
/// User có thể chuyển đổi giữa 2 chế độ bằng toggle button
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Camera mode: true = Photo mode, false = QR Scanner mode
  bool _isPhotoMode = true;

  // Camera controller for photo mode
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  // QR Scanner controller
  MobileScannerController? _qrController;

  // Captured image
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _qrController = MobileScannerController();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0], // Use back camera
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _qrController?.dispose();
    super.dispose();
  }

  void _toggleCameraMode() async {
    // Update UI first
    setState(() {
      _isPhotoMode = !_isPhotoMode;
      _capturedImage = null;
    });

    if (!_isPhotoMode) {
      // Switched TO QR mode - stop camera completely
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        await _cameraController!.dispose();
        _cameraController = null;
        setState(() {
          _isCameraInitialized = false;
        });
      }
    } else {
      // Switched TO Photo mode - reinitialize camera
      await _initializeCamera();
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = photo;
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ToastUtils.showError('${l10n.captureFailed}: $e');
      }
    }
  }

  void _handleQRCodeDetection(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final String? qrData = barcodes.first.rawValue;

      if (qrData != null && qrData.isNotEmpty) {
        // Pause scanner to prevent multiple scans
        _qrController?.stop();

        // Show QR data dialog
        _showQRDataDialog(qrData);
      }
    }
  }

  void _showQRDataDialog(String qrData) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                color: AppColors.success700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.qrCodeDetected,
              style: const TextStyle(color: AppColors.black),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.description,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                qrData,
                style: const TextStyle(fontSize: 14, color: AppColors.gray900),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Resume scanner
              _qrController?.start();
            },
            child: Text(AppLocalizations.of(context)!.scanAgain),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).pop(qrData); // Return to previous screen with QR data
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.success),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          LanguageToggleIconButton(),
          SizedBox(width: 8),
        ],
        title: Text(
          _isPhotoMode ? l10n.camera : l10n.scanQRCode,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera view
          Positioned.fill(
            child: _isPhotoMode ? _buildPhotoMode() : _buildQRScannerMode(),
          ),

          // Mode toggle button (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 20,
            child: _buildModeToggle(),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoMode() {
    if (_capturedImage != null) {
      return Image.file(File(_capturedImage!.path), fit: BoxFit.cover);
    }

    if (!_isCameraInitialized || _cameraController == null) {
      final l10n = AppLocalizations.of(context)!;
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LoadingInfinity(size: 60),
              const SizedBox(height: 16),
              Text(
                l10n.loading,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildQRScannerMode() {
    return Stack(
      children: [
        MobileScanner(
          controller: _qrController,
          onDetect: _handleQRCodeDetection,
        ),
        // Overlay
        Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.brand500, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.scanQRCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            icon: Icons.camera_alt,
            label: AppLocalizations.of(context)!.photo,
            isActive: _isPhotoMode,
            onTap: () {
              if (!_isPhotoMode) _toggleCameraMode();
            },
          ),
          Container(width: 1, height: 24, color: Colors.white.withOpacity(0.3)),
          _buildModeButton(
            icon: Icons.qr_code_scanner,
            label: 'QR',
            isActive: !_isPhotoMode,
            onTap: () {
              if (_isPhotoMode) _toggleCameraMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.brand500 : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.brand500 : Colors.white,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_capturedImage != null && _isPhotoMode) ...[
            // Retake button
            _buildControlButton(
              icon: Icons.refresh,
              label: AppLocalizations.of(context)!.retry,
              onPressed: () {
                setState(() => _capturedImage = null);
              },
            ),
            const SizedBox(width: 20),
            // Confirm button
            _buildControlButton(
              icon: Icons.check,
              label: AppLocalizations.of(context)!.success,
              isPrimary: true,
              onPressed: () {
                Navigator.pop(context, File(_capturedImage!.path));
              },
            ),
          ] else if (_isPhotoMode) ...[
            // Capture button
            GestureDetector(
              onTap: _capturePhoto,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ] else ...[
            // QR Scanner hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.scanQRCode,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.brand500 : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppColors.gray900,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
