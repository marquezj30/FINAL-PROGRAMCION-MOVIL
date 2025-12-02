// lib/viewmodels/user_view_model.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserViewModel extends ChangeNotifier {
  final List<User> _usuarios = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _uid;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _contactosSub;

  List<User> get usuarios => List.unmodifiable(_usuarios);

  void setUser(String uid) {
    if (_uid == uid) return;
    _uid = uid;

    _contactosSub?.cancel();
    _usuarios.clear();
    notifyListeners();

    final ref = _db.collection("users").doc(uid).collection("contacts");

    _contactosSub = ref.snapshots().listen((snapshot) {
      _usuarios
        ..clear()
        ..addAll(snapshot.docs.map((doc) => User.fromMap(doc.id, doc.data())));
      notifyListeners();
    });
  }

  Future<void> agregarUsuario(User usuario) async {
    if (_uid == null) return;
    final ref = _db.collection("users").doc(_uid).collection("contacts");
    await ref.add(usuario.toMap());
  }

  Future<void> editarUsuario(int index, User usuario) async {
    if (_uid == null) return;

    final id = _usuarios[index].id;
    if (id == null) return;

    final ref = _db.collection("users").doc(_uid).collection("contacts").doc(id);
    await ref.update(usuario.toMap());
  }

  Future<void> eliminarUsuario(int index) async {
    if (_uid == null) return;

    final id = _usuarios[index].id;
    if (id == null) return;

    final ref = _db.collection("users").doc(_uid).collection("contacts").doc(id);
    await ref.delete();
  }

  void logout() {
    _uid = null;
    _contactosSub?.cancel();
    _contactosSub = null;
    _usuarios.clear();
    notifyListeners();
  }

}
