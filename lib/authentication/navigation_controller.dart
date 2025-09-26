import 'package:get/get.dart';
import 'package:flutter/material.dart';

// Screens are imported directly from the 'screens' folder
import 'package:checkupplus_capstone/screens/home.dart';
import 'package:checkupplus_capstone/screens/bookings.dart';
import 'package:checkupplus_capstone/screens/chat.dart';
import 'package:checkupplus_capstone/screens/profile.dart';

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs; // Tracks the current tab index

  // List of screens corresponding to the tabs
  final screens = [
    const HomeScreen(),
    const BookingsScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];
  
  // Method to change the tab
  void changeTab(int index) {
    selectedIndex.value = index;
  }
}