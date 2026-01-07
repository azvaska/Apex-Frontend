import 'package:apex/shared/api/api_client.dart';

class AlertPreference {
  final String id;
  final String areaId;
  final String areaName;
  final int avalancheThreshold;
  final bool flood;
  final bool storm;
  final bool landslide;
  final bool enabled;

  AlertPreference({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.avalancheThreshold,
    required this.flood,
    required this.storm,
    required this.landslide,
    required this.enabled,
  });

  factory AlertPreference.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>? ?? {};
    return AlertPreference(
      id: json['id'] as String,
      areaId: json['areaId'] as String,
      areaName: area['name'] as String? ?? '',
      avalancheThreshold: (json['avalancheThreshold'] as num?)?.toInt() ?? 0,
      flood: json['flood'] as bool? ?? false,
      storm: json['storm'] as bool? ?? false,
      landslide: json['landslide'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class AreaSummary {
  final String id;
  final String name;

  const AreaSummary({required this.id, required this.name});

  factory AreaSummary.fromJson(Map<String, dynamic> json) {
    return AreaSummary(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class MonitoringRepository {
  final ApiClient _client;

  MonitoringRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<AlertPreference>> fetchPreferences() async {
    final response = await _client.getJson('/alerts/preferences');
    final data = response as List<dynamic>;
    return data
        .map((item) => AlertPreference.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AlertPreference> createPreference({
    required String areaId,
    required int avalancheThreshold,
    required bool flood,
    required bool storm,
    required bool landslide,
  }) async {
    final response = await _client.postJson(
      '/alerts/preferences',
      body: {
        'areaId': areaId,
        'avalancheThreshold': avalancheThreshold,
        'flood': flood,
        'storm': storm,
        'landslide': landslide,
      },
    );
    return AlertPreference.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deletePreference(String preferenceId) async {
    await _client.deleteJson('/alerts/preferences/$preferenceId');
  }

  Future<List<AreaSummary>> fetchAreas({int page = 1, int limit = 50}) async {
    final response = await _client.getJson(
      '/areas-of-interest',
      query: {
        'page': '$page',
        'limit': '$limit',
      },
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((item) => AreaSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
