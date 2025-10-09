import 'package:flutter/material.dart';

/// 1. Model for a Doctor Category
class MedicalCategory {
  final String title;
  final IconData icon;

  const MedicalCategory({required this.title, required this.icon});
}

/// 2. Model for a Doctor/Clinic Listing
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
/// 3. Mock Data (EXPANDED CATEGORIES)
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

final List<Doctor> mockDoctors = [
  // General Practice
  const Doctor(
    id: 'D101',
    name: 'Dr. John Watson',
    specialty: 'Family Medicine',
    clinicName: 'Sheridan General Clinic',
    rating: 4.8,
    distanceKm: 2,
  ),
  const Doctor(
    id: 'D102',
    name: 'Dr. Emily Chen',
    specialty: 'General Practice',
    clinicName: 'Maple Urgent Care',
    rating: 4.5,
    distanceKm: 5,
    isUrgentCare: true,
  ),
  // Dentist
  const Doctor(
    id: 'D201',
    name: 'Dr. Alex White',
    specialty: 'Cosmetic Dentistry',
    clinicName: 'Bright Smile Dental',
    rating: 4.9,
    distanceKm: 1,
  ),
  // Cardiologist
  const Doctor(
    id: 'D301',
    name: 'Dr. Robert King',
    specialty: 'Heart & Vascular',
    clinicName: 'City Heart Institute',
    rating: 4.7,
    distanceKm: 7,
  ),
  // Urgent Care Mock Data
  const Doctor(
    id: 'D401',
    name: 'Dr. Lin Ming',
    specialty: 'Urgent Care Specialist',
    clinicName: 'The 24/7 Clinic',
    rating: 4.6,
    distanceKm: 1,
    isUrgentCare: true,
  ),
];

/// 4. Helper function to filter doctors (Simulates fetching data for a category)
List<Doctor> getDoctorsForCategory(String category) {
  // Simple logic to match a category to a doctor's specialty/type
  switch (category) {
    case 'General Practice':
      return mockDoctors.where((d) => d.specialty.contains('General') || d.specialty.contains('Family')).toList();
    case 'Dentist':
      return mockDoctors.where((d) => d.specialty.contains('Dentistry')).toList();
    case 'Cardiologist':
      return mockDoctors.where((d) => d.specialty.contains('Heart')).toList();
    case 'Urgent Care':
      return mockDoctors.where((d) => d.isUrgentCare).toList();
    default:
      // Return a placeholder list for un-mocked categories
      return [
        const Doctor(
          id: 'D900',
          name: 'Dr. Placeholder',
          specialty: 'Specialist',
          clinicName: 'Community Health Center',
          rating: 4.0,
          distanceKm: 3,
        ),
      ];
  }
}