import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../models/user.dart';
import 'user_form_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final String grupo;

  const GroupDetailScreen({super.key, required this.grupo});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel para que la lista se actualice si editas/borras
    final viewModel = context.watch<UserViewModel>();

    // FILTRO MÁGICO: Solo mostramos los usuarios cuyo grupo coincide con el seleccionado
    final contactosDelGrupo = viewModel.usuarios
        .where((u) => u.grupo == grupo)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(grupo), // Título: "Familia", "Trabajo", etc.
        centerTitle: true,
      ),
      body: contactosDelGrupo.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              'No hay contactos en "$grupo"',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: contactosDelGrupo.length,
        itemBuilder: (context, index) {
          final user = contactosDelGrupo[index];

          // Necesitamos el índice original para editar/borrar correctamente
          // del ViewModel principal, no de esta lista filtrada.
          final indiceOriginal = viewModel.usuarios.indexOf(user);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getColorForGroup(grupo),
                foregroundColor: Colors.white,
                child: Text(user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?'),
              ),
              title: Text(
                '${user.nombre} ${user.apellido}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user.telefono),
              trailing: const Icon(Icons.edit, color: Colors.grey, size: 20),
              onTap: () async {
                // Permitir editar desde aquí también
                final actualizado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserFormScreen(usuario: user, indice: indiceOriginal),
                  ),
                );
                if (actualizado != null && actualizado is User) {
                  viewModel.editarUsuario(indiceOriginal, actualizado);
                }
              },
            ),
          );
        },
      ),
    );
  }

  // Un pequeño toque de color según el grupo
  Color _getColorForGroup(String grupo) {
    switch (grupo) {
      case 'Familia': return Colors.pinkAccent;
      case 'Amigos': return Colors.orange;
      case 'Trabajo': return Colors.blueAccent;
      default: return Colors.indigo;
    }
  }
}