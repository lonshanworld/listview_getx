import 'package:get/get.dart';
import 'package:listview_getx/controllers/auth_controller.dart';
import 'package:listview_getx/services/local_storage.dart';
import 'package:listview_getx/utils/debug_print.dart';

class PickupProvider extends GetConnect {
  static const String _baseUrl = 'https://dev.gigagates.com/qq-delivery-backend'; // Correct Base URL
  final LocalStorageService _localStorageService = Get.find<LocalStorageService>();

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;

    httpClient.addRequestModifier<void>((request) async {
      final accessToken = _localStorageService.getAccessToken();
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
      cusDebugPrint('Requesting: ${request.url} with headers: ${request.headers}');
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      cusDebugPrint('Response from ${request.url}: Status ${response.statusCode}, Body: ${response.bodyString}');
      if (response.statusCode == 401) {
        cusDebugPrint('PickupApiService: Unauthorized access, token expired or invalid.');
        Get.find<AuthController>().logout();
      }
      return response;
    });
  }

  Future<Response<Map<String, dynamic>>> getPickupItems({
    required int first,
    required int max,
  }) {
    final body = {
      'first': first,
      'max': max,
    };
    cusDebugPrint('Fetching pickup items with body: $body');
    return post(
      '/v4/pickup/list',
      body,
      decoder: (responseBody) {

        return responseBody as Map<String, dynamic>;
      },
    );
  }
}