class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String dob;
  final double walletBalanceNGN;
  final DateTime? createdAt;
  final bool isProfileComplete;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.dob,
    this.walletBalanceNGN = 0.0,
    this.createdAt,
    this.isProfileComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final walletValue = json['walletBalanceNGN'];
    double balance;

    if (walletValue is int) {
      balance = walletValue.toDouble();
    } else if (walletValue is double) {
      balance = walletValue;
    } else if (walletValue is String) {
      balance = double.tryParse(walletValue) ?? 0.0;
    } else {
      balance = 0.0;
    }

    DateTime? createdAt;
    final createdAtValue = json['createdAt'];
    if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else if (createdAtValue != null) {
      createdAt = DateTime.tryParse(createdAtValue.toString());
    }

    return UserModel(
      uid: json['uid']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      walletBalanceNGN: balance,
      createdAt: createdAt,
      isProfileComplete: json['isProfileComplete'] is bool
          ? json['isProfileComplete'] as bool
          : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'dob': dob,
      'walletBalanceNGN': walletBalanceNGN,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'isProfileComplete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? dob,
    double? walletBalanceNGN,
    DateTime? createdAt,
    bool? isProfileComplete,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      walletBalanceNGN: walletBalanceNGN ?? this.walletBalanceNGN,
      createdAt: createdAt ?? this.createdAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
