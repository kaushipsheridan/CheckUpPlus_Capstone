import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkupplus_capstone/models/clinic_model.dart';

class ClinicService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get clinic by ID
  Future<ClinicModel?> getClinic(String clinicId) async {
    try {
      final doc = await _firestore
          .collection('clinics')
          .doc(clinicId)
          .get();

      if (!doc.exists) {
        print('⚠️ Clinic not found: $clinicId');
        return null;
      }

      return ClinicModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error fetching clinic: $e');
      return null;
    }
  }

  /// Get all clinics
  Future<List<ClinicModel>> getAllClinics() async {
    try {
      final querySnapshot = await _firestore
          .collection('clinics')
          .get();

      return querySnapshot.docs
          .map((doc) => ClinicModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching clinics: $e');
      return [];
    }
  }

  /// Get clinics by specialty
  Future<List<ClinicModel>> getClinicsBySpecialty(String specialty) async {
    try {
      final querySnapshot = await _firestore
          .collection('clinics')
          .where('specialty', isEqualTo: specialty)
          .get();

      final clinics = querySnapshot.docs
          .map((doc) => ClinicModel.fromFirestore(doc))
          .toList();

      print('✅ Fetched ${clinics.length} clinics with specialty: $specialty');
      return clinics;
    } catch (e) {
      print('❌ Error fetching clinics by specialty: $e');
      return [];
    }
  }

  /// Search clinics by name
  Future<List<ClinicModel>> searchClinics(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('clinics')
          .get();

      // Filter locally (Firestore doesn't support case-insensitive search)
      final clinics = querySnapshot.docs
          .map((doc) => ClinicModel.fromFirestore(doc))
          .where((clinic) => 
              clinic.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      print('✅ Found ${clinics.length} clinics matching: $query');
      return clinics;
    } catch (e) {
      print('❌ Error searching clinics: $e');
      return [];
    }
  }

  /// Stream clinics for real-time updates
  Stream<List<ClinicModel>> getClinicsStream() {
    return _firestore
        .collection('clinics')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClinicModel.fromFirestore(doc))
            .toList());
  }
}