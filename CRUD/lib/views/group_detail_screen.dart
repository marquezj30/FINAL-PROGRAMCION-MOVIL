import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../models/user.dart';
import 'user_form_screen.dart';
import '../widgets/qr_dialogo.dart';

class GroupDetailScreen extends StatelessWidget {
  final String grupo;

  const GroupDetailScreen({super.key, required this.grupo});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();

    // Obtener color del tema según el grupo
    final colorTema = _getColorForGroup(grupo);

    final contactosDelGrupo = viewModel.usuarios
        .where((u) => u.grupo == grupo)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(grupo),
        backgroundColor: colorTema, // La barra toma el color del grupo
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Cabecera visual
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: colorTema,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              '${contactosDelGrupo.length} Contactos',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),

          // Lista de contactos
          Expanded(
            child: contactosDelGrupo.isEmpty
                ? _buildEmptyState(grupo, colorTema)
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contactosDelGrupo.length,
              itemBuilder: (context, index) {
                final user = contactosDelGrupo[index];
                // Buscamos el índice real para editar
                final indiceOriginal = viewModel.usuarios.indexOf(user);

                return Card(
                  elevation: 4,
                  shadowColor: colorTema.withOpacity(0.4), // Sombra con color
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: colorTema.withOpacity(0.1),
                      foregroundColor: colorTema,
                      child: Text(
                        user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    title: Text(
                      '${user.nombre} ${user.apellido}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(user.telefono),
                      ],
                    ),
                    // QR
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.qr_code_2, color: colorTema),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => QrDialog(user: user),
                            );
                          },
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[300]),
                      ],
                    ),

                    onTap: () async {
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String grupo, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: color.withOpacity(0.3)),
          const SizedBox(height: 15),
          Text(
            'Carpeta vacía',
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
          Text(
            'No hay nadie en $grupo',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // Lógica de colores
  Color _getColorForGroup(String grupo) {
    switch (grupo) {
      case 'Familia': return Colors.pinkAccent;
      case 'Amigos': return Colors.orange;
      case 'Trabajo': return Colors.indigo;
      default: return Colors.teal;
    }
  }
}