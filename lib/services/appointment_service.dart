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
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if time slot is already booked (exclude canceled appointments)
      final isBooked = await isTimeSlotBooked(
        doctorId: doctorId,
        date: date,
        timeSlot: timeSlot,
      );

      if (isBooked) {
        throw Exception('This time slot is already booked');
      }

      final appointmentData = {
        'userId': currentUserId,
        'clinicId': clinicId,
        'doctorId': doctorId,
        'date': Timestamp.fromDate(date),
        'timeSlot': timeSlot,
        'serviceName': serviceName,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('appointments')
          .add(appointmentData);

      print('✅ Appointment created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating appointment: $e');
      rethrow;
    }
  }

  /// Reschedule an existing appointment (NEW)
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String doctorId,
    required DateTime newDate,
    required String newTimeSlot,
  }) async {
    try {
      // Check if the new time slot is available
      final isBooked = await isTimeSlotBooked(
        doctorId: doctorId,
        date: newDate,
        timeSlot: newTimeSlot,
        excludeAppointmentId: appointmentId, // Don't check against itself
      );

      if (isBooked) {
        throw Exception('This time slot is already booked');
      }

      // Update the appointment
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'date': Timestamp.fromDate(newDate),
        'timeSlot': newTimeSlot,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Appointment $appointmentId rescheduled to ${newDate.toLocal()} at $newTimeSlot');
    } catch (e) {
      print('❌ Error rescheduling appointment: $e');
      rethrow;
    }
  }

  /// Check if a time slot is already booked (UPDATED - can exclude specific appointment)
  Future<bool> isTimeSlotBooked({
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    String? excludeAppointmentId, // NEW: Skip checking this appointment
  }) async {
    try {
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

      // If excluding an appointment (for rescheduling), filter it out
      if (excludeAppointmentId != null) {
        final filteredDocs = querySnapshot.docs
            .where((doc) => doc.id != excludeAppointmentId)
            .toList();
        return filteredDocs.isNotEmpty;
      }

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking time slot: $e');
      return false;
    }
  }

  /// Get booked time slots for a specific doctor on a specific date (UPDATED)
  Future<List<String>> getBookedTimeSlots({
    required String doctorId,
    required DateTime date,
    String? excludeAppointmentId, // NEW: For rescheduling
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

      var bookedSlots = querySnapshot.docs
          .map((doc) => doc.data()['timeSlot'] as String)
          .toList();

      // If excluding an appointment (for rescheduling), remove its slot
      if (excludeAppointmentId != null) {
        final excludedDoc = querySnapshot.docs
            .firstWhere((doc) => doc.id == excludeAppointmentId, 
                orElse: () => throw Exception('Appointment not found'));
        final excludedSlot = excludedDoc.data()['timeSlot'] as String?;
        if (excludedSlot != null) {
          bookedSlots.remove(excludedSlot);
        }
      }

      print('✅ Fetched ${bookedSlots.length} booked time slots for doctor $doctorId on ${date.toLocal()}');
      return bookedSlots;
    } catch (e) {
      print('❌ Error fetching booked time slots: $e');
      return [];
    }
  }

  /// Get all appointments for current user
  Future<List<AppointmentModel>> getUserAppointments() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: currentUserId)
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
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: currentUserId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('status', whereIn: ['pending', 'confirmed'])
          .orderBy('date')
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching upcoming appointments: $e');
      return [];
    }
  }

  /// Get past appointments for current user
  Future<List<AppointmentModel>> getPastAppointments() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: currentUserId)
          .where('date', isLessThan: Timestamp.fromDate(now))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching past appointments: $e');
      return [];
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
      return [];
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
      return [];
    }
  }

  /// Stream user appointments for real-time updates
  Stream<List<AppointmentModel>> getUserAppointmentsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: currentUserId)
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

      print('✅ Appointment $appointmentId status updated to: $status');
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
    try {
      await updateAppointmentStatus(
        appointmentId: appointmentId,
        status: 'canceled',
        cancellationReason: reason,
      );
      print('✅ Appointment $appointmentId canceled');
    } catch (e) {
      print('❌ Error canceling appointment: $e');
      rethrow;
    }
  }
}