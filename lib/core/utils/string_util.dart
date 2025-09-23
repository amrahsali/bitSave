
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../data/models/media_model.dart';

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text; // Return the same if empty
  return text[0].toUpperCase() + text.substring(1);
}

String formatDate(dynamic date) {
  if (date == null) return "N/A"; // Handle null values
  if (date is String) {
    try {
      DateTime parsedDate = DateTime.parse(date).toLocal();
      return DateFormat("dd MMM, yyyy").format(parsedDate); // Example: 12 Mar, 2024
    } catch (e) {
      return "Invalid Date";
    }
  } else if (date is DateTime) {
    return DateFormat("dd MMM, yyyy").format(date);
  }
  return "N/A"; // Default fallback
}

ImageProvider getProfileImage(BinaryData? picture) {
  if (picture != null) {
    if (picture.data != null && picture.data!.isNotEmpty) {
      // Handle binary data (List<int>)
      Uint8List imageData = Uint8List.fromList(picture.data!);
      return MemoryImage(imageData);
    } else if (picture.externalReferencePath != null && picture.externalReferencePath!.isNotEmpty) {
      // Handle URL-based images
      return NetworkImage(picture.externalReferencePath!);
    }
  }
  // Fallback to default profile image
  return const AssetImage('assets/images/profile_image.png');
}

Uint8List decodeBase64Image(String base64String) {
  return base64Decode(base64String);
}

String calculateDutyTime(String? lastLoggedIn) {
  if (lastLoggedIn == null) return "00:00";

  DateTime lastLoginTime = DateTime.parse(lastLoggedIn);
  DateTime currentTime = DateTime.now();

  Duration difference = currentTime.difference(lastLoginTime);

  int hours = difference.inHours;
  int minutes = difference.inMinutes.remainder(60);

  return "${hours}H:${minutes}M";
}

