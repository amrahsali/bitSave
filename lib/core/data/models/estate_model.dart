
import 'package:estate360Security/core/data/models/user_model.dart';

class Address {
  int? id;
  String? block;
  String? street;
  String? city;
  String? state;
  String? postalCode;
  String? country;

  Address({
    this.id,
    this.block,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      block: json['block'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'block': block,
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    };
  }
}

class Estate {
  int? id;
  String name;
  Address? address;
  int? numberOfUnits;
  String? amenities;
  String? registrationNumber;
  String? landCertificateNumber;
  User? estateManager;

  Estate({
    this.id,
    required this.name,
    this.address,
    this.numberOfUnits,
    this.amenities,
    this.registrationNumber,
    this.landCertificateNumber,
    this.estateManager,
  });

  factory Estate.fromJson(Map<String, dynamic> json) {
    return Estate(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      numberOfUnits: json['number_of_units'],
      amenities: json['amenities'],
      registrationNumber: json['registration_number'],
      landCertificateNumber: json['land_certificate_number'],
      estateManager:
      json['estate_manager'] != null ? User.fromJson(json['estate_manager']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address?.toJson(),
      'number_of_units': numberOfUnits,
      'amenities': amenities,
      'registration_number': registrationNumber,
      'land_certificate_number': landCertificateNumber,
      'estate_manager': estateManager?.toJson(),
    };
  }
}

