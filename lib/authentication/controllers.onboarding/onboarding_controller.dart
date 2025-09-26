//import 'package:get/get.dart';

// class OnboardingController extends GetxController {

//   static OnboardingController get instance => Get.find();

//   void updatePageIndicator(index){}

//   void dotNaviagtionClick(index) {}

//   void nextPage(){

//   }

//   void skipPage(){

//   }

// }

import 'package:checkupplus_capstone/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  // <-- ADD THIS STORAGE INSTANCE
  final deviceStorage = GetStorage(); 

  /// Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  /// Update Current Index when Page Scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  /// Jump to the specific dot selected page.
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// Go to next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      // ADD: Save completion status
      deviceStorage.write('IsOnboarded', true); 
      
      // Replace with the sign-in screen
      Get.offAll(() => Wrapper());
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  /// Skip all onboarding pages
  void skipPage() {
    // CHANGE: Save completion status immediately
    deviceStorage.write('IsOnboarded', true);
    
    // CHANGE: Navigate directly to the next screen (Wrapper)
    Get.offAll(() => Wrapper());
  }
}