// lib/views/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../viewmodels/user_view_model.dart';
import 'user_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Seleccionar cuenta Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 2. Obtener credenciales
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Autenticar con Firebase
      final fb.UserCredential userCredential =
      await fb.FirebaseAuth.instance.signInWithCredential(credential);

      final fb.User? user = userCredential.user;

      if (!mounted || user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 4. Conectar UserViewModel a Firestore
      context.read<UserViewModel>().setUser(user.uid);

      // 5. Navegar a la lista de contactos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserListScreen(email: user.email ?? "Sin correo"),
        ),
      );
    } catch (e) {
      setState(() {
        _error = "Error al iniciar sesión: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicia sesión para ingresar")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Agenda de contactos",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : OutlinedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Continuar con Google"),
                onPressed: _signInWithGoogle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
