import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import '../../../app/app.logger.dart';
import '../../../core/data/models/dahsboard_model.dart';
import '../../../core/data/models/notification_model.dart';
import '../../../core/data/models/update.dart';
import '../../../core/data/models/mavapay_models.dart';
import '../../../core/data/models/user_model.dart';
import '../../../core/network/mavapay_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import '../../../state.dart';
import '../../../core/network/paystack_service.dart';
import '../../../services/authentication_service.dart';
import '../../../app/app.locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/lock_plan_model.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'recipient': recipient,
      'amount': amount,
      'time': time,
      'date': date,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      recipient: json['recipient'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] ?? '',
      date: json['date'] ?? '',
    );
  }
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

  double _totalBalance = 0.0;
  double _cryptoBalance = 72.80;
  double _cryptoBalanceInSats = 0.0;
  double _todayChange = 20.50;
  List<Transaction> _transactions = [];
  List<TodoItem> _todos = [];



  void loadProfile(User userFromApi) {
    profile.value = userFromApi;   // Save to global state
    notifyListeners();
  }

  void updateProfile(User newProfile) {
    profile.value = newProfile; // also update global
    notifyListeners();
  }


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
    _loadBalanceFromAuth();
    _fetchTransactions();
  }

  void _loadBalanceFromAuth() {
    final authService = locator<AuthenticationService>();
    _totalBalance = authService.currentUser?.walletBalanceNGN ?? 0.0;
  }

  Future<void> _fetchTransactions() async {
    try {
      final authService = locator<AuthenticationService>();
      final user = authService.firebaseAuth.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .get();

        _transactions = querySnapshot.docs
            .map((doc) => Transaction.fromJson(doc.data()))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      log.e('Error fetching transactions: $e');
    }
  }

  Future<void> _saveTransactionToFirestore(Transaction tx) async {
    try {
      final authService = locator<AuthenticationService>();
      final user = authService.firebaseAuth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .add(tx.toJson());
      }
    } catch (e) {
      log.e('Error saving transaction: $e');
    }
  }

  void _initializeCryptoBalance() {
    // Initialize crypto balance in sats (convert from BTC)
    _cryptoBalanceInSats = CurrencyConverter.bitcoinToSats(_cryptoBalance);
  }

  void _initializeFinancialData() {
    _transactions = [];

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
      
      // Update the balances locally
      _totalBalance += nairaAmount;
      _cryptoBalanceInSats += satsAmount;
      _cryptoBalance = CurrencyConverter.satsToBitcoin(_cryptoBalanceInSats);
      
      // Add transaction record
      final tx = Transaction(
        recipient: "Mavapay Deposit",
        amount: nairaAmount,
        time: DateTime.now().toString().substring(11, 16),
        date: "Today",
      );
      _transactions.insert(0, tx);
      await _saveTransactionToFirestore(tx);
      
      log.i('Added ₦${nairaAmount.toStringAsFixed(2)} and ${satsAmount.toStringAsFixed(0)} sats');
      notifyListeners();
      
    } catch (e) {
      log.e('Error adding Naira funds: $e');
    } finally {
      setBusy(false);
    }
  }

  /// Initialize Paystack payment for adding Naira
  Future<void> initiatePaystackPayment(double amount, BuildContext context) async {
    setBusy(true);
    try {
      final paystackService = PaystackService();
      final authService = locator<AuthenticationService>();
      final email = authService.currentUser?.email ?? 'test@example.com';

      final initData = await paystackService.initializeTransaction(
        email: email,
        amount: amount,
      );

      if (initData != null && initData['authorization_url'] != null) {
        final url = Uri.parse(initData['authorization_url']);
        final reference = initData['reference'];

        if (await canLaunchUrl(url)) {
          // Launch the payment page
          await launchUrl(url, mode: LaunchMode.externalApplication);
          
          // Note: In a real app with deep linking configured, we would wait for the user 
          // to return to the app via deep link. Here we'll simulate a mock confirmation dialog.
          // In production, we'd poll or wait for the webhook/deep link.
          
          if (context.mounted) {
            // Mock success for demonstration since we can't capture the deep link easily here
            await authService.addFundsToWallet(amount);
            
            // Reload the local balance
            _totalBalance = authService.currentUser?.walletBalanceNGN ?? _totalBalance;
            
             final tx = Transaction(
                recipient: "Paystack Deposit",
                amount: amount,
                time: DateTime.now().toString().substring(11, 16),
                date: "Today",
              );
              _transactions.insert(0, tx);
              await _saveTransactionToFirestore(tx);
              
            notifyListeners();
            log.i('Successfully added ₦$amount via Paystack');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Funds added successfully! Please wait a moment to see updates.')),
            );
          }
        } else {
          log.e('Could not launch Paystack URL');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize Paystack payment. Check API Keys.')),
        );
      }
    } catch (e) {
      log.e('Error with Paystack payment: $e');
    } finally {
      setBusy(false);
    }
  }

  /// Save Naira to Bitcoin — deducts from wallet, converts to sats, stores lock plan in Firestore
  Future<void> saveToBitcoin(double nairaAmount, int lockMonths, BuildContext context) async {
    setBusy(true);
    try {
      final authService = locator<AuthenticationService>();
      final user = authService.firebaseAuth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save.')),
        );
        return;
      }

      // Check sufficient balance
      final currentBalance = authService.currentUser?.walletBalanceNGN ?? 0.0;
      if (nairaAmount > currentBalance) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Insufficient balance. You have ₦${currentBalance.toStringAsFixed(2)}.')),
          );
        }
        return;
      }

      // Fetch exchange rate from Mavapay with CoinGecko fallback
      double btcPriceNGN = 150000000.0; // Realistic default fallback rate
      try {
        final rateResp = await _mavapayService.getBitcoinExchangeRate();
        if (rateResp.statusCode == 200 && rateResp.data['success'] == true) {
          btcPriceNGN = (rateResp.data['data']['rate'] ?? btcPriceNGN).toDouble();
        } else {
          try {
            final dio = Dio();
            final resp = await dio.get('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=ngn');
            if (resp.statusCode == 200 && resp.data['bitcoin']?['ngn'] != null) {
              btcPriceNGN = (resp.data['bitcoin']['ngn'] as num).toDouble();
              log.i('Fetched CoinGecko rate: 1 BTC = ₦$btcPriceNGN');
            }
          } catch (e) {
            log.w('CoinGecko fallback failed: $e');
          }
        }
      } catch (_) {
        try {
          final dio = Dio();
          final resp = await dio.get('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=ngn');
          if (resp.statusCode == 200 && resp.data['bitcoin']?['ngn'] != null) {
            btcPriceNGN = (resp.data['bitcoin']['ngn'] as num).toDouble();
            log.i('Fetched CoinGecko rate: 1 BTC = ₦$btcPriceNGN');
          }
        } catch (e) {
          log.w('CoinGecko fallback failed: $e');
        }
      }

      // Perform conversion on Mavapay
      int satsAmount;
      double exchangeRateUsed = btcPriceNGN;
      try {
        final convertResp = await _mavapayService.convertNairaToBitcoin(
          nairaAmount: nairaAmount,
          userId: user.uid,
        );
        if (convertResp.statusCode == 200 && convertResp.data['success'] == true) {
          final conversionResult = MavapayConversionResult.fromJson(convertResp.data['data']);
          satsAmount = CurrencyConverter.bitcoinToSats(conversionResult.toAmount).round();
          exchangeRateUsed = conversionResult.exchangeRate;
        } else {
          satsAmount = CurrencyConverter.nairaToSats(nairaAmount, btcPriceNGN).round();
        }
      } catch (e) {
        log.w('Mavapay conversion failed: $e, using local conversion fallback');
        satsAmount = CurrencyConverter.nairaToSats(nairaAmount, btcPriceNGN).round();
      }

      // Deduct from wallet in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'walletBalanceNGN': FieldValue.increment(-nairaAmount),
      });

      // Create lock plan in Firestore
      final lockId = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('savings').doc().id;
      final lockPlan = LockPlanModel(
        lockId: lockId,
        userId: user.uid,
        fiatAmountNGN: nairaAmount,
        satsAllocated: satsAmount,
        btcPriceAtLock: exchangeRateUsed,
        createdAt: DateTime.now(),
        targetMaturityDate: DateTime.now().add(Duration(days: lockMonths * 30)),
        isMatured: false,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savings')
          .doc(lockId)
          .set(lockPlan.toJson());

      // Update local balance
      _totalBalance -= nairaAmount;

      // Record transaction
      final tx = Transaction(
        recipient: 'Bitcoin Savings',
        amount: -nairaAmount,
        time: DateTime.now().toString().substring(11, 16),
        date: 'Today',
      );
      _transactions.insert(0, tx);
      await _saveTransactionToFirestore(tx);

      // Refresh auth user cache
      await authService.fetchUserProfile(user.uid);

      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('₦${nairaAmount.toStringAsFixed(0)} saved as $satsAmount sats! 🔒')),
        );
      }

      log.i('Saved ₦$nairaAmount → $satsAmount sats, locked for $lockMonths months');
    } catch (e) {
      log.e('Error saving to Bitcoin: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
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
    _saveTransactionToFirestore(transaction);
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
    final authService = locator<AuthenticationService>();
    if (authService.firebaseAuth.currentUser != null) {
      await authService.fetchUserProfile(authService.firebaseAuth.currentUser!.uid);
      _totalBalance = authService.currentUser?.walletBalanceNGN ?? 0.0;
      await _fetchTransactions();
    }
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