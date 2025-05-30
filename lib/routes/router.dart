import 'package:get/get.dart';
import 'package:listview_getx/controllers/pickuplist_controller.dart';
import 'package:listview_getx/features/auth/pages/login.dart';
import 'package:listview_getx/features/pickuplist/pages/pickup_list.dart';

class CusRouter{
  CusRouter._();

  static const String initial = LoginPage.routeName;

  static final routes = [
    GetPage(
        name: LoginPage.routeName,
        page: ()=>LoginPage()
    ),
    GetPage(
        name: PickupListPage.routeName,
        page: ()=>PickupListPage(),
        binding: BindingsBuilder(() {
          Get.lazyPut<PickupListController>(() => PickupListController());
        }),
    ),
  ];
}