import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_getx/constants/enums.dart';
import 'package:listview_getx/features/auth/pages/login.dart';
import 'package:listview_getx/features/pickuplist/pages/pickup_list.dart';
import 'package:listview_getx/providers/auth_provider.dart';
import 'package:listview_getx/services/local_storage.dart';
import 'package:listview_getx/utils/debug_print.dart';

class AuthController extends GetxController with StateMixin<LoginState> {
  final AuthProvider _authApiService = Get.find<AuthProvider>();
  final LocalStorageService _localStorageService = Get.find<LocalStorageService>();

   TextEditingController usernameController = TextEditingController();
   TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    cusDebugPrint('AuthController onInit called.');

    change(LoginState.loading, status: RxStatus.loading());
  }


  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }


  Future<void> checkLoginStatus() async {
    cusDebugPrint('checkLoginStatus started.');
    final accessToken = _localStorageService.getAccessToken();
    final expirationTimestampMillis = _localStorageService.getExpirationTimestamp();
    final refreshToken = _localStorageService.getRefreshToken();

    cusDebugPrint('Stored Access Token: $accessToken');
    cusDebugPrint('Stored Expiration Timestamp (millis): $expirationTimestampMillis');
    cusDebugPrint('Stored Refresh Token: $refreshToken');

    if (accessToken != null && expirationTimestampMillis != null) {
      final DateTime expirationTimeUtc = DateTime.fromMillisecondsSinceEpoch(expirationTimestampMillis, isUtc: true);
      final DateTime nowUtc = DateTime.now().toUtc();

      cusDebugPrint('Current UTC time: $nowUtc');
      cusDebugPrint('Token Expiration UTC time: $expirationTimeUtc');

      if (nowUtc.isBefore(expirationTimeUtc)) {
        change(LoginState.loggedIn, status: RxStatus.success());
        cusDebugPrint('User logged in. Access token is valid.');
      } else {
        cusDebugPrint('Access token expired. Attempting to refresh...');
        if (refreshToken != null) {
          bool refreshed = await refreshAccessToken();
          if (refreshed) {
            cusDebugPrint('Token refreshed successfully during status check.');
            change(LoginState.loggedIn, status: RxStatus.success());
            usernameController.clear();
            passwordController.clear();
          } else {
            cusDebugPrint('Refresh token failed. User needs to re-login.');
            change(LoginState.initial, status: RxStatus.empty());
          }
        } else {
          cusDebugPrint('No refresh token available. User needs to re-login.');
          change(LoginState.initial, status: RxStatus.empty());
        }
      }
    } else {
      change(LoginState.initial, status: RxStatus.empty());
      cusDebugPrint('No access token or expiration data found. User is logged out.');
    }
  }

  Future<void> login() async {
    cusDebugPrint('Attempting login...');
    change(LoginState.loading, status: RxStatus.loading());

    try {
      final response = await _authApiService.login(
        usernameController.text,
        passwordController.text,
      );
      cusDebugPrint('Login API Response Body: ${response.body}');

      if (response.isOk && response.body != null && response.body['success'] == true) {
        final data = response.body['data'];
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        final expiresInSeconds = data['expires_in']; // This is the duration in seconds

        if (accessToken != null && refreshToken != null && expiresInSeconds != null) {
          await _localStorageService.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresInSeconds,
          );
          change(LoginState.loggedIn, status: RxStatus.success());
          Get.offAllNamed(PickupListPage.routeName);
          Get.snackbar('Success', response.body['message'] ?? 'Login successful!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
          cusDebugPrint('Login successful. Token saved.');
        } else {
          throw 'Missing token data from API response.';
        }
      } else {
        final errorMessage = response.body?['message'] ?? response.statusText ?? 'Login failed. Please try again.';
        change(LoginState.error, status: RxStatus.error(errorMessage));
        Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        cusDebugPrint('Login API error: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      final errorMessage = e.toString();
      change(LoginState.error, status: RxStatus.error('An unexpected error occurred: $errorMessage'));
      Get.snackbar('Error', 'An unexpected error occurred: $errorMessage', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      cusDebugPrint('Login error: $e');
    }
  }

  Future<void> logout({bool isSilent = false}) async {
    cusDebugPrint('Attempting logout...');
    if (!isSilent) {
      change(LoginState.loading, status: RxStatus.loading());
    }
    _showLoadingOverlay();
    try {
      final response = await _authApiService.revokeAccessToken();

      if (response.isOk && response.body != null && response.body['success'] == true) {
        cusDebugPrint('Token revocation successful (if applicable).');
      } else {
        cusDebugPrint('Token revocation failed or not applicable, proceeding with local logout. Message: ${response.body?['message']}');
      }
    } catch (e) {
      cusDebugPrint('Error revoking token: $e. Proceeding with local logout.');
    } finally {
      await _localStorageService.clearTokens();
      change(LoginState.initial, status: RxStatus.empty());
      Get.offAllNamed(LoginPage.routeName);
      if (!isSilent) {
        Get.snackbar('Logged Out', 'You have been successfully logged out.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      }
      cusDebugPrint('Local tokens cleared. Redirected to login page.');
    }
  }

  Future<bool> refreshAccessToken() async {
    cusDebugPrint('Attempting to refresh token...');
    final refreshToken = _localStorageService.getRefreshToken();
    if (refreshToken == null) {
      cusDebugPrint('No refresh token available. Cannot refresh.');
      return false;
    }

    try {
      final response = await _authApiService.refreshToken(refreshToken);
      cusDebugPrint('Refresh Token API Response Body: ${response.body}');

      if (response.isOk && response.body != null && response.body['success'] == true) {
        final data = response.body['data'];
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        final expiresInSeconds = data['expires_in'];

        if (newAccessToken != null && newRefreshToken != null && expiresInSeconds != null) {
          await _localStorageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            expiresIn: expiresInSeconds,
          );
          cusDebugPrint('Token refreshed successfully!');
          return true;
        } else {
          cusDebugPrint('Refresh token response missing data.');
          return false;
        }
      } else {
        final errorMessage = response.body?['message'] ?? response.statusText ?? 'Failed to refresh token.';
        cusDebugPrint('Refresh token API error: $errorMessage');
        return false;
      }
    } catch (e) {
      cusDebugPrint('Refresh token catch error: $e');
      return false;
    }
  }

  void _showLoadingOverlay() {
    if (Get.isDialogOpen == true) {
      cusDebugPrint('Dialog already open, not showing logout overlay.');
      return;
    }
    cusDebugPrint('Showing full-screen logout overlay.');
    Get.dialog(
      PopScope(
        canPop: false,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54,
      useSafeArea: true,
      name: 'LogoutLoadingOverlay',
    );
  }
}