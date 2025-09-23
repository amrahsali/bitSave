class GuestInviteModel {
   String? user;
   String? apartment;
   String? name;
   String? arrivalDate;
   DurationModel? duration;
   String? status;
   String? inviteType;
   String? inviteCode;
   String? id;
   String? createdAt;
   String? updatedAt;

  GuestInviteModel({
    this.user,
    this.apartment,
    this.name,
    this.arrivalDate,
    this.duration,
    this.status,
    this.inviteType,
    this.inviteCode,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory GuestInviteModel.fromJson(Map<String, dynamic> json) {
    return GuestInviteModel(
      user: json['user'] ?? '',
      apartment: json['apartment'] ?? '',
      name: json['name'] ?? '',
      arrivalDate: json['arrival_date'] ?? '',
      duration: json['duration'] != null ? DurationModel.fromJson(json['duration']) : null,
      status: json['status'] ?? '',
      inviteType: json['invite_type'] ?? '',
      inviteCode: json['invite_code'] ?? '',
      id: json['_id'] ?? '',
      createdAt:  json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class DurationModel {
  String? startTime;
  String? endTime;
  String? id;

  DurationModel({
    this.startTime,
    this.endTime,
    this.id,
  });

  factory DurationModel.fromJson(Map<String, dynamic> json) {
    return DurationModel(
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}
