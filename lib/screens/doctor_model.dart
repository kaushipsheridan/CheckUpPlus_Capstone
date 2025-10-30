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

// -------------------------------------------------------------------
/// 4. Mock Doctor Data
///
/// * Cardiologists are from the previous step.
/// * All other entries are new from your provided data.
///
final List<Doctor> mockDoctors = [
  // --- CARDIOLOGISTS (from your data) ---
  const Doctor(
    id: 'D302',
    name: 'Dr. Sarah Lee',
    specialty: 'Cardiology',
    clinicName: 'Peel Cardiology Associates',
    rating: 4.6,
    distanceKm: 3,
  ),
  const Doctor(
    id: 'D303',
    name: 'Dr. Michael Cho',
    specialty: 'Cardiology',
    clinicName: 'Mississauga Cardiovascular Centre',
    rating: 4.8,
    distanceKm: 6,
  ),
  const Doctor(
    id: 'D304',
    name: 'Dr. Anjali Patel',
    specialty: 'Cardiology',
    clinicName: 'Heart Health Medical Group',
    rating: 4.7,
    distanceKm: 8,
  ),
  const Doctor(
    id: 'D305',
    name: 'Dr. James Smith',
    specialty: 'Cardiology',
    clinicName: 'Regional Cardiac Care',
    rating: 4.5,
    distanceKm: 4,
  ),
  const Doctor(
    id: 'D306',
    name: 'Dr. Kenji Tanaka',
    specialty: 'Cardiology',
    clinicName: 'Brampton Heart Institute',
    rating: 4.9,
    distanceKm: 5,
  ),
  const Doctor(
    id: 'D307',
    name: 'Dr. Maria Garcia',
    specialty: 'Cardiology',
    clinicName: 'Peel Heart & Rhythm Centre',
    rating: 4.6,
    distanceKm: 7,
  ),
  const Doctor(
    id: 'D308',
    name: 'Dr. David Brown',
    specialty: 'Cardiology',
    clinicName: 'Brampton Heart & Vascular Clinic',
    rating: 4.7,
    distanceKm: 2,
  ),

  // --- NEW DATA (All other specialties) ---

  // General Practice
  const Doctor(
    id: 'D501',
    name: 'Dr. Susan Ray',
    specialty: 'General Practice',
    clinicName: 'Davis Medical Clinic',
    rating: 4.6,
    distanceKm: 2,
  ),
  const Doctor(
    id: 'D502',
    name: 'Dr. Robert Stone',
    specialty: 'General Practice',
    clinicName: 'Shoppers Medical Centre',
    rating: 4.5,
    distanceKm: 3,
  ),
  const Doctor(
    id: 'D503',
    name: 'Dr. Aisha Khan',
    specialty: 'General Practice',
    clinicName: 'Brampton Family Health Centre',
    rating: 4.8,
    distanceKm: 2,
  ),

  // Urgent Care
  const Doctor(
    id: 'D504',
    name: 'Dr. Ben Carter',
    specialty: 'Urgent Care',
    clinicName: 'QuickCare Walk-In Clinic',
    rating: 4.4,
    distanceKm: 1,
    isUrgentCare: true,
  ),
  const Doctor(
    id: 'D505',
    name: 'Dr. Linda Harris',
    specialty: 'Urgent Care',
    clinicName: 'After Hours Medical Centre',
    rating: 4.6,
    distanceKm: 5,
    isUrgentCare: true,
  ),

  // Dentist
  const Doctor(
    id: 'D506',
    name: 'Dr. Kevin Lee',
    specialty: 'Dentist',
    clinicName: 'Family Dental Care',
    rating: 4.8,
    distanceKm: 5,
  ),
  const Doctor(
    id: 'D507',
    name: 'Dr. Alen Cooper',
    specialty: 'Dentist',
    clinicName: 'Bright Smiles Dental',
    rating: 4.7,
    distanceKm: 3,
  ),

  // Physiotherapist
  const Doctor(
    id: 'D508',
    name: 'Dr. Mark Brown',
    specialty: 'Physiotherapist',
    clinicName: 'Active Life Physiotherapy',
    rating: 4.7,
    distanceKm: 4,
  ),
  const Doctor(
    id: 'D509',
    name: 'Dr. Chloe Kim',
    specialty: 'Physiotherapist',
    clinicName: 'Motion Rehab Clinic',
    rating: 4.8,
    distanceKm: 7,
  ),

  // Neurologist
  const Doctor(
    id: 'D510',
    name: 'Dr. Evelyn Reed',
    specialty: 'Neurologist',
    clinicName: 'Brampton Neurology Clinic',
    rating: 4.9,
    distanceKm: 3,
  ),
  const Doctor(
    id: 'D511',
    name: 'Dr. Henry Wu',
    specialty: 'Neurologist',
    clinicName: 'Brain & Spine Neurology',
    rating: 4.8,
    distanceKm: 10,
  ),

  // Lab & Imaging
  const Doctor(
    id: 'D512',
    name: 'Tech Office', // Not a doctor
    specialty: 'Lab & Imaging',
    clinicName: 'Advanced Diagnostics Centre',
    rating: 4.5,
    distanceKm: 6,
  ),
  const Doctor(
    id: 'D513',
    name: 'Lab Office', // Not a doctor
    specialty: 'Lab & Imaging',
    clinicName: 'LifeLabs Medical Laboratory',
    rating: 4.6,
    distanceKm: 7,
  ),

  // Orthopedics
  const Doctor(
    id: 'D514',
    name: 'Dr. Daniel Pak',
    specialty: 'Orthopedics',
    clinicName: 'Joint & Bone Orthopedic Centre',
    rating: 4.7,
    distanceKm: 8,
  ),
  const Doctor(
    id: 'D515',
    name: 'Dr. Megan Fox', // Yes, that's a generated name :)
    specialty: 'Orthopedics',
    clinicName: 'Brampton Sports Medicine',
    rating: 4.9,
    distanceKm: 10,
  ),

  // Ophthalmologist
  const Doctor(
    id: 'D516',
    name: 'Dr. Sam Ghosh',
    specialty: 'Ophthalmologist',
    clinicName: 'Vision Plus Eye Care',
    rating: 4.7,
    distanceKm: 6,
  ),
  const Doctor(
    id: 'D517',
    name: 'Dr. Brian King',
    specialty: 'Ophthalmologist',
    clinicName: 'Eye Health Centre',
    rating: 4.6,
    distanceKm: 9,
  ),

  // Dermatologist
  const Doctor(
    id: 'D518',
    name: 'Dr. Julia Ives',
    specialty: 'Dermatologist',
    clinicName: 'Clear Skin Dermatology',
    rating: 4.9,
    distanceKm: 3,
  ),
  const Doctor(
    id: 'D519',
    name: 'Dr. Sonia Verma',
    specialty: 'Dermatologist',
    clinicName: 'Brampton Skin Care Clinic',
    rating: 4.7,
    distanceKm: 8,
  ),

  // Pediatrician
  const Doctor(
    id: 'D520',
    name: 'Dr. Elena Gomez',
    specialty: 'Pediatrician',
    clinicName: 'Little Stars Pediatric Clinic',
    rating: 4.9,
    distanceKm: 5,
  ),
  const Doctor(
    id: 'D521',
    name: 'Dr. Peter Pan', // Generated name
    specialty: 'Pediatrician',
    clinicName: 'Kids First Medical Centre',
    rating: 4.8,
    distanceKm: 9,
  ),

  // Pharmacy
  const Doctor(
    id: 'D522',
    name: 'Pharma Team', // Not a doctor
    specialty: 'Pharmacy',
    clinicName: 'HealthPlus Pharmacy',
    rating: 4.5,
    distanceKm: 4,
  ),

  // Vaccination
  const Doctor(
    id: 'D523',
    name: 'Clinic Staff', // Not a doctor
    specialty: 'Vaccination',
    clinicName: 'Brampton Immunization Clinic',
    rating: 4.6,
    distanceKm: 7,
  ),
];



/// 5. Helper function to filter doctors (Simulates fetching data for a category)
///
/// **FULLY UPDATED** to handle all new categories and data.
///
List<Doctor> getDoctorsForCategory(String category) {
  // Normalize category name for robust matching
  final String normalizedCategory = category.toLowerCase();

  // Use exact matching for specialty strings
  switch (normalizedCategory) {
    case 'general practice':
      return mockDoctors.where((d) => d.specialty == 'General Practice').toList();
    
    case 'dentist':
      return mockDoctors.where((d) => d.specialty == 'Dentist').toList();
    
    case 'cardiologist':
      return mockDoctors.where((d) => d.specialty == 'Cardiology').toList();
    
    case 'urgent care':
      // Filter by the flag
      return mockDoctors.where((d) => d.isUrgentCare).toList();
    
    case 'pediatrician':
      return mockDoctors.where((d) => d.specialty == 'Pediatrician').toList();

    case 'dermatologist':
      return mockDoctors.where((d) => d.specialty == 'Dermatologist').toList();

    case 'ophthalmologist':
      return mockDoctors.where((d) => d.specialty == 'Ophthalmologist').toList();
    
    case 'neurologist':
      return mockDoctors.where((d) => d.specialty == 'Neurologist').toList();

    case 'orthopedics':
      return mockDoctors.where((d) => d.specialty == 'Orthopedics').toList();

    case 'physiotherapist':
      return mockDoctors.where((d) => d.specialty == 'Physiotherapist').toList();

    case 'pharmacy':
      return mockDoctors.where((d) => d.specialty == 'Pharmacy').toList();
    
    case 'lab & imaging':
      return mockDoctors.where((d) => d.specialty == 'Lab & Imaging').toList();

    case 'vaccination':
      return mockDoctors.where((d) => d.specialty == 'Vaccination').toList();

    default:
      // If no category matches, return an empty list.
      return [];
  }
}
