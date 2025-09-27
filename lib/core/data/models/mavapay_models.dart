/// Models for Mavapay API responses and requests

class MavapayBalance {
  final double nairaBalance;
  final double bitcoinBalance;
  final double bitcoinBalanceInSats;
  final DateTime lastUpdated;

  MavapayBalance({
    required this.nairaBalance,
    required this.bitcoinBalance,
    required this.bitcoinBalanceInSats,
    required this.lastUpdated,
  });

  factory MavapayBalance.fromJson(Map<String, dynamic> json) {
    return MavapayBalance(
      nairaBalance: (json['naira_balance'] ?? 0.0).toDouble(),
      bitcoinBalance: (json['bitcoin_balance'] ?? 0.0).toDouble(),
      bitcoinBalanceInSats: (json['bitcoin_balance_sats'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'naira_balance': nairaBalance,
      'bitcoin_balance': bitcoinBalance,
      'bitcoin_balance_sats': bitcoinBalanceInSats,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class MavapayTransaction {
  final String id;
  final String type; // 'deposit', 'withdrawal', 'conversion'
  final double amount;
  final String currency;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  MavapayTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.metadata,
  });

  factory MavapayTransaction.fromJson(Map<String, dynamic> json) {
    return MavapayTransaction(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class MavapayExchangeRate {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime lastUpdated;

  MavapayExchangeRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.lastUpdated,
  });

  factory MavapayExchangeRate.fromJson(Map<String, dynamic> json) {
    return MavapayExchangeRate(
      fromCurrency: json['from_currency'] ?? '',
      toCurrency: json['to_currency'] ?? '',
      rate: (json['rate'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'rate': rate,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class MavapayConversionResult {
  final String transactionId;
  final double fromAmount;
  final String fromCurrency;
  final double toAmount;
  final String toCurrency;
  final double exchangeRate;
  final double fees;
  final DateTime createdAt;

  MavapayConversionResult({
    required this.transactionId,
    required this.fromAmount,
    required this.fromCurrency,
    required this.toAmount,
    required this.toCurrency,
    required this.exchangeRate,
    required this.fees,
    required this.createdAt,
  });

  factory MavapayConversionResult.fromJson(Map<String, dynamic> json) {
    return MavapayConversionResult(
      transactionId: json['transaction_id'] ?? '',
      fromAmount: (json['from_amount'] ?? 0.0).toDouble(),
      fromCurrency: json['from_currency'] ?? '',
      toAmount: (json['to_amount'] ?? 0.0).toDouble(),
      toCurrency: json['to_currency'] ?? '',
      exchangeRate: (json['exchange_rate'] ?? 0.0).toDouble(),
      fees: (json['fees'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'from_amount': fromAmount,
      'from_currency': fromCurrency,
      'to_amount': toAmount,
      'to_currency': toCurrency,
      'exchange_rate': exchangeRate,
      'fees': fees,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Utility class for currency conversions
class CurrencyConverter {
  /// Convert Naira to Satoshis using current exchange rate
  static double nairaToSats(double nairaAmount, double btcToNgnRate) {
    // 1 BTC = 100,000,000 sats
    // So: Naira -> BTC -> Sats
    final btcAmount = nairaAmount / btcToNgnRate;
    return btcAmount * 100000000; // Convert BTC to sats
  }

  /// Convert Satoshis to Naira using current exchange rate
  static double satsToNaira(double satsAmount, double btcToNgnRate) {
    // 1 BTC = 100,000,000 sats
    // So: Sats -> BTC -> Naira
    final btcAmount = satsAmount / 100000000; // Convert sats to BTC
    return btcAmount * btcToNgnRate;
  }

  /// Convert Satoshis to Bitcoin
  static double satsToBitcoin(double satsAmount) {
    return satsAmount / 100000000;
  }

  /// Convert Bitcoin to Satoshis
  static double bitcoinToSats(double btcAmount) {
    return btcAmount * 100000000;
  }
}
