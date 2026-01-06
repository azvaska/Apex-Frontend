import 'package:apex/shared/api/api_client.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    await _client.postJson(
      '/auth/signup',
      body: {
        'email': email,
        'password': password,
        'name': name,
        'surname': surname,
      },
    );
  }
}
