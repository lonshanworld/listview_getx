
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_getx/controllers/auth_controller.dart';
import 'package:listview_getx/controllers/pickuplist_controller.dart';
import 'package:listview_getx/features/pickuplist/components/pickupItem_widget.dart';
import 'package:listview_getx/utils/debug_print.dart';


class PickupListPage extends GetView<PickupListController> {
  static const String routeName = '/pickup_list';

  const PickupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    final List<String> tabDisplayNames = [
      'Pickup on way',
      'Pickup Completed',
      'Pickup cancel',
    ];

    return DefaultTabController(
      length: tabDisplayNames.length,
      initialIndex: controller.selectedTabIndex.value,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,

          actions: [
            TextButton(
                onPressed: (){
                  authController.logout();
                },
                child: Text(
                    "Log out",
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                )
            )
          ],
          bottom: TabBar(
            onTap: (index) {
              controller.selectedTabIndex.value = index;
            },
            tabs: tabDisplayNames.map((name) => Tab(text: name)).toList(),
            indicatorColor: Colors.orange, // Visual styling from design
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: Obx(() {
          final String currentApiStatus = controller.tabApiStatuses[controller.selectedTabIndex.value];

          return RefreshIndicator(
            onRefresh: () => controller.onRefresh(currentApiStatus),
            child: controller.obx(
                  (state) {
                cusDebugPrint('Page obx: Success builder for tab status: $currentApiStatus. Items count: ${controller.items.length}');

                if (controller.items.isEmpty) {
                  return ListView(
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No pickup items found for this status.'),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.items.length + (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.items.length -1) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator(
                          color: Colors.teal,
                        )),
                      );
                    }

                    final item = controller.items[index];
                    final displayIndex = index + 1;
                    final totalItemsForTab = controller.totalRecords;

                    return PickupitemWidget(
                        countString: '$displayIndex of $totalItemsForTab',
                        osName: item.osName,
                        osPrimaryPhone: item.osPrimaryPhone,
                        pickupDate: item.pickupDate ?? 'N/A',
                        totalWays: item.totalWays,
                        townShipName: item.osTownshipName,
                        trackingId: item.trackingId
                    );
                  },
                );
              },

              onLoading: const Center(child: CircularProgressIndicator()),
              onError: (error) {
                cusDebugPrint('Page obx: onError builder. Error: $error');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${error ?? 'Unknown error'}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => controller.fetchPickupItems(isInitialFetch: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
              onEmpty: ListView(
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No pickup items found for this status.'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}