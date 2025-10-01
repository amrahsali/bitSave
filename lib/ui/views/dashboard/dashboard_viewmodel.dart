import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import '../../../app/app.logger.dart';
import '../../../core/data/models/dahsboard_model.dart';
import '../../../core/data/models/notification_model.dart';
import '../../../core/data/models/update.dart';
import '../../../core/data/models/mavapay_models.dart';
import '../../../core/network/interceptors.dart';
import '../../../core/network/mavapay_service.dart';
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
  DashboardModel? dashboardData;
  Timer? _autoRefreshTimer;
  final MavapayService _mavapayService = MavapayService();

  double _totalBalance = 20999.99;
  double _cryptoBalance = 72.80;
  double _cryptoBalanceInSats = 0.0;
  double _todayChange = 20.50;
  List<Transaction> _transactions = [];
  List<TodoItem> _todos = [];
  
  // Mavapay data
  MavapayBalance? _mavapayBalance;
  MavapayExchangeRate? _exchangeRate;
  String _userId = "user_123";

  // Notifications and updates
  List<NotificationModel> notifications = [];
  List<UpdateModel> _updates = [];
  int selectedIndex = 0;
  bool _isDataLoaded = false;

  // Getters for financial data
  double get totalBalance => _totalBalance;
  double get cryptoBalance => _cryptoBalance;
  double get cryptoBalanceInSats => _cryptoBalanceInSats;
  double get todayChange => _todayChange;
  List<Transaction> get transactions => _transactions;
  List<TodoItem> get todos => _todos;
  List<UpdateModel> get updates => _updates;
  MavapayBalance? get mavapayBalance => _mavapayBalance;
  MavapayExchangeRate? get exchangeRate => _exchangeRate;

  DashboardViewModel() {
    _initializeFinancialData();
    _initializeCryptoBalance();
  }

  void _initializeCryptoBalance() {
    // Initialize crypto balance in sats (convert from BTC)
    _cryptoBalanceInSats = CurrencyConverter.bitcoinToSats(_cryptoBalance);
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
    if (accountType == 0) {
      // Fiat account - show Mavapay dialog
      // This will be called from the UI
      log.i('Add Naira funds action triggered');
    } else {
      // Crypto account - show Bitcoin receive dialog
      log.i('Add Bitcoin action triggered');
    }
  }

  /// Add Naira funds and convert to Bitcoin
  Future<void> addNairaFunds(double nairaAmount, double satsAmount) async {
    try {
      setBusy(true);
      
      // Update the balances
      _totalBalance += nairaAmount;
      _cryptoBalanceInSats += satsAmount;
      _cryptoBalance = CurrencyConverter.satsToBitcoin(_cryptoBalanceInSats);
      
      // Add transaction record
      _transactions.insert(0, Transaction(
        recipient: "Mavapay Deposit",
        amount: nairaAmount,
        time: DateTime.now().toString().substring(11, 16),
        date: "Today",
      ));
      
      log.i('Added ₦${nairaAmount.toStringAsFixed(2)} and ${satsAmount.toStringAsFixed(0)} sats');
      notifyListeners();
      
    } catch (e) {
      log.e('Error adding Naira funds: $e');
    } finally {
      setBusy(false);
    }
  }

  /// Initialize Mavapay balance data
  Future<void> initializeMavapayData() async {
    try {
      // Fetch user balance
      final balanceResponse = await _mavapayService.getUserBalance(_userId);
      if (balanceResponse.statusCode == 200 && balanceResponse.data['success'] == true) {
        _mavapayBalance = MavapayBalance.fromJson(balanceResponse.data['data']);
        _cryptoBalanceInSats = _mavapayBalance!.bitcoinBalanceInSats;
        _cryptoBalance = CurrencyConverter.satsToBitcoin(_cryptoBalanceInSats);
        _totalBalance = _mavapayBalance!.nairaBalance;
      }
      
      // Fetch exchange rate
      final rateResponse = await _mavapayService.getBitcoinExchangeRate();
      if (rateResponse.statusCode == 200 && rateResponse.data['success'] == true) {
        _exchangeRate = MavapayExchangeRate.fromJson(rateResponse.data['data']);
      }
      
      notifyListeners();
    } catch (e) {
      log.e('Error initializing Mavapay data: $e');
    }
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
  int _selectedAccountType = 0;

  int get selectedAccountType => _selectedAccountType;

  void setAccountType(int index) {
    _selectedAccountType = index;
    notifyListeners();
  }


  Future<void> refreshData() async {
    setBusy(true);
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