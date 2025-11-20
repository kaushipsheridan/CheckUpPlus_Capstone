import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // User data
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile() async {
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        
        // Combine First_Name and Last_Name
        final firstName = data?['First_Name'] ?? '';
        final lastName = data?['Last_Name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        
        setState(() {
          _userName = fullName.isNotEmpty ? fullName : user?.displayName ?? 'User';
          _userEmail = data?['Email'] ?? user?.email ?? 'No email';
          _isLoading = false;
        });
        
        print('✅ Loaded user profile: $_userName ($_userEmail)');
      } else {
        // Fallback to Firebase Auth data if Firestore doc doesn't exist
        setState(() {
          _userName = user?.displayName ?? 'User';
          _userEmail = user?.email ?? 'No email';
          _isLoading = false;
        });
        print('⚠️ No Firestore document found, using Firebase Auth data');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
      // Fallback to Firebase Auth data on error
      setState(() {
        _userName = user?.displayName ?? 'User';
        _userEmail = user?.email ?? 'No email';
        _isLoading = false;
      });
    }
  }

  // Sign out function
  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Profile image
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            _userName?.isNotEmpty == true 
                                ? _userName![0].toUpperCase() 
                                : 'U',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          // You can replace with actual image if available
                          // backgroundImage: user?.photoURL != null 
                          //     ? NetworkImage(user!.photoURL!) 
                          //     : null,
                        ),
                        const SizedBox(width: 20),
                        // User details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName ?? "User",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userEmail ?? "email@example.com",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Menu options
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.edit, 
                          title: 'Edit Profile', 
                          onTap: () {
                            // TODO: Navigate to edit profile screen
                          },
                        ),                      
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.folder, 
                          title: 'Electronic Health Records', 
                          onTap: () {
                            // TODO: Navigate to health records screen
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.settings, 
                          title: 'Settings', 
                          onTap: () {
                            // TODO: Navigate to settings screen
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.support_agent, 
                          title: 'Contact Us', 
                          onTap: () {
                            // TODO: Navigate to contact us screen
                          },
                        ),
                        _buildMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.logout, 
                          title: 'LogOut', 
                          onTap: signOut,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  // Helper method to build menu items
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey,
        size: 30,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      onTap: onTap,
    );
  }
  
  // Helper method to build dividers between menu items
  Widget _buildMenuDivider() {
    return const Divider(height: 1, thickness: 0.5);
  }
}