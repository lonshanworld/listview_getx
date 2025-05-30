// lib/app/data/services/auth_api_service.dart
import 'package:get/get.dart';
import 'package:listview_getx/services/local_storage.dart';
import 'package:listview_getx/utils/debug_print.dart';

class AuthProvider extends GetConnect {
  static const String _baseUrl = 'https://dev.gigagates.com/qq-delivery-backend';
  final LocalStorageService _localStorageService = Get.find<LocalStorageService>();

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;

    httpClient.addRequestModifier<void>((request) async {
      final accessToken = _localStorageService.getAccessToken();
      if (accessToken != null && !request.url.path.contains('/v3/user/')) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {

        cusDebugPrint('Unauthorized access: ${response.statusCode}');
      }
      return response;
    });
  }

  Future<Response> login(String username, String password) {
    return post('/v3/user/', {
      'username': username,
      'password': password,
    });
  }

  Future<Response> revokeAccessToken() {

    return post(
      '/v3/user/revoke_access_token_by_username',
      {},
      headers: {
        'Authorization': 'Bearer ${_localStorageService.getAccessToken()}',
      },
    );
  }

  Future<Response> refreshToken(String refreshTokenValue) {
    return post('/v3/user/refresh_token', {
      'accessToken': refreshTokenValue,
    });
  }
}