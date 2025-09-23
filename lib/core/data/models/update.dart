class UpdateModel {
  final String name;
  final String description;
  final String time;
  final String status;

  UpdateModel({
    required this.name,
    required this.description,
    required this.time,
    required this.status,
  });

  /// ✅ Factory constructor for JSON deserialization
  factory UpdateModel.fromJson(Map<String, dynamic> json) {
    return UpdateModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
    );
  }

  /// ✅ Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'time': time,
      'status': status,
    };
  }
}
