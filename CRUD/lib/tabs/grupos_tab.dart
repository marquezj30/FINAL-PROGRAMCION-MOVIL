import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/user_view_model.dart';
import '../views/group_detail_screen.dart';

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();
    final grupos = ['Familia', 'Amigos', 'Trabajo', 'Otros'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            "Categorías",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: grupos.length,
            itemBuilder: (context, index) {
              final categoria = grupos[index];
              final cantidad = viewModel.usuarios.where((u) => u.grupo == categoria).length;
              final color = _getColorForGroup(categoria);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailScreen(grupo: categoria),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Círculo iconográfico
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(categoria),
                          size: 32,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        categoria,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$cantidad personas',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getColorForGroup(String grupo) {
    switch (grupo) {
      case 'Familia': return Colors.pinkAccent;
      case 'Amigos': return Colors.orange;
      case 'Trabajo': return Colors.indigo;
      default: return Colors.teal;
    }
  }

  IconData _getIcon(String grupo) {
    switch (grupo) {
      case 'Familia': return Icons.favorite_rounded;
      case 'Amigos': return Icons.sentiment_satisfied_alt_rounded;
      case 'Trabajo': return Icons.work_rounded;
      default: return Icons.label_rounded;
    }
  }
}