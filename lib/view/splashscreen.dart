import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yumm/view/home.dart';
import 'package:yumm/view/onboard.dart';
import 'package:yumm/widget/bottom_nav.dart';
class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 2), (){

Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => Onboard()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //backgroundColor: Colors.deepOrange,
      body: Center(
        child: Container(
          height: 450,
          width: 450,
          //color: Colors.deepOrange,
          
            child:  Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset("assets/images/logo-no-background.png"),
            )
          
          
        ),
      
      ),
    );
  }
}