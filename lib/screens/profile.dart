import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

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
      body: SingleChildScrollView(
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
                    backgroundImage: const AssetImage('assets/images/default_profile.png'),
                    // You can replace with user?.photoURL if available
                    // backgroundImage: user?.photoURL != null 
                    //     ? NetworkImage(user!.photoURL!) 
                    //     : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  ),
                  const SizedBox(width: 20),
                  // User details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "Yashika",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                       
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "email@example.com",
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