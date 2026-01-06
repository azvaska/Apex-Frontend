import 'dart:convert';

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Color iconColor;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Icon(Icons.person_outline, color: iconColor, size: size * 0.45);
    }
    if (imageUrl!.startsWith('data:image')) {
      final data = imageUrl!.split(',').last;
      final bytes = base64Decode(data);
      return ClipOval(
        child: Image.memory(bytes, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return ClipOval(
      child: Image.network(imageUrl!, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
