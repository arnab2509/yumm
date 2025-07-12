import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yumm/Authentication/authentication.dart';
import 'package:yumm/widget/bottom_nav.dart';
import 'package:yumm/widget/content_model.dart';
import 'package:yumm/widget/widget_support.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  int currentIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Main content area with proper constraints
            Expanded(
              flex: 8,
              child: PageView.builder(
                controller: pageController,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Lottie animation with proper constraints
                        Flexible(
                          flex: 3,
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.4,
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            child: Lottie.network(
                              contents[i].lottieUrl ?? '',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Title with proper constraints
                        Flexible(
                          flex: 1,
                          child: Text(
                            contents[i].title,
                            style: AppWidget.getPlaywriteOrangeTitleTextStyle(),
                            // style: const TextStyle(
                            //   fontSize: 24,
                            //   fontWeight: FontWeight.bold,
                            //   color: Colors.deepOrange,
                            // ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Description with proper constraints
                        Flexible(
                          flex: 2,
                          child: Text(
                            contents[i].description,
                            style: AppWidget.getBlackLightHeadingTextStyle(),
                            // style: const TextStyle(
                            //   fontSize: 16,
                            //   color: Colors.black54,
                            //   height: 1.5,
                            // ),
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page indicators with proper spacing
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  contents.length,
                  (index) => buildDot(index, context),
                ),
              ),
            ),
            
            // Bottom button with proper constraints
            Container(
              margin: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  if (currentIndex < contents.length - 1) {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Authentication(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  currentIndex == contents.length - 1 ? 'Get Started' : 'Next',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      width: currentIndex == index ? 20 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.deepOrange : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}