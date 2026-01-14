import 'package:apex/shared/api/api_client.dart';

class AssistantReply {
  final String conversationId;
  final String answer;
  final DateTime createdAt;

  AssistantReply({
    required this.conversationId,
    required this.answer,
    required this.createdAt,
  });

  factory AssistantReply.fromJson(Map<String, dynamic> json) {
    return AssistantReply(
      conversationId: json['conversationId'] as String,
      answer: json['answer'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AssistenteRepository {
  final ApiClient _client;

  AssistenteRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<AssistantReply> sendMessage({
    required String message,
    required String areaId,
    String? conversationId,
  }) async {
    final response = await _client.postJson(
      '/ai/chat',
      body: {
        'message': message,
        'areaId': areaId,
        if (conversationId != null) 'conversationId': conversationId,
      },
    );
    return AssistantReply.fromJson(response as Map<String, dynamic>);
  }
}
