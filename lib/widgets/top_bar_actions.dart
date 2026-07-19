import 'package:flutter/material.dart';
import '../screens/profile/profile_screen.dart';

class TopBarActions extends StatelessWidget {
  const TopBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
