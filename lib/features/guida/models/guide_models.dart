import 'package:flutter/material.dart';

enum ContactKind { emergency, info }

typedef PhoneNumber = String;

class EmergencyContact {
  final String name;
  final String subtitle;
  final PhoneNumber number;
  final ContactKind kind;
  final Color accent;

  const EmergencyContact({
    required this.name,
    required this.subtitle,
    required this.number,
    required this.kind,
    required this.accent,
  });
}

class QuickGuide {
  final String title;
  final String description;
  final IconData icon;
  final Color tint;

  const QuickGuide({
    required this.title,
    required this.description,
    required this.icon,
    required this.tint,
  });
}
