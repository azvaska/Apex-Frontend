import 'dart:convert';

import 'package:flutter/material.dart';

class ReportCoverImage extends StatelessWidget {
  final String? url;

  const ReportCoverImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (url == null || url!.isEmpty) {
      return Container(
        color: theme.colorScheme.surfaceVariant,
        child: const Icon(Icons.image, size: 48),
      );
    }
    if (url!.startsWith('data:image')) {
      final data = url!.split(',').last;
      final bytes = base64Decode(data);
      return Image.memory(bytes, fit: BoxFit.cover);
    }
    return Image.network(url!, fit: BoxFit.cover);
  }
}
