class LockPlanModel {
  final String lockId;
  final String userId;
  final double fiatAmountNGN;
  final int satsAllocated;
  final double btcPriceAtLock;
  final DateTime createdAt;
  final DateTime targetMaturityDate;
  final bool isMatured;

  LockPlanModel({
    required this.lockId,
    required this.userId,
    required this.fiatAmountNGN,
    required this.satsAllocated,
    required this.btcPriceAtLock,
    required this.createdAt,
    required this.targetMaturityDate,
    this.isMatured = false,
  });

  factory LockPlanModel.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) return DateTime.parse(v);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is Map) {
        if (v['seconds'] != null) {
          return DateTime.fromMillisecondsSinceEpoch((v['seconds'] as int) * 1000);
        }
      }
      return DateTime.now();
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString().split('.').first) ?? 0;
    }

    return LockPlanModel(
      lockId: json['lockId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fiatAmountNGN: _toDouble(json['fiatAmountNGN']),
      satsAllocated: _toInt(json['satsAllocated']),
      btcPriceAtLock: _toDouble(json['btcPriceAtLock']),
      createdAt: _parseDate(json['createdAt']),
      targetMaturityDate: _parseDate(json['targetMaturityDate']),
      isMatured: json['isMatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'lockId': lockId,
        'userId': userId,
        'fiatAmountNGN': fiatAmountNGN,
        'satsAllocated': satsAllocated,
        'btcPriceAtLock': btcPriceAtLock,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'targetMaturityDate': targetMaturityDate.toUtc().toIso8601String(),
        'isMatured': isMatured,
      };
}
