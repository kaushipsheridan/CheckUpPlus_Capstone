import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 1. Logic is moved here
  final user = FirebaseAuth.instance.currentUser;

  signOut() async {
    // This function will sign out the user
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        // Optional: Move the sign-out button to the AppBar for easy access
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      
      // 2. Display User Email and Sign-out button in the body
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the authenticated user's email
            Text(
              'Logged in as: ${user?.email ?? "User Not Found"}', 
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // FloatingActionButton logic replaced with a standard ElevatedButton
            ElevatedButton.icon(
              onPressed: signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
      
      // The original FloatingActionButton is removed from the Scaffold, 
      // as it's now handled by the body/AppBar.
    );
  }
}