import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileController controller;
  const ProfileHeader({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        CircleAvatar(
          radius: 48,
          child: Text(
            controller.initials,
            style: const TextStyle(fontSize: 32),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          controller.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          controller.email,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
