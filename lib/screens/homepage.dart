import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:checkupplus_capstone/authentication/navigation_controller.dart'; 
// NOTE: Your controller must be correctly imported

// HomePage should be a StatelessWidget since NavigationController manages all state
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. INITIALIZE THE CONTROLLER INSIDE THE BUILD METHOD
    // This is the correct, safe way to use Get.put()
    final NavigationController controller = Get.put(NavigationController());

    // NOTE: Your old Firebase logic (user, signOut, etc.) has been moved to 
    // lib/screens/profile.dart, so we remove it from here.

    return Scaffold(
      // The body uses Obx to reactively display the correct screen
      body: Obx(
        () => controller.screens[controller.selectedIndex.value],
      ),
      
      // The Bottom Navigation Bar is also wrapped in Obx
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80, 
          elevation: 0, 
          backgroundColor: const Color(0xFF1A4D8C),
          indicatorColor: Colors.white.withAlpha((0.2 * 255).round()),
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.changeTab, // Use the controller method
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white),
          ),

          // Destinations (Your four tabs: Home, Bookings, Chat, Profile)
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.home, color: Colors.white), 
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.calendar, color: Colors.white), 
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.message, color: Colors.white), 
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.user, color: Colors.white), 
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}