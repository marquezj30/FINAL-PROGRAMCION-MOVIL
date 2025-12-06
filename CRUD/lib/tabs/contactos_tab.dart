import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_view_model.dart';
import '../../models/user.dart';
import '../views/user_form_screen.dart';
import '../widgets/qr_dialogo.dart';

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

    // Filtrado de contactos por buscador
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

        // Lista de Contactos
        Expanded(
          child: contactos.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.perm_contact_calendar_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text("No se encontraron contactos", style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          )
              : ListView.builder(
            itemCount: contactos.length,
            itemBuilder: (context, index) {
              final user = contactos[index];

              // 1. OBTENER COLOR SEGÚN EL GRUPO AL QUE PERTENECE EL CONTACTO
              final colorGrupo = _getColorForGroup(user.grupo);

              return Card(
                elevation: 2,
                shadowColor: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Margen externo
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bordes redondos
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Padding interno

                  // 2. AVATAR (Círculo) CON COLOR DEL GRUPO
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: colorGrupo.withOpacity(0.1), // Fondo suave
                    foregroundColor: colorGrupo, // Letra fuerte
                    child: Text(
                      user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  title: Text(
                    '${user.nombre} ${user.apellido}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  subtitle: Text(
                    user.telefono,
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  // 3. BOTONES A LA DERECHA (QR y Estado)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón QR (Ahora toma el color del grupo también)
                      IconButton(
                        icon: Icon(Icons.qr_code_2, color: colorGrupo),
                        tooltip: 'Compartir contacto',
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => QrDialog(user: user)
                          );
                        },
                      ),

                      // Indicador de bloqueo o flecha
                      user.bloqueado
                          ? const Icon(Icons.block, color: Colors.red)
                          : const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),

                  // Acción al tocar la tarjeta (Editar)
                  onTap: () async {
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

  // Lógica de colores al final de la clase
  Color _getColorForGroup(String grupo) {
    switch (grupo) {
      case 'Familia': return Colors.pinkAccent;
      case 'Amigos': return Colors.orange;
      case 'Trabajo': return Colors.indigo;
      default: return Colors.teal;
    }
  }
}