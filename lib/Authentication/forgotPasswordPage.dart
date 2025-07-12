// import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:yumm/widget/widget_support.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class Forgotpasswordpage extends StatefulWidget {
  const Forgotpasswordpage({super.key});

  @override
  State<Forgotpasswordpage> createState() => _ForgotpasswordpageState();
}

class _ForgotpasswordpageState extends State<Forgotpasswordpage> {
  final _emailController = TextEditingController();
   @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                'Password Reset Link Sent! Check your inbox.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          });
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Password Reset Error',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(e.message.toString()),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.deepOrange,
      //   elevation: 0,
      // ),
      body: Container(
        margin: EdgeInsets.only(top: 50, left: 20, right: 20),

        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 30,
                  color: Colors.deepOrange,
                ),
              ),
            ),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                              width: MediaQuery.of(context).size.width * 0.8,
                  child: Lottie.network(
                      'https://lottie.host/abc42aeb-7a95-404e-9fe3-ee2673972f70/ttEmUop9Qk.json')),
              const SizedBox(
                height: 20,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Text(
                  'Enter Your Email & we will send you a password reset link',
                  textAlign: TextAlign.center,
                  style: AppWidget.getBoldBlackHeadingTextStyle(),
                ),
              ),
              const SizedBox(height:30 ),
              // Spacer(),
              //Email field
Material(
      elevation: 7,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepOrange),
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 237, 237, 237),
        ),
                  child: Column(
                    children: [
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                //   child: Container(
                //     height: MediaQuery.of(context).size.height * 0.08,
                //                 width: MediaQuery.of(context).size.width ,
                              
                //     decoration: BoxDecoration(
                      
                //       color: Colors.white,
                //       border: Border.all(color: const Color.fromARGB(255, 253, 99, 52)),
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.only(left: 20.0),
                //       child: TextField(
                //         controller: _emailController,
                //         decoration: InputDecoration(
                //           border: InputBorder.none,
                //           hintText: 'Email',
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.008,
              ),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter E-mail';
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: "Mail ID",
                  hintText: "Please enter your email",
                  hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                  labelStyle: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepOrangeAccent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
                SizedBox(height: 10),
                
                //Signin BTN
                AppWidget.customButton(
                  context: context,
                  text: "Reset Password",
                  onPressed: () {
                    
                    passwordReset();
                  },
                ),
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
