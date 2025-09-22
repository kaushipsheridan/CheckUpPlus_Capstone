// import 'package:flutter/material.dart';

// class OnboardingScreen extends StatelessWidget {
//   const OnboardingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           PageView(
//             children: [
//               Column(
//                 children: [
//                   Image(
//                     width: ,
//                     image: AssetImage("assets/images/onboarding_images/OnboardingGif1.gif")),
//                 ],
//               )
//             ],
//          )
//         ]
//       )
//     );
      
//   }
// }

import 'package:checkupplus_capstone/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:checkupplus_capstone/screens/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      body: Stack(
        children: [
          // Onboarding Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnboardingPage(
                image: 'assets/images/onboarding_images/OnboardingGif1.gif',
                title: 'Welcome to CheckupPlus',
                subTitle: 'Your health, your way.',
              ),
              OnboardingPage(
                image: 'assets/images/onboarding_images/OnboardingGif2.gif',
                title: 'Find Doctors Easily',
                subTitle: 'Book appointments with top specialists.',
              ),
              OnboardingPage(
                image: 'assets/images/onboarding_images/OnboardingGif3.gif',
                title: 'Get Personalized Care',
                subTitle: 'Tailored health plans just for you.',
              ),
            ],
          ),

          // Skip Button
          Positioned(
            top: kToolbarHeight,
            right: 20,
            child: TextButton(
              onPressed: () => controller.skipPage(),
              child: const Text('Skip'),
            ),
          ),

          // Dot Navigation SmoothPageIndicator
          Positioned(
            bottom: kBottomNavigationBarHeight + 25,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: controller.pageController,
                count: 3,
                onDotClicked: controller.dotNavigationClick,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.blue,
                  dotHeight: 6,
                ),
              ),
            ),
          ),

          // Next Button
          Positioned(
            right: 20,
            bottom: kBottomNavigationBarHeight,
            child: Obx(
              () => ElevatedButton(
                onPressed: () => controller.nextPage(),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: controller.currentPageIndex.value == 2
                      ? Colors.green
                      : Colors.blue,
                ),
                child: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
        ],
      ),
    );
  }
}