import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../viewmodels/user_view_model.dart';
import '../views/login_screen.dart';
import '../models/user.dart';
import '../widgets/qr_dialogo.dart';

class ProfileTab extends StatelessWidget {
  final String email;
  const ProfileTab({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.indigo.shade100,
                child: const Icon(Icons.person, size: 50, color: Colors.indigo),
              ),
              const SizedBox(height: 20),
              Text(
                email,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // BOTÓN COMPARTIR MI PERFIL
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Compartir mi contacto (QR)'),
                  onPressed: () => _showMyQrDialog(context),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // BOTON CERRAR SESIÓN
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  onPressed: () async {
                    final google = GoogleSignIn();
                    try {
                      await google.signOut();
                      await google.disconnect();
                    } catch (_) {}
                    await fb.FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      context.read<UserViewModel>().logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMyQrDialog(BuildContext context) {
    // Controladores para capturar tus datos temporalmente
    final nombreController = TextEditingController();
    final telefonoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar mi QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tus datos para generar un código que otros puedan escanear.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Tu Nombre Completo',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(
                labelText: 'Tu Teléfono',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nombreController.text.isEmpty || telefonoController.text.isEmpty) return;

              // Creamos un usuario temporal "Yo"
              final miUsuario = User(
                nombre: nombreController.text,
                apellido: '',
                telefono: telefonoController.text,
                bloqueado: false,
                grupo: 'Yo',
              );

              Navigator.pop(context); // Cierra el formulario

              // Muestra el QR
              showDialog(
                context: context,
                builder: (_) => QrDialog(user: miUsuario),
              );
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }
}