import 'package:apex/shared/api/api_client.dart';

class AlertEvent {
  final String id;
  final String areaId;
  final String areaName;
  final int riskIndex;
  final String message;
  final DateTime createdAt;

  AlertEvent({
    required this.id,
    required this.areaId,
    required this.areaName,
    required this.riskIndex,
    required this.message,
    required this.createdAt,
  });

  factory AlertEvent.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>? ?? {};
    return AlertEvent(
      id: json['id'] as String,
      areaId: json['areaId'] as String,
      areaName: area['name'] as String? ?? '',
      riskIndex: (json['riskIndex'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AreaSummary {
  final String id;
  final String name;
  final Map<String, dynamic> geometry;

  const AreaSummary({
    required this.id,
    required this.name,
    required this.geometry,
  });

  factory AreaSummary.fromJson(Map<String, dynamic> json) {
    return AreaSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      geometry: Map<String, dynamic>.from(
        json['geometry'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class HomeRepository {
  final ApiClient _client;

  HomeRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<AlertEvent>> fetchActiveAlerts() async {
    final response = await _client.getJson('/alerts/active');
    final data = response as List<dynamic>;
    return data
        .map((item) => AlertEvent.fromJson(item as Map<String, dynamic>))
        .toList();
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
