import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/notification_model.dart';
import '../../../core/network/interceptors.dart';

class ReportsViewModel extends BaseViewModel {
  final TextEditingController searchController = TextEditingController();

  List<NotificationModel> allNotifications = [];
  List<NotificationModel> filteredNotifications = [];

  /// ✅ **Initialize & Fetch Notifications**
  Future<void> init() async {
    setBusy(true);
    await fetchNotifications();
    setBusy(false);
  }

  /// ✅ **Search Notifications**
  void searchNotifications(String query) {
    if (query.isEmpty) {
      filteredNotifications = List.from(allNotifications);
    } else {
      filteredNotifications = allNotifications
          .where((notification) =>
      notification.title.toLowerCase().contains(query.toLowerCase()) ||
          notification.message.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// ✅ **Filter Notifications by Type**
  void filterNotifications(String type) {
    if (type == "All") {
      filteredNotifications = List.from(allNotifications);
    } else {
      filteredNotifications =
          allNotifications.where((n) => n.notificationType == type).toList();
    }
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    setBusy(true);
    try {
      final response = await repo.getNotifications();
      if (response.statusCode == 200 && response.data['success'] == true) {
        allNotifications = (response.data['data'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        allNotifications.sort((a, b) => b.sentAt.compareTo(a.sentAt));
        filteredNotifications = List.from(allNotifications);
        notifyListeners();
      } else {
        print("Failed to fetch notifications: ${response.data['message']}");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
    setBusy(false);
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }

  Future<void> escalateNotifications(int notificationId) async {
    setBusy(true);
    try {
      final response = await repo.escalateNotifications(notificationId);
      if (response.statusCode == 200) {
        locator<SnackbarService>().showSnackbar(message: "Notification sent", duration: const Duration(seconds: 3));
        await fetchNotifications();
      } else {
        locator<SnackbarService>().showSnackbar(message: "Failed to escalate notification", duration: const Duration(seconds: 3));
        print("Failed to fetch notifications: ${response.data['message']}");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
    setBusy(false);
  }

}
