import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// A dialog that opens the camera and returns the scanned barcode as a String.
/// Usage:
///   final result = await showDialog<String>(
///     context: context,
///     builder: (context) => ScanDialog(),
///   );
class ScanDialog extends StatefulWidget {
  const ScanDialog();

  @override
  State<ScanDialog> createState() => _ScanDialogState();
}

class _ScanDialogState extends State<ScanDialog> {
  MobileScannerController controller = MobileScannerController();
  bool _detected = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 300,
        height: 300,
        child: MobileScanner(
          controller: controller,
          onDetect: (capture) {
            if (_detected) return;
            final barcode = capture.barcodes.firstOrNull;
            if (barcode?.rawValue != null) {
              _detected = true;
              Navigator.of(context).pop(barcode!.rawValue);
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
