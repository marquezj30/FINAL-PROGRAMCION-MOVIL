import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    if (widget.usuario != null) {
      _nombre = widget.usuario!.nombre;
      _apellido = widget.usuario!.apellido;
      _telefono = widget.usuario!.telefono;
      _bloqueado = widget.usuario!.bloqueado;
    } else {
      _nombre = '';
      _apellido = '';
      _telefono = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario == null
            ? 'Agregar nuevo contacto'
            : 'Editar contacto'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // NOMBRE
              TextFormField(
                initialValue: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese un nombre válido' : null,
                onSaved: (value) => _nombre = value!,
              ),

              const SizedBox(height: 15),

              // APELLIDO
              TextFormField(
                initialValue: _apellido,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese un apellido válido' : null,
                onSaved: (value) => _apellido = value!,
              ),

              const SizedBox(height: 15),

              // TELÉFONO
              TextFormField(
                initialValue: _telefono,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un teléfono válido';
                  }
                  if (value.length < 6) {
                    return 'Número demasiado corto';
                  }
                  return null;
                },
                onSaved: (value) => _telefono = value!,
              ),

              const SizedBox(height: 20),

              // CONTACTO BLOQUEADO
              SwitchListTile(
                title: const Text('Contacto bloqueado'),
                value: _bloqueado,
                onChanged: (value) => setState(() => _bloqueado = value),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final contacto = User(
                      nombre: _nombre,
                      apellido: _apellido,
                      telefono: _telefono,
                      bloqueado: _bloqueado,
                    );

                    Navigator.pop(context, contacto);
                  }
                },
                child: Text(widget.usuario == null ? 'Guardar' : 'Actualizar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
