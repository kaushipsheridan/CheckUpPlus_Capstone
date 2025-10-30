import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/clinic_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<LatLng> getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception("Location permission denied");
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting user location: $e');
      return const LatLng(43.6709, -79.7396);
    }
  }

  Future<List<Clinic>> getClinics() async {
    try {
      final snapshot = await _firestore.collection('clinics').get();

      return snapshot.docs.map((doc) {
        return Clinic.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error fetching clinics: $e');
      return [];
    }
  }

  //We are using Haversine formula
  double calculateDistanceKm(LatLng user, LatLng clinic) {
    const R = 6371;
    final dLat = (clinic.latitude - user.latitude) * pi / 180;
    final dLon = (clinic.longitude - user.longitude) * pi / 180;

    final lat1 = user.latitude * pi / 180;
    final lat2 = clinic.latitude * pi / 180;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  Future<List<Map<String, dynamic>>> getNearbyClinics(
    LatLng userLocation,
    double maxDistanceKm,
  ) async {
    final clinics = await getClinics();

    final nearby = clinics
        .map(
          (clinic) => {
            'clinic': clinic,
            'distanceKm': calculateDistanceKm(
              userLocation,
              LatLng(clinic.lat, clinic.lng),
            ),
          },
        )
        .where(
          (item) =>
              (item['distanceKm'] as double?) != null &&
              (item['distanceKm'] as double) <= maxDistanceKm,
        )
        .toList();

    nearby.sort(
      (a, b) =>
          (a['distanceKm'] as double).compareTo(b['distanceKm'] as double),
    );

    return nearby;
  }
}
