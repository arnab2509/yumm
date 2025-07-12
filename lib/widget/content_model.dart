import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
class OnboardingContent {
  // String image;
  String? lottieUrl;
  String title;
  String description;

  OnboardingContent({
    required this.lottieUrl,
    required this.title,
    required this.description,
  });
  
}
List<OnboardingContent> contents = [
  OnboardingContent(

    // image: 'assets/images/onboarding1.png',
    // Example of using Lottie.network (not directly assignable to String 'image')
    // To use Lottie, you might want to add a new field or handle it in your widget.
    // For demonstration, here's how you might store the Lottie URL:
   lottieUrl: 'https://lottie.host/e1327176-2cdc-4c20-9c53-ba0068e7a01e/manYBupnst.json',
    title: 'Food on your fingure tips !',
    description: 'Food like your mom\'s special dishes',
  ),
  OnboardingContent(
    // image: 'assets/images/onboarding2.png',
   lottieUrl: 'https://lottie.host/42b78ada-666c-4ef8-a0ba-d504adc37d90/48Xr1rdPrY.json',

    title: 'Chose your favourite dishes  !',
    description: 'Chose dishes of your liking form yumm',
  ),
  OnboardingContent(
    // image: 'assets/images/onboarding3.png',
   lottieUrl: 'https://lottie.host/8538ca80-4d26-4802-9f9d-9651ef6c2e19/EpU2HYGKAK.json',

    title: 'Get amazing offers & discounts !',
    description: 'Choose  offers , coupons , discounts  that suits you before ordering your food !',
  ),
    OnboardingContent(
    // image: 'assets/images/onboarding3.png',
   lottieUrl: 'https://lottie.host/2a4b0d26-b264-4b62-b0c7-27e9c79911f6/hFfM5LR174.json',

    title: 'Get your food at your door steps !',
    description: 'Order your food and we will deliver your meal on your door steps within 30 minutes !',
  ),
];