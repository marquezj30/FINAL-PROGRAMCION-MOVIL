import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../tabs/contactos_tab.dart';
import '../tabs/grupos_tab.dart';
import '../tabs/perfil_tab.dart';
import '../models/user.dart';
import 'user_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();

    // Las 3 vistas principales
    final List<Widget> pages = [
      const ContactsTab(),          // Pestaña 0: Lista completa de contactos
      const GroupsTab(),            // Pestaña 1: Lista Mostrada Por grupos
      ProfileTab(email: widget.email), // Pestaña 2: Perfil y Logout
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
        centerTitle: true,
        elevation: 0,
      ),
      body: pages[_currentIndex],

      // SOLO mostramos el botón flotante para crear "Nuevo Contacto" en la pestaña de Contactos
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo'),
        onPressed: () async {
          final nuevoUsuario = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          );
          if (nuevoUsuario != null && nuevoUsuario is User) {
            viewModel.agregarUsuario(nuevoUsuario);
          }
        },
      )
          : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Contactos',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_work_outlined),
            selectedIcon: Icon(Icons.group_work),
            label: 'Grupos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Mis Contactos';
      case 1: return 'Grupos';
      case 2: return 'Mi Perfil';
      default: return 'App';
    }
  }
}