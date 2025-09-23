
import 'dart:convert';

class BinaryData {
  int? id;
  List<int>? data; // Handling binary data as a List<int> (Uint8List in Flutter)
  String? externalReferencePath;
  String? contentType;
  String? description;
  bool? inUse;
  List<int>? thumbnail; // Also binary data

  BinaryData({
    this.id,
    this.data,
    this.externalReferencePath,
    this.contentType,
    this.description,
    this.inUse,
    this.thumbnail,
  });

  factory BinaryData.fromJson(Map<String, dynamic> json) {
    return BinaryData(
      id: json['id'],
      data: json['data'] != null ? List<int>.from(json['data']) : null,
      externalReferencePath: json['externalReferencePath'],
      contentType: json['contentType'],
      description: json['description'],
      inUse: json['inUse'],
      thumbnail: json['thumbnail'] != null ? List<int>.from(json['thumbnail']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'externalReferencePath': externalReferencePath,
      'contentType': contentType,
      'description': description,
      'inUse': inUse,
      'thumbnail': thumbnail,
    };
  }
}

class Picture {
  final int? id;
  final String? url;
  final String? type;
  final List<int>? data;
  final bool? front;
  final DateTime? createdDate;
  final DateTime? lastModifiedDate;

  Picture({
    this.id,
    this.url,
    this.type,
    this.data,
    this.front,
    this.createdDate,
    this.lastModifiedDate,
  });

  factory Picture.fromJson(Map<String, dynamic> json) {
    return Picture(
      id: json['id'],
      url: json['url'],
      type: json['type'],
      data: json['data'] != null && json['data'] is String
          ? base64Decode(json['data'])
          : null,
      front: json['front'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      lastModifiedDate: json['lastModifiedDate'] != null
          ? DateTime.parse(json['lastModifiedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type,
      'data': data != null ? base64Encode(data!) : null,
      'front': front,
      'createdDate': createdDate?.toIso8601String(),
      'lastModifiedDate': lastModifiedDate?.toIso8601String(),
    };
  }
}

