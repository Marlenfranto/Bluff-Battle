import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/providers/user_provider.dart';
import 'package:networking_game/services/qr_service.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _torchOn = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null) return;

    setState(() => _isProcessing = true);

    final qrService = QrService();
    final scannedUserId = qrService.parseQrData(rawValue);

    if (scannedUserId == null) {
      if (mounted) context.showSnackBar('Invalid QR code', isError: true);
      _resetScanner();
      return;
    }

    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == scannedUserId) {
      if (mounted) context.showSnackBar('You can\'t scan yourself!', isError: true);
      _resetScanner();
      return;
    }

    final firestore = ref.read(firestoreServiceProvider);
    final alreadyScanned =
        await firestore.checkIfScanned(currentUserId!, scannedUserId);
    if (alreadyScanned) {
      if (mounted) {
        context.showSnackBar('You\'ve already scanned this person!', isError: true);
      }
      _resetScanner();
      return;
    }

    if (mounted) {
      await _scannerController.stop();
      context.push('/game/$scannedUserId');
    }
    _resetScanner();
  }

  void _resetScanner() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isProcessing = false);
        _scannerController.start();
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isSmallScreen;

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          _ScanOverlay(isProcessing: _isProcessing),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isSmall ? 12 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Flexible(
                      child: Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 16 : 20,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(blurRadius: 10, color: Colors.black54),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Torch not supported on mobile web browsers
                    if (!kIsWeb)
                      IconButton(
                        icon: Icon(
                          _torchOn ? Icons.flash_off : Icons.flash_on,
                          color: _torchOn ? AppColors.accentOrange : Colors.white,
                          size: 22,
                        ),
                        onPressed: () async {
                          await _scannerController.toggleTorch();
                          setState(() => _torchOn = !_torchOn);
                        },
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ),

          // Bottom instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                isSmall ? 20 : 32,
                20,
                isSmall ? 20 : 32,
                isSmall ? 32 : 48,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isProcessing ? 'Processing...' : 'Point at a player\'s QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmall ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The game will start automatically',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isSmall ? 11 : 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  final bool isProcessing;

  const _ScanOverlay({required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scanArea = size.width * 0.65;

    return CustomPaint(
      size: size,
      painter: _ScanOverlayPainter(
        scanArea: scanArea,
        borderColor:
            isProcessing ? AppColors.accentOrange : AppColors.primaryPurple,
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final double scanArea;
  final Color borderColor;

  _ScanOverlayPainter({required this.scanArea, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(
          (size.width - scanArea) / 2,
          (size.height - scanArea) / 2,
        ) &
        Size(scanArea, scanArea);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16))),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    final cornerLength = scanArea * 0.12;
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top left
    canvas.drawLine(rect.topLeft + const Offset(0, 16), rect.topLeft + Offset(cornerLength, 0), paint);
    canvas.drawLine(rect.topLeft + const Offset(16, 0), rect.topLeft + Offset(0, cornerLength), paint);

    // Top right
    canvas.drawLine(rect.topRight + const Offset(0, 16), rect.topRight + Offset(-cornerLength, 0), paint);
    canvas.drawLine(rect.topRight + const Offset(-16, 0), rect.topRight + Offset(0, cornerLength), paint);

    // Bottom left
    canvas.drawLine(rect.bottomLeft + const Offset(0, -16), rect.bottomLeft + Offset(cornerLength, 0), paint);
    canvas.drawLine(rect.bottomLeft + const Offset(16, 0), rect.bottomLeft + Offset(0, -cornerLength), paint);

    // Bottom right
    canvas.drawLine(rect.bottomRight + const Offset(0, -16), rect.bottomRight + Offset(-cornerLength, 0), paint);
    canvas.drawLine(rect.bottomRight + const Offset(-16, 0), rect.bottomRight + Offset(0, -cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      borderColor != oldDelegate.borderColor;
}
