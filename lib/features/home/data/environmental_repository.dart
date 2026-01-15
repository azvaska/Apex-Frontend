import 'package:apex/shared/api/api_client.dart';

class EnvironmentalSample {
  final String id;
  final String areaId;
  final DateTime timestamp;
  final double airTemperatureC;
  final double relativeHumidity;
  final double windSpeedMs;
  final int windDirectionDeg;
  final double precipitationMm;
  final String source;

  EnvironmentalSample({
    required this.id,
    required this.areaId,
    required this.timestamp,
    required this.airTemperatureC,
    required this.relativeHumidity,
    required this.windSpeedMs,
    required this.windDirectionDeg,
    required this.precipitationMm,
    required this.source,
  });

  factory EnvironmentalSample.fromJson(Map<String, dynamic> json) {
    return EnvironmentalSample(
      id: json['id'] as String,
      areaId: json['areaId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      airTemperatureC: (json['airTemperatureC'] as num).toDouble(),
      relativeHumidity: (json['relativeHumidity'] as num).toDouble(),
      windSpeedMs: (json['windSpeedMs'] as num).toDouble(),
      windDirectionDeg: (json['windDirectionDeg'] as num).toInt(),
      precipitationMm: (json['precipitationMm'] as num).toDouble(),
      source: json['source'] as String,
    );
  }
}

class EnvironmentalRepository {
  final ApiClient _client;

  EnvironmentalRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<EnvironmentalSample> fetchLatestSample(String areaId) async {
    final response = await _client.getJson('/environmental/latest/$areaId');
    return EnvironmentalSample.fromJson(response as Map<String, dynamic>);
  }
}
