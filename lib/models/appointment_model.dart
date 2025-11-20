import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String? id; // Document ID from Firestore
  final String userId;
  final String clinicId;
  final String doctorId;
  final DateTime date;
  final String timeSlot;
  final String serviceName;
  final String status; // "pending", "confirmed", "canceled", "completed"
  final String? cancellationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppointmentModel({
    this.id,
    required this.userId,
    required this.clinicId,
    required this.doctorId,
    required this.date,
    required this.timeSlot,
    required this.serviceName,
    this.status = 'pending',
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
  });

  /// Create AppointmentModel from Firestore DocumentSnapshot
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppointmentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      clinicId: data['clinicId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      serviceName: data['serviceName'] ?? '',
      status: data['status'] ?? 'pending',
      cancellationReason: data['cancellationReason'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Convert AppointmentModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'clinicId': clinicId,
      'doctorId': doctorId,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'serviceName': serviceName,
      'status': status,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? clinicId,
    String? doctorId,
    DateTime? date,
    String? timeSlot,
    String? serviceName,
    String? status,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clinicId: clinicId ?? this.clinicId,
      doctorId: doctorId ?? this.doctorId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if appointment is in the past
  bool get isPast => date.isBefore(DateTime.now());

  /// Check if appointment is upcoming
  bool get isUpcoming => date.isAfter(DateTime.now()) && 
      (status == 'pending' || status == 'confirmed');

  /// Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Get formatted date string (e.g., "Nov 21, 2025")
  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Get formatted time from timeSlot (e.g., "14:00" -> "2:00 PM")
  String get formattedTime {
    final parts = timeSlot.split(':');
    if (parts.length != 2) return timeSlot;
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  /// Get status color based on appointment status
  String get statusColor {
    switch (status) {
      case 'confirmed':
        return '#4CAF50'; // Green
      case 'pending':
        return '#FFC107'; // Amber
      case 'canceled':
        return '#F44336'; // Red
      case 'completed':
        return '#2196F3'; // Blue
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Get user-friendly status text
  String get statusText {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'canceled':
        return 'Canceled';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'AppointmentModel(id: $id, userId: $userId, clinicId: $clinicId, '
           'doctorId: $doctorId, date: $date, timeSlot: $timeSlot, '
           'serviceName: $serviceName, status: $status)';
  }
}