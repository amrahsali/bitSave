import 'dart:async';
import 'dart:convert';
import 'package:bitSave/ui/views/dashboard/profileDetailsDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../core/data/models/dahsboard_model.dart';
import '../../../core/data/models/notification_model.dart';
import '../../../core/data/models/update.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import 'package:flutter/material.dart';

void prettyPrintJson(dynamic object, {String? tag}) {
  final encoder = const JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(object);
  const int chunkSize = 800;

  for (var i = 0; i < jsonString.length; i += chunkSize) {
    final end = (i + chunkSize > jsonString.length) ? jsonString.length : i + chunkSize;
    debugPrint('${tag ?? ''}${jsonString.substring(i, end)}');
  }
}

class Transaction {
  final String recipient;
  final double amount;
  final String time;
  final String date;

  Transaction({
    required this.recipient,
    required this.amount,
    required this.time,
    required this.date,
  });
}

class TodoItem {
  final String title;
  final bool completed;

  TodoItem({
    required this.title,
    required this.completed,
  });
}

class DashboardViewModel extends BaseViewModel {
  final log = getLogger("DashboardViewModel");
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
 // Barcode? result;
 // QRViewController? controller;
  DashboardModel? dashboardData;
  Timer? _autoRefreshTimer;

  // Financial data
  double _totalBalance = 20999.99;
  double _cryptoBalance = 72.80;
  double _todayChange = 20.50;
  List<Transaction> _transactions = [];
  List<TodoItem> _todos = [];

  // Notifications and updates
  List<NotificationModel> notifications = [];
  List<UpdateModel> _updates = [];
  int selectedIndex = 0;
  bool _isDataLoaded = false;

  // Getters for financial data
  double get totalBalance => _totalBalance;
  double get cryptoBalance => _cryptoBalance;
  double get todayChange => _todayChange;
  List<Transaction> get transactions => _transactions;
  List<TodoItem> get todos => _todos;
  List<UpdateModel> get updates => _updates;

  DashboardViewModel() {
    _initializeFinancialData();
  }

  void _initializeFinancialData() {
    _transactions = [
      Transaction(
        recipient: "Karimatu UIUX",
        amount: -5000.00,
        time: "3:30 PM",
        date: "Today",
      ),
    ];

    _todos = [
      TodoItem(title: "Enable FaceID /Fingerprint", completed: false),
      TodoItem(title: "Approved Device", completed: false),
      TodoItem(title: "Add a picture", completed: false),
      TodoItem(title: "Enable /Fingerprint", completed: false),
    ];
  }

  void changeSelected(int i) {
    selectedIndex = i;
    notifyListeners();
  }

  // Financial methods
  void addFunds(double amount) {
    _totalBalance += amount;
    notifyListeners();
  }

  void withdraw(double amount) {
    if (_totalBalance >= amount) {
      _totalBalance -= amount;
      notifyListeners();
    }
  }

  void markTodoCompleted(int index) {
    if (index >= 0 && index < _todos.length) {
      _todos[index] = TodoItem(
        title: _todos[index].title,
        completed: true,
      );
      notifyListeners();
    }
  }
  void handleAddAction(int accountType) {
    // Handle add action based on account type
    print('Add action for ${accountType == 0 ? 'Fiat' : 'Crypto'}');
  }

  void handleWithdrawAction(int accountType) {
    // Handle withdraw action
    print('Withdraw action for ${accountType == 0 ? 'Fiat' : 'Crypto'}');
  }

  void handleReceiveAction(int accountType) {
    // Handle receive action
    print('Receive action for ${accountType == 0 ? 'Fiat' : 'Crypto'}');
  }

  void handleSwapAction(int accountType) {
    // Handle swap action
    print('Swap action for ${accountType == 0 ? 'Fiat' : 'Crypto'}');
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  // Add this to your DashboardViewModel
  int _selectedAccountType = 0; // 0 = Fiat, 1 = Crypto

  int get selectedAccountType => _selectedAccountType;

  void setAccountType(int index) {
    _selectedAccountType = index;
    notifyListeners();
  }


  // API methods
  Future<void> getDashboardData() async {
    setBusy(true);
    try {
      final response = await repo.getDashboardData();
      if (response.statusCode == 200 && response.data['success'] == true) {
        dashboardData = DashboardModel.fromJson(response.data['data']);
      } else {
        log.e("Failed to fetch dashboard data: ${response.data['message']}");
      }
    } catch (e) {
      log.e("Error fetching dashboard data: $e");
    }
    setBusy(false);
  }

  // Future<void> getNotifications() async {
  //   setBusy(true);
  //   try {
  //     final response = await repo.getNotifications();
  //     if (response.statusCode == 200 && response.data['success'] == true) {
  //       notifications = (response.data['data'] as List)
  //           .map((json) => NotificationModel.fromJson(json))
  //           .toList();
  //       notifications.sort((a, b) => b.sentAt.compareTo(a.sentAt));
  //     } else {
  //       log.e("Failed to fetch notifications: ${response.data['message']}");
  //     }
  //   } catch (e) {
  //     log.e("Error fetching notifications: $e");
  //   }
  //   setBusy(false);
  // }

  Future<void> refreshData() async {
    setBusy(true);
    //await getNotifications();
    await getDashboardData();
    notifyListeners();
    setBusy(false);
  }


  Future<bool> verifyPublicId(String publicId) async {
    setBusy(true);
    setBusy(false);
    return false;
  }


  @override
  void dispose() {
    //controller?.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}