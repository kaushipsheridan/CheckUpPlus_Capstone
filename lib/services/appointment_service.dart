import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:checkupplus_capstone/models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Create a new appointment
  Future<String> createAppointment({
    required String clinicId,
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    required String serviceName,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if time slot is available
      final isAvailable = await isTimeSlotAvailable(
        doctorId: doctorId,
        date: date,
        timeSlot: timeSlot,
      );

      if (!isAvailable) {
        throw Exception('This time slot is already booked');
      }

      // Create appointment model
      final appointment = AppointmentModel(
        userId: userId,
        clinicId: clinicId,
        doctorId: doctorId,
        date: date,
        timeSlot: timeSlot,
        serviceName: serviceName,
        status: 'pending',
      );

      // Save to Firestore
      final docRef = await _firestore
          .collection('appointments')
          .add(appointment.toFirestore());

      print('✅ Appointment created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating appointment: $e');
      rethrow;
    }
  }

  /// Get all appointments for current user
  Future<List<AppointmentModel>> getUserAppointments() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final appointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      print('✅ Fetched ${appointments.length} appointments for user');
      return appointments;
    } catch (e) {
      print('❌ Error fetching user appointments: $e');
      rethrow;
    }
  }

  /// Get upcoming appointments for current user
  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('status', whereIn: ['pending', 'confirmed'])
          .orderBy('date', descending: false)
          .get();

      final appointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      print('✅ Fetched ${appointments.length} upcoming appointments');
      return appointments;
    } catch (e) {
      print('❌ Error fetching upcoming appointments: $e');
      rethrow;
    }
  }

  /// Get past appointments for current user
  Future<List<AppointmentModel>> getPastAppointments() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('date', isLessThan: Timestamp.fromDate(now))
          .orderBy('date', descending: true)
          .get();

      final appointments = querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();

      print('✅ Fetched ${appointments.length} past appointments');
      return appointments;
    } catch (e) {
      print('❌ Error fetching past appointments: $e');
      rethrow;
    }
  }

  /// Get appointments for a specific clinic
  Future<List<AppointmentModel>> getClinicAppointments(String clinicId) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('clinicId', isEqualTo: clinicId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching clinic appointments: $e');
      rethrow;
    }
  }

  /// Get appointments for a specific doctor
  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching doctor appointments: $e');
      rethrow;
    }
  }

  /// Stream user appointments for real-time updates
  Stream<List<AppointmentModel>> getUserAppointmentsStream() {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    String? cancellationReason,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (cancellationReason != null) {
        updateData['cancellationReason'] = cancellationReason;
      }

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update(updateData);

      print('✅ Appointment status updated to: $status');
    } catch (e) {
      print('❌ Error updating appointment status: $e');
      rethrow;
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: 'canceled',
      cancellationReason: reason,
    );
  }

  /// Confirm appointment
  Future<void> confirmAppointment(String appointmentId) async {
    await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: 'confirmed',
    );
  }

  /// Complete appointment
  Future<void> completeAppointment(String appointmentId) async {
    await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: 'completed',
    );
  }

  /// Get single appointment by ID
  Future<AppointmentModel?> getAppointment(String appointmentId) async {
    try {
      final doc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!doc.exists) {
        print('⚠️ Appointment not found: $appointmentId');
        return null;
      }

      return AppointmentModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error fetching appointment: $e');
      return null;
    }
  }

  /// Check if a time slot is already booked for a doctor on a specific date
  Future<bool> isTimeSlotAvailable({
    required String doctorId,
    required DateTime date,
    required String timeSlot,
  }) async {
    try {
      // Get start and end of the day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('❌ Error checking time slot availability: $e');
      return false;
    }
  }

  /// Get booked time slots for a doctor on a specific date
  Future<List<String>> getBookedTimeSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['timeSlot'] as String)
          .toList();
    } catch (e) {
      print('❌ Error fetching booked time slots: $e');
      return [];
    }
  }
}