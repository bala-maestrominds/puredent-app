import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/models/appointment.dart';
import '../../core/services/api_client.dart';
import '../../core/services/appointments_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';

/// Full-screen QR scanner for reception check-in: scans the QR code printed
/// on a patient's appointment ticket, verifies it against the backend
/// (`POST /api/appointments/verify`), shows the appointment details, and lets
/// the admin confirm check-in (`POST /api/appointments/:id/checkin`).
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

enum _ScanState { scanning, verifying, result, checkingIn, checkedIn }

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  _ScanState _state = _ScanState.scanning;
  Appointment? _appointment;
  String? _error;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_state != _ScanState.scanning) return;
    final raw = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (raw == null) return;

    Map<String, dynamic>? payload;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) payload = decoded;
    } catch (_) {
      // Not JSON -- not one of our tickets.
    }

    if (payload == null || payload['code'] == null || payload['token'] == null) {
      setState(() {
        _state = _ScanState.result;
        _error = "That QR code isn't a PureDent appointment ticket.";
      });
      return;
    }

    setState(() => _state = _ScanState.verifying);

    try {
      final appointment = await AppointmentsService.instance.verify(
        code: payload['code'].toString(),
        token: payload['token'].toString(),
      );
      if (!mounted) return;
      setState(() {
        _appointment = appointment;
        _state = _ScanState.result;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _ScanState.result;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _ScanState.result;
        _error = 'Could not verify this code: $e';
      });
    }
  }

  Future<void> _confirmCheckIn() async {
    final appointment = _appointment;
    if (appointment == null) return;

    setState(() => _state = _ScanState.checkingIn);
    try {
      final updated = await AppointmentsService.instance.checkIn(appointment.id);
      if (!mounted) return;
      setState(() {
        _appointment = updated;
        _state = _ScanState.checkedIn;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _ScanState.result;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _ScanState.result;
        _error = 'Check-in failed: $e';
      });
    }
  }

  void _scanAgain() {
    setState(() {
      _state = _ScanState.scanning;
      _appointment = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Dim overlay with a cut-out scan frame.
          IgnorePointer(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(active: _state == _ScanState.scanning),
              child: const SizedBox.expand(),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Scan Patient QR',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  _RoundIconButton(
                    icon: _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    onTap: () {
                      _controller.toggleTorch();
                      setState(() => _torchOn = !_torchOn);
                    },
                  ),
                ],
              ),
            ),
          ),

          if (_state == _ScanState.scanning)
            const Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Text(
                'Point the camera at the QR code on the\npatient\'s appointment ticket',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ),

          if (_state == _ScanState.verifying)
            const _CenteredCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 14),
                  Text('Verifying appointment...', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          if (_state == _ScanState.result || _state == _ScanState.checkingIn || _state == _ScanState.checkedIn)
            _ResultSheet(
              appointment: _appointment,
              error: _error,
              isCheckingIn: _state == _ScanState.checkingIn,
              isCheckedIn: _state == _ScanState.checkedIn,
              onConfirm: _confirmCheckIn,
              onScanAgain: _scanAgain,
              onClose: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CenteredCard extends StatelessWidget {
  final Widget child;
  const _CenteredCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: child,
      ),
    );
  }
}

/// Draws a dim scrim over the whole preview with a clear square cut out in
/// the middle, plus rounded corner brackets -- the standard "scan frame" look.
class _ScannerOverlayPainter extends CustomPainter {
  final bool active;
  const _ScannerOverlayPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final frameSize = size.width * 0.7;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 30),
      width: frameSize,
      height: frameSize,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    final scrimPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(scrimPath, Paint()..color = Colors.black.withValues(alpha: 0.55));

    if (!active) return;

    final borderPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLen = 26.0;
    void corner(Offset a, Offset b, Offset c) {
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy);
      canvas.drawPath(path, borderPaint);
    }

    final l = rect.left, t = rect.top, r = rect.right, b = rect.bottom;
    corner(Offset(l, t + cornerLen), Offset(l, t), Offset(l + cornerLen, t));
    corner(Offset(r - cornerLen, t), Offset(r, t), Offset(r, t + cornerLen));
    corner(Offset(l, b - cornerLen), Offset(l, b), Offset(l + cornerLen, b));
    corner(Offset(r - cornerLen, b), Offset(r, b), Offset(r, b - cornerLen));
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) => oldDelegate.active != active;
}

class _ResultSheet extends StatelessWidget {
  final Appointment? appointment;
  final String? error;
  final bool isCheckingIn;
  final bool isCheckedIn;
  final VoidCallback onConfirm;
  final VoidCallback onScanAgain;
  final VoidCallback onClose;

  const _ResultSheet({
    required this.appointment,
    required this.error,
    required this.isCheckingIn,
    required this.isCheckedIn,
    required this.onConfirm,
    required this.onScanAgain,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: error != null ? _buildError(context) : _buildAppointment(context),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.errorContainer.withValues(alpha: 0.5), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: AppColors.error),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verification failed', style: Theme.of(context).textTheme.titleMedium),
                  Text(error!, style: const TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onScanAgain,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: const Text('Scan Again'),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointment(BuildContext context) {
    final a = appointment!;
    final alreadyCheckedIn = a.checkInStatus == 'checked_in' && !isCheckedIn;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(999)),
          ),
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                a.patientName.isNotEmpty ? a.patientName[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.patientName, style: Theme.of(context).textTheme.titleMedium),
                  Text('#${a.appointmentCode}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            if (isCheckedIn || alreadyCheckedIn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.secondaryContainer.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
                child: const Text('Checked In', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _row(Icons.medical_services_outlined, a.serviceName),
              const SizedBox(height: 8),
              _row(Icons.person_outline_rounded, '${a.doctorName}${a.doctorSpecialty.isNotEmpty ? ' · ${a.doctorSpecialty}' : ''}'),
              const SizedBox(height: 8),
              _row(Icons.schedule_rounded, '${a.date} · ${a.time}'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (isCheckedIn)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onScanAgain,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: const Text('Scan Next Patient'),
            ),
          )
        else if (alreadyCheckedIn)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: onClose, child: const Text('Close')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onScanAgain,
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: const Text('Scan Next'),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: onScanAgain, child: const Text('Rescan')),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isCheckingIn ? null : onConfirm,
                  icon: isCheckingIn
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text(isCheckingIn ? 'Checking In...' : 'Confirm Check-In'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
