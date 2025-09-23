import 'dart:async';
import 'dart:convert';
import 'package:estate360Security/ui/views/dashboard/profileDetailsDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../core/data/models/dahsboard_model.dart';
import '../../../core/data/models/gate_pass_model.dart';
import '../../../core/data/models/notification_model.dart';
import '../../../core/data/models/update.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/interceptors.dart';
import 'package:flutter/material.dart';
import '../../common/app_colors.dart';
import '../auth/visitorProfile.dart';

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
  Barcode? result;
  QRViewController? controller;
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

  Future<void> getNotifications() async {
    setBusy(true);
    try {
      final response = await repo.getNotifications();
      if (response.statusCode == 200 && response.data['success'] == true) {
        notifications = (response.data['data'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        notifications.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      } else {
        log.e("Failed to fetch notifications: ${response.data['message']}");
      }
    } catch (e) {
      log.e("Error fetching notifications: $e");
    }
    setBusy(false);
  }

  Future<void> refreshData() async {
    setBusy(true);
    await getNotifications();
    await getDashboardData();
    notifyListeners();
    setBusy(false);
  }

  Future<bool> verifyGatePass(
      String verificationCode, BuildContext context,
      {required Null Function(String reason) onFailure}) async {
    try {
      setBusy(true);
      try {
        final decodedString = utf8.decode(base64.decode(verificationCode));
        final decodedData = jsonDecode(decodedString);

        if (decodedData['type'] == 'profile') {
          if (context.mounted) {
            Navigator.of(context).pop();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              builder: (context) => ProfileDetailsDialog(profileData: decodedData),
            );
          }
          return true;
        }
      } on FormatException {
        log.i('QR code is not base64 encoded, treating as visitor code');
      }
      ApiResponse res = await repo.validateGatePass(verificationCode);
      if (res.statusCode == 200 && res.data != null) {
        prettyPrintJson(res.data, tag: 'validateGatePass: ');
        final data = res.data['data'];
        prettyPrintJson(data, tag: 'gatePass.data: ');
        prettyPrintJson(data['visitor'] ?? {}, tag: 'visitor: ');
        prettyPrintJson(data['resident'] ?? {}, tag: 'resident: ');

        GatePassModel gatePass = GatePassModel.fromJson(res.data['data']);

        if (context.mounted) {
          Navigator.of(context).pop();
          showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => VisitorProfileDialog(gatePass: gatePass),
          ).then((visitorResult) {
            if (visitorResult == true) {
              refreshData();
            }
          });
        }
        return true;
      } else {
        if (context.mounted) {
          onFailure(res.data['message'] ?? "Unknown error");
        }
        return false;
      }
    } catch (e, stackTrace) {
      log.e(e);
      log.e(stackTrace);
      if (context.mounted) {
        onFailure('Invalid Code');
        locator<SnackbarService>().showSnackbar(
          message: 'Invalid Code',
          duration: const Duration(seconds: 3),
        );
      }
      return false;
    } finally {
      setBusy(false);
    }
  }

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      result = scanData;
      if (result != null) {
        controller.pauseCamera();
        setBusy(true);
        final BuildContext? currentContext =
            locator<NavigationService>().navigatorKey?.currentContext;

        if (currentContext == null || !currentContext.mounted) {
          log.e('No valid context available');
          setBusy(false);
          return;
        }

        bool isVerified = await verifyGatePass(
          result!.code!,
          currentContext,
          onFailure: (reason) {
            if (currentContext.mounted) {
              locator<SnackbarService>().showSnackbar(
                message: reason,
                duration: const Duration(seconds: 3),
              );
            }
          },
        );

        if (isVerified) {
          notifyListeners();
        }
        setBusy(false);
      }
    });
  }

  Future<bool> verifyPublicId(String publicId) async {
    setBusy(true);
    setBusy(false);
    return false;
  }

  void verifyCode(BuildContext context, String verificationCode,
      {required Null Function(String reason) onFailure}) async {
    await verifyGatePass(verificationCode, context, onFailure: onFailure);
    notifyListeners();
  }

  @override
  void dispose() {
    controller?.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}