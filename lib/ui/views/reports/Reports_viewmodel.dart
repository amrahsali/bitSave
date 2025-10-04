import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../core/data/models/notification_model.dart';
import '../../../core/network/interceptors.dart';

class ReportsViewModel extends BaseViewModel {
  final TextEditingController searchController = TextEditingController();
  double _todayChange = 20.50;
  double _cryptoBalance = 72.80;
  double _cryptoBalanceInSats = 0.0;

  int _selectedAccountType = 0;

  int get selectedAccountType => _selectedAccountType;

  List<NotificationModel> allNotifications = [];
  List<NotificationModel> filteredNotifications = [];
  double get todayChange => _todayChange;
  double get cryptoBalance => _cryptoBalance;

  double get cryptoBalanceInSats => _cryptoBalanceInSats;

  /// ✅ **Initialize & Fetch Notifications**
  Future<void> init() async {
    setBusy(true);
    // await fetchNotifications();
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

  // Future<void> fetchNotifications() async {
  //   setBusy(true);
  //   try {
  //     final response = await repo.getNotifications();
  //     if (response.statusCode == 200 && response.data['success'] == true) {
  //       allNotifications = (response.data['data'] as List)
  //           .map((json) => NotificationModel.fromJson(json))
  //           .toList();
  //       allNotifications.sort((a, b) => b.sentAt.compareTo(a.sentAt));
  //       filteredNotifications = List.from(allNotifications);
  //       notifyListeners();
  //     } else {
  //       print("Failed to fetch notifications: ${response.data['message']}");
  //     }
  //   } catch (e) {
  //     print("Error fetching notifications: $e");
  //   }
  //   setBusy(false);
  // }

  // Future<void> refreshNotifications() async {
  //   await fetchNotifications();
  // }

  // Future<void> escalateNotifications(int notificationId) async {
  //   setBusy(true);
  //   try {
  //     final response = await repo.escalateNotifications(notificationId);
  //     if (response.statusCode == 200) {
  //       locator<SnackbarService>().showSnackbar(message: "Notification sent", duration: const Duration(seconds: 3));
  //       // await fetchNotifications();
  //     } else {
  //       locator<SnackbarService>().showSnackbar(message: "Failed to escalate notification", duration: const Duration(seconds: 3));
  //       print("Failed to fetch notifications: ${response.data['message']}");
  //     }
  //   } catch (e) {
  //     print("Error fetching notifications: $e");
  //   }
  //   setBusy(false);
  // }

  void quickSave() {
    // Implement quick save functionality
    // This could open a dialog or navigate to quick save screen
  }

  void selectRecommendation(String amount, String purpose) {
    // Handle recommendation selection
    // This could navigate to a savings setup screen
  }

  void unlockSavings(String savingsTitle) {
    // Handle unlock savings functionality
    // This could show a confirmation dialog
  }

  void completeSavings(String savingsTitle) {
    // Handle complete savings functionality
    // This could show a confirmation dialog and process completion
  }

  void showMoreOptions() {
    // Handle complete savings functionality
    // This could show a confirmation dialog and process completion
  }
  // Insights Page Methods
  void setSavingsGoal() {
    // Implement set savings goal functionality
    // This could navigate to a savings goal setup screen
  }

  void viewFinancialDetails() {
    // Implement view financial details functionality
  }

  void manageSavings() {
    // Implement manage savings functionality
  }

  // Chart data methods
  List<double> getChartData() {
    // Return chart data for the financial overview
    return [8000, 12000, 16000, 14000, 10000, 6000];
  }

  // Financial data methods
  double getTotalIncome() => 15000.0;
  double getTotalExpenses() => 10000.0;
  String getBTCBalance() => "14,530.12";
  String getSavingsBalance() => "13,540.40";

  // Progress data
  double getBusinessProgress() => 0.85;
  String getBusinessAmount() => "\$12,400.00";

}
