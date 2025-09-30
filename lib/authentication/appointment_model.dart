import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

// --- DATA MODEL AND MOCK DATA ---

/// Enum defining the possible status states of an appointment.
enum AppointmentStatus { upcoming, completed, canceled, missed }

/// Data class representing a single appointment.
class Appointment {
  final String id;
  final DateTime date;
  final TimeOfDay time;
  final String serviceName;
  final String doctorName;
  final AppointmentStatus status;
  final String? cancellationReason;

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    required this.serviceName,
    required this.doctorName,
    required this.status,
    this.cancellationReason,
  });

  /// Helper getter to format the date string.
  String get formattedDate => '${date.month}/${date.day}/${date.year}';
  
  /// Helper getter to format the time string.
  String get formattedTime {
     // FIX: Using the robust method (intl package) to format time.
    // 1. Combine the TimeOfDay with today's date to create a full DateTime object.
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    // 2. Use DateFormat.jm() for locale-sensitive time formatting (e.g., "10:30 AM").
    return DateFormat.jm().format(dt); 
  }
}

/// Mock Data Source for initial UI development.
final List<Appointment> mockAppointments = [
  // Upcoming
  Appointment(
    id: 'U1',
    date: DateTime.now().add(const Duration(days: 3)),
    time: const TimeOfDay(hour: 10, minute: 30),
    serviceName: 'General Checkup',
    doctorName: 'Dr. Jane Doe',
    status: AppointmentStatus.upcoming,
  ),
  Appointment(
    id: 'U2',
    date: DateTime.now().add(const Duration(days: 10)),
    time: const TimeOfDay(hour: 14, minute: 0),
    serviceName: 'Dental Cleaning',
    doctorName: 'Dr. Alex Smith',
    status: AppointmentStatus.upcoming,
  ),
  // Completed
  Appointment(
    id: 'C1',
    date: DateTime.now().subtract(const Duration(days: 5)),
    time: const TimeOfDay(hour: 9, minute: 0),
    serviceName: 'Physiotherapy Session',
    doctorName: 'Dr. Emily Carter',
    status: AppointmentStatus.completed,
  ),
  // Canceled/Missed
  Appointment(
    id: 'X1',
    date: DateTime.now().subtract(const Duration(days: 15)),
    time: const TimeOfDay(hour: 11, minute: 0),
    serviceName: 'Eye Exam',
    doctorName: 'Dr. Ben Johnson',
    status: AppointmentStatus.canceled,
    cancellationReason: 'Clinic scheduling conflict.',
  ),
  Appointment(
    id: 'X2',
    date: DateTime.now().subtract(const Duration(days: 1)),
    time: const TimeOfDay(hour: 16, minute: 0),
    serviceName: 'Vaccination',
    doctorName: 'Dr. Maria Garcia',
    status: AppointmentStatus.missed,
    cancellationReason: 'Patient did not attend.',
  ),
];
