class UserModel {

/// Wondering if I should import something here, just for the sake of it.🤣


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
    this.walletBalanceNGN = 0.0, // Defaults to empty wallet for MVP deposit
    this.createdAt,
    this.isProfileComplete = false,
  });

  /// Factory constructor to create a UserModel DTO from Firestore JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      dob: json['dob'] ?? '',
      // Ensure we safely parse integers or doubles from JSON into a double
      walletBalanceNGN: (json['walletBalanceNGN'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }

  /// Converts the current UserModel instance into a JSON Map for Firestore writes
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

  /// Optional but highly recommended helper method to quickly clone a user object 
  /// with modified values (e.g., when updating wallet balance after a deposit webhook)
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