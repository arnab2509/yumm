import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:yumm/Authentication/forgotPasswordPage.dart';
import 'package:yumm/Authentication/registeration.dart';
import 'package:yumm/service/shared_pref.dart';
import 'package:yumm/widget/bottom_nav.dart';
import 'package:yumm/widget/widget_support.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "";
  final _formkey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _secureText = true;
  bool _isLoading = false; // Add loading state

  userLogin() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Sign in with email and password
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    
    User? user = userCredential.user;
    
    if (user != null) {
      // Check if email is verified
      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              "Please verify your email before logging in.",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        );
        return;
      }

      // Get user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("user")
          .doc(user.email)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;

        // Clear previous user data before saving new data
        await SharedPreferenceHelper().clearUserData();

        // Save current user data - handle null values
        await SharedPreferenceHelper().saveUserName(userData["Name"] ?? "");
        await SharedPreferenceHelper().saveUserEmail(userData["Email"] ?? "");
        await SharedPreferenceHelper().saveUserPhone(userData["Mobile"] ?? "");
        await SharedPreferenceHelper().saveUserId(userData["Id"] ?? "");
        
        // FIXED: Always save profile field, even if it's empty
        String profileUrl = userData["Profile"] ?? "";
        await SharedPreferenceHelper().saveUserProfile(profileUrl);
        
        print("User data loaded successfully");
        print("Profile: $profileUrl");
        print("All user data saved to SharedPreferences");

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Login successful!",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        );

        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
        );
      } else {
        // User document doesn't exist in Firestore
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "User data not found. Please contact support.",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage = "";
    
    switch (e.code) {
      case 'user-not-found':
        errorMessage = "No user found with this email address.";
        break;
      case 'wrong-password':
        errorMessage = "Incorrect password. Please try again.";
        break;
      case 'invalid-email':
        errorMessage = "Invalid email address format.";
        break;
      case 'user-disabled':
        errorMessage = "This user account has been disabled.";
        break;
      case 'too-many-requests':
        errorMessage = "Too many failed attempts. Please try again later.";
        break;
      case 'invalid-credential':
        errorMessage = "Invalid email or password. Please check your credentials.";
        break;
      default:
        errorMessage = "Login failed: ${e.message}";
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          errorMessage,
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "An unexpected error occurred: ${e.toString()}",
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          height: double.infinity,
          width: double.infinity,
          margin: EdgeInsets.only(top: 50, left: 20, right: 20),
          child: SingleChildScrollView(
              child: Center(
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
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
                  Lottie.network(
                    "https://lottie.host/f222a9c9-7163-4ded-9b61-4a31aefe475f/kinPhSHLSN.json",
                    height: 130,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(height: 40),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: "Login as ",
                        style: TextStyle(color: Colors.black, fontSize: 23)),
                    TextSpan(
                      text: "User",
                      style: AppWidget.getPlayLargeOrangeTextStyle(),
                    )
                  ])),
                  SizedBox(height: 60),
                  Material(
                    elevation: 7,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepOrange),
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 237, 237, 237),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.008,
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Email ID';
                                }
                                // Add email validation
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: "Email ID",
                                hintText: "Please enter your Email ID",
                                hintStyle:
                                    const TextStyle(fontWeight: FontWeight.w300),
                                labelStyle: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.008,
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Password';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              obscureText: _secureText,
                              decoration: InputDecoration(
                                labelText: "Password",
                                hintText: "Please enter your password",
                                hintStyle:
                                    const TextStyle(fontWeight: FontWeight.w300),
                                labelStyle: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                suffixIconColor: Colors.deepOrange,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _secureText = !_secureText;
                                    });
                                  },
                                  icon: Icon(
                                    _secureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return Forgotpasswordpage();
                                }),
                              );
                            },
                            child: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          
                          // Show loading indicator or login button
                          _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.deepOrange,
                                )
                              : AppWidget.customButton(
                                  context: context,
                                  text: "Log In",
                                  onPressed: () {
                                    if (_formkey.currentState!.validate()) {
                                      setState(() {
                                        email = _emailController.text.trim();
                                        password = _passwordController.text;
                                      });
                                      userLogin();
                                    }
                                  },
                                ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Not a member ?'),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Register()));
                                },
                                child: Text(
                                  ' Register now',
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ))),
    );
  }
}