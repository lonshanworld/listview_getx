
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_getx/models/pickupitem_model.dart';
import 'package:listview_getx/providers/pickuplist_provider.dart';
import 'package:listview_getx/utils/debug_print.dart';


class PickupListController extends GetxController with StateMixin<List<PickupItemModel>> {
  final PickupProvider _pickupProvider = Get.put<PickupProvider>(PickupProvider());

  final List<String> tabApiStatuses = [
    'on_way',
    'completed',
    'canceled',
  ];

  final RxInt selectedTabIndex = 0.obs;

  final RxList<PickupItemModel> items = <PickupItemModel>[].obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  int currentPage = 0;
  int totalRecords = 0;
  final int _recordsPerPage = 10;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    cusDebugPrint('PickupListController onInit called.');

    scrollController.addListener(_scrollListener);

    fetchPickupItems( isInitialFetch: true);


    ever(selectedTabIndex, (int index) {
      final String newApiStatus = tabApiStatuses[index];
      cusDebugPrint('Tab changed to index: $index, new status filter: $newApiStatus');
      fetchPickupItems( isInitialFetch: true);
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent &&
        hasMoreData.value &&
        !isLoadingMore.value &&
        status.isSuccess) {
      cusDebugPrint('Scroll to bottom detected. Attempting to load more items.');
      fetchPickupItems( isLoadMore: true);
    }
  }


  void _resetPaginationAndList() {
    items.clear();
    currentPage = 0;
    totalRecords = 0;
    hasMoreData.value = true;
    isLoadingMore.value = false;
  }


  Future<void> fetchPickupItems({
    bool isInitialFetch = false,
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    if (isLoadMore) {
      if (!hasMoreData.value || isLoadingMore.value) {
        cusDebugPrint('Load more blocked for status $status: hasMoreData=${hasMoreData.value}, isLoadingMore=${isLoadingMore.value}');
        return;
      }
      isLoadingMore.value = true;
    }
    else if (isInitialFetch || isRefresh) {
      _resetPaginationAndList();
      change(null, status: RxStatus.loading());
    }

    try {
      final response = await _pickupProvider.getPickupItems(
        first: currentPage,
        max: _recordsPerPage,
      );
      cusDebugPrint('check response ${response.body}');
      if (response.isOk && response.body != null && response.body?['success'] == true) {
        final data = response.body?['data'];
        final List<dynamic> itemsJson = data['items'] ?? [];
        final int totalRecordsFromServer = data['totalRecords'] ?? 0;

        final List<PickupItemModel> newFetchedItems = itemsJson
            .map((json) => PickupItemModel.fromJson(json as Map<String, dynamic>))
            .toList();

        items.addAll(newFetchedItems);

        totalRecords = totalRecordsFromServer;
        if (items.length >= totalRecords) {
          hasMoreData.value = false;
          cusDebugPrint('All data loaded for status $status. Total items fetched: ${items.length}');
        } else {
          currentPage++;
          cusDebugPrint('Loaded page ${currentPage -1} for status $status. Total items: ${items.length}, Total records: $totalRecords');
        }

        if (items.isEmpty) {
          change(items.value, status: RxStatus.empty());
        } else {
          change(items.value, status: RxStatus.success());
        }
        cusDebugPrint('Fetched ${newFetchedItems.length} new items for status $status. Current list size: ${items.length}');
      } else {
        final errorMessage = response.body?['message'] ?? response.statusText ?? 'Failed to load pickup items.';
        change(items.value, status: RxStatus.error(errorMessage));
        cusDebugPrint('API Error for status $status: $errorMessage');
      }
    } catch (e) {
      final errorMessage = e.toString();
      change(items.value, status: RxStatus.error(errorMessage));
      cusDebugPrint('Catch Error for status $status: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }


  Future<void> onRefresh(String status) async {
    cusDebugPrint('Pull to refresh triggered for status: $status');
    await fetchPickupItems(isRefresh: true);
  }
}