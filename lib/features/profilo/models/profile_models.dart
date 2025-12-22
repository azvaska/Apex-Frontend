import 'package:flutter/material.dart';

enum RiskLevel {
  low,
  medium,
  high,
}

enum RiskCategory {
  avalanches,
  landslides,
  severeWeather,
  rivers,
}

extension RiskLevelX on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Rischio basso';
      case RiskLevel.medium:
        return 'Rischio medio';
      case RiskLevel.high:
        return 'Rischio alto';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.low:
        return const Color(0xFF2EBC7A);
      case RiskLevel.medium:
        return const Color(0xFFF29D38);
      case RiskLevel.high:
        return const Color(0xFFE94251);
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.low:
        return Icons.check_circle_rounded;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
        return Icons.error_rounded;
    }
  }
}

extension RiskCategoryX on RiskCategory {
  String get label {
    switch (this) {
      case RiskCategory.avalanches:
        return 'Valanghe';
      case RiskCategory.landslides:
        return 'Frane';
      case RiskCategory.severeWeather:
        return 'Meteo Avverso';
      case RiskCategory.rivers:
        return 'Fiumi';
    }
  }

  IconData get icon {
    switch (this) {
      case RiskCategory.avalanches:
        return Icons.terrain_outlined;
      case RiskCategory.landslides:
        return Icons.warning_amber_rounded;
      case RiskCategory.severeWeather:
        return Icons.cloudy_snowing;
      case RiskCategory.rivers:
        return Icons.water_rounded;
    }
  }

  Color get color {
    switch (this) {
      case RiskCategory.avalanches:
        return const Color(0xFF4A5568);
      case RiskCategory.landslides:
        return const Color(0xFF2F7BF6);
      case RiskCategory.severeWeather:
        return const Color(0xFF2F7BF6);
      case RiskCategory.rivers:
        return const Color(0xFF4A5568);
    }
  }
}

class MonitoredArea {
  final String name;
  final String category;
  final RiskLevel riskLevel;

  const MonitoredArea({
    required this.name,
    required this.category,
    required this.riskLevel,
  });

  MonitoredArea copyWith({
    String? name,
    String? category,
    RiskLevel? riskLevel,
  }) {
    return MonitoredArea(
      name: name ?? this.name,
      category: category ?? this.category,
      riskLevel: riskLevel ?? this.riskLevel,
    );
  }
}

class ProfileUser {
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;

  const ProfileUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
  });

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  ProfileUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
  }) {
    return ProfileUser(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class AreaOption {
  final String name;
  final String detail;

  const AreaOption({
    required this.name,
    required this.detail,
  });
}

class AddAreaSelection {
  final AreaOption area;
  final Set<RiskCategory> risks;

  const AddAreaSelection({
    required this.area,
    required this.risks,
  });
}
