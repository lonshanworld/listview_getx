import 'package:get/get.dart';
import 'package:listview_getx/controllers/auth_controller.dart';
import 'package:listview_getx/providers/auth_provider.dart';
import 'package:listview_getx/services/local_storage.dart';

class DependencyInjection{
  static Future<void> init() async {

    await Get.putAsync<LocalStorageService>(() async => await LocalStorageService().init());
    Get.put<AuthProvider>(AuthProvider());

    Get.put<AuthController>(AuthController());
  }
}