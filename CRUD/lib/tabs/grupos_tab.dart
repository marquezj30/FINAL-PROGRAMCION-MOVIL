import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_view_model.dart';
import '../../models/user.dart';
import '../views/group_detail_screen.dart';

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();
    final grupos = ['Familia', 'Amigos', 'Trabajo', 'Otros'];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columnas
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: grupos.length,
      itemBuilder: (context, index) {
        final categoria = grupos[index];
        // Contar cuantos hay en este grupo
        final cantidad = viewModel.usuarios
            .where((u) => u.grupo == categoria)
            .length;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupDetailScreen(grupo: categoria),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getIcon(categoria), size: 40, color: Colors.indigo),
                const SizedBox(height: 10),
                Text(
                  categoria,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$cantidad contactos',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIcon(String grupo) {
    switch (grupo) {
      case 'Familia': return Icons.home_filled;
      case 'Amigos': return Icons.sentiment_satisfied_alt;
      case 'Trabajo': return Icons.business_center;
      default: return Icons.category;
    }
  }
}