import 'package:flutter/material.dart';

import 'package:apex/features/profilo/models/profile_models.dart';
import 'package:apex/features/profilo/presentation/widgets/profile_avatar.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ProfileUser user;
  final VoidCallback onEditProfile;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 136,
            height: 136,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE3F0FF), Color(0xFFD7E7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.transparent,
                  child: ProfileAvatar(
                    imageUrl: user.avatarUrl,
                    size: 128,
                    iconColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName.isEmpty ? 'Il tuo nome' : user.fullName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 210,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: onEditProfile,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Modifica Profilo'),
            ),
          ),
        ],
      ),
    );
  }
}
