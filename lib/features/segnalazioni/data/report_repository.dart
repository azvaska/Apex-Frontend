import 'package:apex/features/segnalazioni/models/report_models.dart';
import 'package:apex/shared/api/api_client.dart';

class ReportRepository {
  final ApiClient _client;

  ReportRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<Report>> fetchReports({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.getJson(
      '/reports',
      query: {
        'page': '$page',
        'limit': '$limit',
      },
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((item) => Report.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Report> fetchReportById(String id) async {
    final response = await _client.getJson('/reports/$id');
    return Report.fromJson(response as Map<String, dynamic>);
  }

  Future<Report> createReport({
    required String title,
    required String text,
    required String areaId,
    String? imageDataUrl,
  }) async {
    final payload = {
      'title': title,
      'text': text,
      'areaId': areaId,
      if (imageDataUrl != null && imageDataUrl.isNotEmpty)
        'image': imageDataUrl,
    };
    final response = await _client.postJson('/reports', body: payload);
    return Report.fromJson(response as Map<String, dynamic>);
  }

  Future<ReportComment> createComment({
    required String reportId,
    required String text,
  }) async {
    final response = await _client.postJson(
      '/reports/$reportId/comments',
      body: {'text': text},
    );
    return ReportComment.fromJson(response as Map<String, dynamic>);
  }

  Future<List<AreaOfInterest>> fetchAreas({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _client.getJson(
      '/areas-of-interest',
      query: {
        'page': '$page',
        'limit': '$limit',
      },
    );
    final data = response['data'] as List<dynamic>;
    return data
        .map((item) => AreaOfInterest.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
