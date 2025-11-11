import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create user profile in Firestore after signup
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      await _firestore.collection('Users').doc(uid).set({
        'Email': email,
        'First_Name': firstName,
        'Last_Name': lastName,
        'Age': null, // To be completed in profile
        'Gender': null, // To be completed in profile
        'City': null, // To be completed in profile
        'profilePhotoUrl': null, // To be completed in profile
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User profile created successfully for uid: $uid');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      rethrow; // Rethrow so signup knows it failed
    }
  }

  // Check if user profile exists in Firestore
  Future<bool> userProfileExists(String uid) async {
    try {
      final doc = await _firestore.collection('Users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking user profile: $e');
      return false;
    }
  }

  // Get user profile
  Future<DocumentSnapshot?> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('Users').doc(uid).get();
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile (for profile section)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('Users').doc(uid).update(data);
      print('✅ User profile updated successfully');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // Stream user profile for real-time updates
  Stream<DocumentSnapshot> getUserProfileStream(String uid) {
    return _firestore.collection('Users').doc(uid).snapshots();
  }

  // Ensure user profile exists (called on login)
  // This handles the case where Auth exists but Firestore document doesn't
  Future<void> ensureUserProfileExists() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('⚠️ No authenticated user found');
      return;
    }

    final exists = await userProfileExists(user.uid);
    if (!exists) {
      print('⚠️ Firestore profile missing for uid: ${user.uid}, creating now...');
      // Create minimal profile from Auth data
      await createUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        firstName: user.displayName?.split(' ').first ?? 'User',
        lastName: user.displayName?.split(' ').last ?? '',
      );
    } else {
      print('✅ Firestore profile exists for uid: ${user.uid}');
    }
  }

  // Check if profile is complete
  Future<bool> isProfileComplete(String uid) async {
    try {
      final doc = await _firestore.collection('Users').doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      
      // Check if essential fields are filled
      return data['Age'] != null &&
             data['Gender'] != null &&
             data['City'] != null;
    } catch (e) {
      print('❌ Error checking profile completion: $e');
      return false;
    }
  }
}