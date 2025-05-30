import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_getx/constants/enums.dart';
import 'package:listview_getx/controllers/auth_controller.dart';
import 'package:listview_getx/features/pickuplist/pages/pickup_list.dart';
import 'package:listview_getx/injectors.dart';
import 'package:listview_getx/routes/router.dart';
import 'package:listview_getx/utils/debug_print.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  final AuthController authController = Get.find<AuthController>();

  String startPage = CusRouter.initial;
  cusDebugPrint('Main: Starting initial login status check.');
  await authController.checkLoginStatus();
  cusDebugPrint('Main: Initial login status check completed. AuthController state: ${authController.state}, status: ${authController.status}');

  if (authController.state == LoginState.loggedIn) {
    startPage = PickupListPage.routeName;
    cusDebugPrint('Main: Initial route set to pickup.');
  } else {
    cusDebugPrint('Main: Initial route remains LOGIN.');
  }
  runApp(GetMaterialApp(
    title: "QuickQ Innovation App",
    initialRoute: startPage,
    getPages: CusRouter.routes,
    debugShowCheckedModeBanner: false,
  ));
}



