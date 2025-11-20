import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkupplus_capstone/models/doctor_model.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get doctor by ID
  Future<DoctorModel?> getDoctor(String doctorId) async {
    try {
      final doc = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .get();

      if (!doc.exists) {
        print('⚠️ Doctor not found: $doctorId');
        return null;
      }

      return DoctorModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error fetching doctor: $e');
      return null;
    }
  }

  /// Get all doctors
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .get();

      return querySnapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching doctors: $e');
      return [];
    }
  }

  /// Get doctors by clinic ID
  Future<List<DoctorModel>> getDoctorsByClinic(String clinicId) async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      final doctors = querySnapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc))
          .toList();

      print('✅ Fetched ${doctors.length} doctors for clinic: $clinicId');
      return doctors;
    } catch (e) {
      print('❌ Error fetching doctors by clinic: $e');
      return [];
    }
  }

  /// Get doctors by specialty
  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialty) async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('specialty', isEqualTo: specialty)
          .get();

      final doctors = querySnapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc))
          .toList();

      print('✅ Fetched ${doctors.length} doctors with specialty: $specialty');
      return doctors;
    } catch (e) {
      print('❌ Error fetching doctors by specialty: $e');
      return [];
    }
  }

  /// Search doctors by name
  Future<List<DoctorModel>> searchDoctors(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .get();

      // Filter locally (Firestore doesn't support case-insensitive search)
      final doctors = querySnapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc))
          .where((doctor) => 
              doctor.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      print('✅ Found ${doctors.length} doctors matching: $query');
      return doctors;
    } catch (e) {
      print('❌ Error searching doctors: $e');
      return [];
    }
  }

  /// Stream doctors for real-time updates
  Stream<List<DoctorModel>> getDoctorsStream() {
    return _firestore
        .collection('doctors')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoctorModel.fromFirestore(doc))
            .toList());
  }

  /// Stream doctors by clinic for real-time updates
  Stream<List<DoctorModel>> getDoctorsByClinicStream(String clinicId) {
    return _firestore
        .collection('doctors')
        .where('clinicId', isEqualTo: clinicId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoctorModel.fromFirestore(doc))
            .toList());
  }
}