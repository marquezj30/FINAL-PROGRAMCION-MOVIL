import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_view_model.dart';
import '../models/user.dart';

class UserFormScreen extends StatefulWidget {
  final User? usuario;
  final int? indice;

  const UserFormScreen({super.key, this.usuario, this.indice});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _nombre;
  late String _apellido;
  late String _telefono;
  bool _bloqueado = false;

  // Variables para el grupo
  String _grupo = 'Otros';
  final List<String> _opcionesGrupos = ['Familia', 'Amigos', 'Trabajo', 'Otros'];

  @override
  void initState() {
    super.initState();

    if (widget.usuario != null) {
      // Si estamos editando, cargamos los datos existentes
      _nombre = widget.usuario!.nombre;
      _apellido = widget.usuario!.apellido;
      _telefono = widget.usuario!.telefono;
      _bloqueado = widget.usuario!.bloqueado;
      _grupo = widget.usuario!.grupo; // Cargar el grupo guardado
    } else {
      // Si es nuevo, campos vacíos
      _nombre = '';
      _apellido = '';
      _telefono = '';
      // _grupo ya tiene valor por defecto 'Otros'
    }
  }

  // Iconos para el grupo al que pertenece el contacto
  IconData _getIconForGroup(String grupo) {
    switch (grupo) {
      case 'Familia': return Icons.favorite;
      case 'Amigos': return Icons.people;
      case 'Trabajo': return Icons.work;
      default: return Icons.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario == null
            ? 'Agregar nuevo contacto'
            : 'Editar contacto'),
        // Botón de eliminar opcional en la barra superior
        actions: [
          if (widget.usuario != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmarEliminar,
            )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // NOMBRE
                TextFormField(
                  initialValue: _nombre,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => _nombre = v!,
                ),

                const SizedBox(height: 15),

                // APELLIDO
                TextFormField(
                  initialValue: _apellido,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => _apellido = v!,
                ),

                const SizedBox(height: 15),

                // TELÉFONO
                TextFormField(
                  initialValue: _telefono,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese un teléfono';
                    if (value.length < 6) return 'Número demasiado corto';
                    return null;
                  },
                  onSaved: (v) => _telefono = v!,
                ),

                const SizedBox(height: 20),

                // SELECTOR DE GRUPOS
                DropdownButtonFormField<String>(
                  value: _grupo,
                  decoration: const InputDecoration(
                    labelText: 'Grupo / Etiqueta',
                    border: OutlineInputBorder(),
                  ),
                  items: _opcionesGrupos.map((String categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Row(
                        children: [
                          Icon(_getIconForGroup(categoria), color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(categoria),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _grupo = val!),
                  onSaved: (val) => _grupo = val!,
                ),

                const SizedBox(height: 20),

                // SWITCH BOTON BLOQUEADO
                SwitchListTile(
                  title: const Text('Contacto bloqueado'),
                  value: _bloqueado,
                  onChanged: (v) => setState(() => _bloqueado = v),
                ),

                const SizedBox(height: 30),

                // BOTÓN PARA GUARDAR / ACTUALIZAR
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _guardarContacto,
                    child: Text(widget.usuario == null ? 'Guardar' : 'Actualizar'),
                  ),
                ),

                // BOTÓN ELIMINAR SE MUESTRA CUANDO SE ACTUALIZA UN CONTACTO
                if (widget.usuario != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar Contacto'),
                      onPressed: _confirmarEliminar,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Lógica para Guardar o Actualizar
  void _guardarContacto() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final contacto = User(
        nombre: _nombre,
        apellido: _apellido,
        telefono: _telefono,
        bloqueado: _bloqueado,
        grupo: _grupo,
      );
      Navigator.pop(context, contacto);
    }
  }

  // Lógica para Eliminar con confirmación
  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar contacto?'),
        content: Text('¿Seguro que quieres borrar a $_nombre $_apellido? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Cerrar alerta
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // 1. Borramos usando el ViewModel
              if (widget.indice != null) {
                Provider.of<UserViewModel>(context, listen: false)
                    .eliminarUsuario(widget.indice!);
              }

              // 2. Cerramos la alerta
              Navigator.pop(ctx);

              // 3. Cerramos la pantalla de formulario devolviendo null
              Navigator.pop(context, null);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}