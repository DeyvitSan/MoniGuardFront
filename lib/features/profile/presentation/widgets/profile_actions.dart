import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';

class ProfileActions extends StatelessWidget {
  final ProfileController controller;
  const ProfileActions({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
          onPressed: () async {
            await controller.logout();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }
}
