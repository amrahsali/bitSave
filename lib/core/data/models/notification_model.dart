import 'package:intl/intl.dart';

class NotificationModel {
  final int trackerId;
  final int notificationId;
  final String title;
  final String message;
  final DateTime sentAt;
  final String sentBy;
  final String status;
  final String? sentByRole;
  final String notificationType;
  final String approvalStatus;
  final String type;

  NotificationModel({
    required this.trackerId,
    required this.title,
    required this.message,
    required this.sentAt,
    required this.sentBy,
    required this.status,
    required this.notificationType,
    this.sentByRole,
    required this.type,
    this.approvalStatus = 'PENDING',
    required this.notificationId,
  });

  String get formattedSentAt {
    return DateFormat('yyyy-MM-dd  HH:mm').format(sentAt);
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      trackerId: json['trackerId'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      sentAt: DateTime.parse(json['sentAt']),
      sentBy: json['sentBy'] ?? '',
      status: json['status'] ?? 'PENDING',
      notificationType: json['notificationType'] ?? '',
      type: json['type'] ?? 'GENERAL',
      approvalStatus: json['approvalStatus'] ?? 'PENDING',
      notificationId: json['notificationId'] ?? 0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'trackerId': trackerId,
      'title': title,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'sentBy': sentBy,
      'status': status,
      'notificationType': notificationType,
      'type': type,
      'approvalStatus': approvalStatus,
      'notificationId': notificationId,
    };
  }
}
