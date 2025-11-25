import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../models/user.dart';
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  final String email;

  const UserListScreen({super.key, required this.email});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String _search = ''; // <-- NUEVO

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();

    //  FILTRAR CONTACTOS
    final contactosFiltrados = viewModel.usuarios.where((user) {
      final query = _search.toLowerCase();
      return user.nombre.toLowerCase().contains(query) ||
          user.apellido.toLowerCase().contains(query) ||
          user.telefono.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido: ${widget.email}'),
      ),

      body: Column(
        children: [
          //  BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, apellido o teléfono',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),

          //  LISTA DE CONTACTOS
          Expanded(
            child: ListView.builder(
              itemCount: contactosFiltrados.length,
              itemBuilder: (context, index) {
                final user = contactosFiltrados[index];

                return Card(
                  child: ListTile(
                    title: Text('${user.nombre} ${user.apellido}'),
                    subtitle: Text(
                        'Tel: ${user.telefono} • ${user.bloqueado ? "Bloqueado" : "No bloqueado"}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final actualizado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserFormScreen(
                                  usuario: user,
                                  indice: index,
                                ),
                              ),
                            );

                            if (actualizado != null && actualizado is User) {
                              viewModel.editarUsuario(index, actualizado);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => viewModel.eliminarUsuario(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final nuevoUsuario = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          );

          if (nuevoUsuario != null && nuevoUsuario is User) {
            viewModel.agregarUsuario(nuevoUsuario);
          }
        },
      ),
    );
  }
}
