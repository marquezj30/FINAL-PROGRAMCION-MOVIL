import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_view_model.dart';
import '../../models/user.dart';
import '../views/user_form_screen.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();

    // Filtrado
    final contactos = viewModel.usuarios.where((user) {
      final query = _search.toLowerCase();
      return user.nombre.toLowerCase().contains(query) ||
          user.apellido.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Buscador Estilizado
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar contacto...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (val) => setState(() => _search = val),
          ),
        ),

        // Lista
        Expanded(
          child: contactos.isEmpty
              ? const Center(child: Text("No hay contactos"))
              : ListView.builder(
            itemCount: contactos.length,
            itemBuilder: (context, index) {
              final user = contactos[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    foregroundColor: Colors.indigo.shade800,
                    child: Text(user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?'),
                  ),
                  title: Text(
                    '${user.nombre} ${user.apellido}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.telefono),
                  trailing: user.bloqueado
                      ? const Icon(Icons.block, color: Colors.red)
                      : const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () async {
                    // Editar al tocar la tarjeta
                    final actualizado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserFormScreen(usuario: user, indice: index),
                      ),
                    );
                    if (actualizado != null && actualizado is User) {
                      viewModel.editarUsuario(index, actualizado);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}