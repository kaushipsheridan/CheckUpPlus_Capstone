import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 1. Model for a Doctor Category
class MedicalCategory {
  final String title;
  final IconData icon;

  const MedicalCategory({required this.title, required this.icon});
}

/// 2. Firestore-backed Doctor Model (NEW - for real data)
class DoctorModel {
  final String? id;
  final String name;
  final String clinicId;
  final String? clinicName;
  final String specialty;
  final double? rating;

  DoctorModel({
    this.id,
    required this.name,
    required this.clinicId,
    this.clinicName,
    required this.specialty,
    this.rating,
  });

  /// Create DoctorModel from Firestore DocumentSnapshot
  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      clinicId: data['clinicId'] ?? '',
      clinicName: data['clinicName'],
      specialty: data['specialty'] ?? '',
      rating: data['rating']?.toDouble(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'specialty': specialty,
      'rating': rating,
    };
  }
}

/// 3. Mock Doctor class (DEPRECATED - will be removed after migration)
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String clinicName;
  final double rating;
  final int distanceKm;
  final bool isUrgentCare;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.clinicName,
    required this.rating,
    required this.distanceKm,
    this.isUrgentCare = false,
  });
}

// -------------------------------------------------------------------
/// 4. Mock Data (EXPANDED CATEGORIES)
const List<MedicalCategory> mockCategories = [
  // Primary Care
  MedicalCategory(title: 'General Practice', icon: Icons.local_hospital),
  MedicalCategory(title: 'Urgent Care', icon: Icons.emergency),
  
  // Specialists
  MedicalCategory(title: 'Dentist', icon: Icons.healing),
  MedicalCategory(title: 'Cardiologist', icon: Icons.favorite),
  MedicalCategory(title: 'Pediatrician', icon: Icons.child_care),
  MedicalCategory(title: 'Dermatologist', icon: Icons.self_improvement),
  MedicalCategory(title: 'Ophthalmologist', icon: Icons.visibility),
  MedicalCategory(title: 'Neurologist', icon: Icons.psychology_outlined),
  MedicalCategory(title: 'Orthopedics', icon: Icons.accessible_forward),
  MedicalCategory(title: 'Physiotherapist', icon: Icons.fitness_center),
  
  // Other Services
  MedicalCategory(title: 'Pharmacy', icon: Icons.local_pharmacy),
  MedicalCategory(title: 'Lab & Imaging', icon: Icons.biotech),
  MedicalCategory(title: 'Vaccination', icon: Icons.vaccines),
];

// -------------------------------------------------------------------
/// 5. Mock Doctor Data (DEPRECATED - will be removed)
final List<Doctor> mockDoctors = [
  // ...existing code...
  // (Keep all your mock doctors for now)
  const Doctor(
    id: 'D302',
    name: 'Dr. Sarah Lee',
    specialty: 'Cardiology',
    clinicName: 'Peel Cardiology Associates',
    rating: 4.6,
    distanceKm: 3,
  ),
  // ... rest of mock doctors
];

/// 6. Helper function to filter doctors (DEPRECATED)
List<Doctor> getDoctorsForCategory(String category) {
  // ...existing code...
  final String normalizedCategory = category.toLowerCase();

  switch (normalizedCategory) {
    case 'general practice':
      return mockDoctors.where((d) => d.specialty == 'General Practice').toList();
    // ... rest of the switch cases
    default:
      return [];
  }
}