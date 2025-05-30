// lib/features/pickuplist/pages/pickup_list.dart

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
    // Retrieve AuthController to handle logout action
    final AuthController authController = Get.find<AuthController>();

    // Define the display names for the tabs (purely for UI labels)
    final List<String> tabDisplayNames = [
      'Pickup on way',
      'Pickup Completed',
      'Pickup cancel',
    ];

    return DefaultTabController(
      length: tabDisplayNames.length,
      // Use Obx to ensure initialIndex reacts if controller.selectedTabIndex is changed programmatically
      initialIndex: controller.selectedTabIndex.value,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text(
              'Pickup List',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          centerTitle: true,
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
              // This is the ONLY action the TabBar takes: update the controller's selected index.
              // The controller then handles fetching new data based on this index.
              controller.selectedTabIndex.value = index;
            },
            tabs: tabDisplayNames.map((name) => Tab(text: name)).toList(),
            indicatorColor: Colors.orange, // Visual styling from design
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: Obx(() {
          // This outer Obx ensures that the `currentApiStatus` used in `onRefresh`
          // and `onError` retry button dynamically updates when the tab changes.
          final String currentApiStatus = controller.tabApiStatuses[controller.selectedTabIndex.value];

          // RefreshIndicator allows pull-to-refresh functionality for the list.
          // It calls the controller's onRefresh method with the current tab's API status.
          return RefreshIndicator(
            onRefresh: () => controller.onRefresh(currentApiStatus),
            // controller.obx() observes the StateMixin status (loading, success, error, empty)
            // of the *single* list managed by the controller.
            child: controller.obx(
                  (state) {
                // This builder is for RxStatus.success.
                // 'state' here is the List<PickupItemModel> (controller.items.value).
                cusDebugPrint('Page obx: Success builder for tab status: $currentApiStatus. Items count: ${controller.items.length}');

                // Check if the list of items is empty for the current status.
                // We use controller.items.isEmpty because 'state' might still contain
                // the last loaded items even if the new fetch is empty.
                if (controller.items.isEmpty) {
                  return ListView( // Use ListView to allow pull-to-refresh even when empty
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

                // If items exist, display them using ListView.builder
                return ListView.builder(
                  controller: controller.scrollController, // Attach the single scroll controller
                  itemCount: controller.items.length + (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    // If it's the last item and isLoadingMore is true, show the loading indicator
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