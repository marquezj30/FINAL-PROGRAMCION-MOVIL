import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/user.dart';

class QrDialog extends StatelessWidget {
  final User user;

  const QrDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Generamos el formato vCard (Estándar para contactos)
    final vCardData =
    '''BEGIN:VCARD
VERSION:3.0
N:${user.apellido};${user.nombre};;;
FN:${user.nombre} ${user.apellido}
TEL;TYPE=CELL:${user.telefono}
END:VCARD''';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escanear para agregar',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '${user.nombre} ${user.apellido}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Dibujo del QR
            SizedBox(
              height: 220,
              width: 220,
              child: QrImageView(
                data: vCardData,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
                gapless: false,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}