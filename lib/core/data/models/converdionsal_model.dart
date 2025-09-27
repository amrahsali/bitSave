/// Model for conversion result from Mavapay API
class MavapayConversionResult {
  final String conversionId;
  final String fromCurrency;
  final String toCurrency;
  final double fromAmount;
  final double toAmount;
  final double exchangeRate;
  final double fee;
  final DateTime createdAt;
  final String status;

  MavapayConversionResult({
    required this.conversionId,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
    required this.fee,
    required this.createdAt,
    required this.status,
  });

  factory MavapayConversionResult.fromJson(Map<String, dynamic> json) {
    return MavapayConversionResult(
      conversionId: json['conversion_id'] ?? json['id'] ?? '',
      fromCurrency: json['from_currency'] ?? '',
      toCurrency: json['to_currency'] ?? '',
      fromAmount: (json['from_amount'] ?? 0.0).toDouble(),
      toAmount: (json['to_amount'] ?? 0.0).toDouble(),
      exchangeRate: (json['exchange_rate'] ?? 0.0).toDouble(),
      fee: (json['fee'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversion_id': conversionId,
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'from_amount': fromAmount,
      'to_amount': toAmount,
      'exchange_rate': exchangeRate,
      'fee': fee,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}