import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yumm/Authentication/authentication.dart';
import 'package:yumm/Authentication/login.dart';
import 'package:yumm/Authentication/registeration.dart';
import 'package:yumm/widget/widget_support.dart';

class Userlogin extends StatefulWidget {
  const Userlogin({super.key});

  @override
  State<Userlogin> createState() => _UserloginState();
}

class _UserloginState extends State<Userlogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //  // title: Text("User Login"),

      // ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // alignment: Alignment.center,
        margin: EdgeInsets.only(top: 50, left: 20, right: 20),
       
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.end,
                          children: [
            // const SizedBox(height: 50
            // ,),
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
 Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Authentication()),
    );
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 30,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            
         Container(
                               height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.6,
            child:
          Lottie.network("https://lottie.host/554fd8b9-3ef8-44ad-9171-bdad466bf58e/UY5fu1nFsX.json"),

          
                           ),
            
            SizedBox(height: 50), // This is for gaping
            RichText(text: TextSpan(
              children: [
                TextSpan(text: "Login or Register as ",style: TextStyle(color: Colors.black,fontSize: 23)),
                TextSpan(text: "User",style: AppWidget.getPlayLargeOrangeTextStyle())
              ]
            )),
            SizedBox(height: 34,),
                     
 AppWidget.customButton(
  context: context,
  text: "Log In",
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  },
),
            AppWidget.customButton(
  context: context,
  text: "Register",
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  },
),
                         
                          ],
                        ),
          )),
    );
  }
}