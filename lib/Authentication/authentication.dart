import 'package:flutter/material.dart';
import 'package:yumm/Authentication/adminlogin.dart';
import 'package:yumm/Authentication/userlogin.dart';
import 'package:yumm/widget/widget_support.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,

        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,

            children: [
              const SizedBox(height: 70),

              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Image.asset("assets/images/Yumm.png"),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                // child: Text("Login As",style: TextStyle(fontFamily: 'PlaywriteGBS',color: Colors.deepOrangeAccent,fontWeight: FontWeight.bold,fontSize: 30),),
              ),
              SizedBox(height: 50), // This is for gaping

              AppWidget.customButton(
  context: context,
  text: "Admin",
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Adminlogin()),
    );
  },
),
 AppWidget.customButton(
  context: context,
  text: "User",
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Userlogin()),
    );
  },
),


            ],
          ),
        ),
      ),
    );
  }
}
