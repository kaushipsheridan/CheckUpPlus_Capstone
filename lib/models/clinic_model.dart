import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String specialty;
  final double lat;
  final double lng;

  ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.specialty,
    required this.lat,
    required this.lng,
  });

  factory ClinicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['geopoint'] as GeoPoint?;

    return ClinicModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Clinic',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      specialty: data['specialty'] ?? '',
      lat: geoPoint?.latitude ?? 0.0,
      lng: geoPoint?.longitude ?? 0.0,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'specialty': specialty,
      'geopoint': GeoPoint(lat, lng),
    };
  }
}

/// DEPRECATED: Keep old Clinic class for backward compatibility
/// Remove after migrating all code to ClinicModel
class Clinic {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String specialty;
  final double lat;
  final double lng;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.specialty,
    required this.lat,
    required this.lng,
  });

  factory Clinic.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['geopoint'] as GeoPoint?;

    return Clinic(
      id: doc.id,
      name: data['name'] ?? 'Unknown Clinic',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      specialty: data['specialty'] ?? '',
      lat: geoPoint?.latitude ?? 0.0,
      lng: geoPoint?.longitude ?? 0.0,
    );
  }
}