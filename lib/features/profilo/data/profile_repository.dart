import 'package:apex/features/profilo/models/profile_models.dart';
import 'package:apex/shared/api/api_client.dart';

class ProfileRepository {
  final ApiClient _client;

  ProfileRepository({ApiClient? client}) : _client = client ?? ApiClient();

  Future<ProfileUser> fetchCurrentUser() async {
    final response = await _client.getJson('/users/me');
    return ProfileUser.fromJson(response as Map<String, dynamic>);
  }

  Future<ProfileUser> updateProfile({
    required String name,
    required String surname,
    String? profileImage,
  }) async {
    final response = await _client.patchJson(
      '/users/me',
      body: {
        'name': name,
        'surname': surname,
        if (profileImage != null && profileImage.isNotEmpty)
          'profileImage': profileImage,
      },
    );
    return ProfileUser.fromJson(response as Map<String, dynamic>);
  }
}
