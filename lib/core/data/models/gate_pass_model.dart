class GatePassModel {
  final VisitorModel? visitor;
  final ResidentModel resident;
  final String status;
  final bool used;
  final String code;
  final String passExpiryDate;
  final String passIssueDate;

  GatePassModel({
    required this.visitor,
    required this.resident,
    required this.status,
    required this.used,
    required this.code,
    required this.passExpiryDate,
    required this.passIssueDate,
  });

  factory GatePassModel.fromJson(Map<String, dynamic> json) {
    return GatePassModel(
      visitor: json['visitor'] != null ? VisitorModel.fromJson(json['visitor']) : null,
      resident: ResidentModel.fromJson(json['resident']),
      status: json['status'] ?? "UNKNOWN",
      used: json['used'] ?? false,
      code: json['code'] ?? "",
      passExpiryDate: json['passExpiryDate'] ?? "",
      passIssueDate: json['passIssueDate'] ?? "",
    );
  }
}

class VisitorModel {
  final int id;
  final String name;
  final String phone;
  final String visitStatus;
  final String imageUrl;


  VisitorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.visitStatus,
    required this.imageUrl,

  });

factory VisitorModel.fromJson(Map<String, dynamic> json) {

    return VisitorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "Unknown",
      phone: json['phone'] ?? "N/A",
      visitStatus: json['visitStatus'] ?? "UNKNOWN",
      imageUrl: json['imageUrl'] ?? "",

    );
  }
}

class ResidentModel {
  final int id;
  final String firstName;
  final String lastName;
  final String houseNumber;
  final String houseDescription;
  final String phone;
  final String pictureUrl;

  ResidentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.houseNumber,
    required this.phone,
    required this.houseDescription,
    required this.pictureUrl,
  });

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? "Unknown",
      lastName: json['lastName'] ?? "",
      houseNumber: json['houseNumber'] ?? "N/A",
      houseDescription: json['houseDescription'] ?? "N/A",
      phone: json['phone'] ?? "N/A",
      pictureUrl: json['picture']?['url'] ?? "",
    );
  }
}
