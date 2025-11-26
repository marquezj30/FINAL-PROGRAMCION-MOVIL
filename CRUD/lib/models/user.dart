
class User {
  String? id;          // id del documento en Firestore
  String nombre;
  String apellido;
  String telefono;
  bool bloqueado;

  User({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.bloqueado,
  });

  // Para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'bloqueado': bloqueado,
    };
  }

  // Para leer desde Firestore
  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      telefono: map['telefono'] ?? '',
      bloqueado: map['bloqueado'] ?? false,
    );
  }
}
