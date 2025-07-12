import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yumm/Authentication/login.dart';
import 'package:yumm/service/shared_pref.dart';
import 'package:yumm/view/home.dart';
import 'package:yumm/widget/bottom_nav.dart';
import 'package:yumm/widget/widget_support.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:random_string/random_string.dart';
import 'dart:async';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _secureText = true;
  bool _securetext = true;
  bool _isEmailVerified = false;
  bool _isLoading = false;
  bool _showVerificationUI = false;
  Timer? _verificationTimer;
  User? _currentUser;

  String email = "",
      password = "",
      confirmpassword = " ",
      name = "",
      mobile = " ";

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmpasswordController =
      new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _mobileController = new TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    _verificationTimer?.cancel();
    // Clean up incomplete registration if user leaves without verification
    if (_showVerificationUI && _currentUser != null && !_isEmailVerified) {
      _currentUser?.delete().catchError((error) {
        // Handle deletion error silently
      });
    }
    super.dispose();
  }

  // Check if email is verified
  Future<void> _checkEmailVerification() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await _currentUser!.reload();
      if (_currentUser!.emailVerified) {
        setState(() {
          _isEmailVerified = true;
        });
        _verificationTimer?.cancel();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Email verified successfully!",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
        //add data to firebase

        // Navigate to BottomNav after a short delay
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
        );
        String Id = randomAlphaNumeric(10);

        Map<String, dynamic> addUserInfo = {
          "Name": _nameController.text,
          "Email": _emailController.text,
          "Mobile": _mobileController.text,
          "Id":_emailController.text ,
        };
        await addUserDetail(addUserInfo, _emailController.text);
        await SharedPreferenceHelper().saveUserName(_nameController.text);
        await SharedPreferenceHelper().saveUserEmail(_emailController.text);
        await SharedPreferenceHelper().saveUserPhone(_mobileController.text);

        await SharedPreferenceHelper().saveUserId(_emailController.text);
      }
    }
  }

  // Send verification email
  Future<void> _sendVerificationEmail() async {
    try {
      await _currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blue,
          content: Text(
            "Verification email sent! Check your inbox.",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Error sending verification email: ${e.toString()}",
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      );
    }
  }

  // Start verification process
  void _startVerificationProcess() {
    setState(() {
      _showVerificationUI = true;
    });

    // Start periodic check for email verification
    _verificationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  // Handle back button cleanup
  Future<bool> _onWillPop() async {
    if (_showVerificationUI && _currentUser != null && !_isEmailVerified) {
      // Show confirmation dialog
      bool shouldExit =
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Cancel Registration?"),
              content: Text(
                "Are you sure you want to cancel the registration process? Your account will be deleted.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Stay",
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Cancel Registration",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldExit) {
        _verificationTimer?.cancel();
        await _currentUser?.delete().catchError((error) {
          // Handle deletion error silently
        });
        return true;
      }
      return false;
    }
    return true;
  }

  // Registration with email verification
  registration() async {
    if (password != null && password.isNotEmpty) {
      // Check if passwords match
      if (password != confirmpassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Passwords do not match!",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        _currentUser = userCredential.user;

        // Send verification email
        await _sendVerificationEmail();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              "Account created! Please verify your email.",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );

        // Start verification process
        _startVerificationProcess();
      } on FirebaseException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password provided is too weak",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account already exists",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Registration failed: ${e.message}",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "An error occurred: ${e.toString()}",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.only(top: 50, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Show back button only when not in verification mode
                  if (!_showVerificationUI)
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
                    height: 110,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Register as ",
                          style: TextStyle(color: Colors.black, fontSize: 23),
                        ),
                        TextSpan(
                          text: "User",
                          style: AppWidget.getPlayLargeOrangeTextStyle(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  // Show verification UI or registration form
                  if (_showVerificationUI) ...[
                    _buildVerificationUI(),
                  ] else ...[
                    _buildRegistrationForm(),
                  ],

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationUI() {
    return Material(
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
            Icon(Icons.email_outlined, size: 80, color: Colors.deepOrange),
            SizedBox(height: 20),
            Text(
              "Verify Your Email",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "We've sent a verification email to:",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 5),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Please check your email and click the verification link. You'll be automatically redirected once verified.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 15),
            // Loading indicator to show it's checking
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Waiting for verification...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Resend verification email button
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _sendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  "Resend Verification Email",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),

            // Cancel button
            TextButton(
              onPressed: () async {
                _verificationTimer?.cancel();
                await _currentUser?.delete().catchError((error) {
                  // Handle deletion error silently
                });
                setState(() {
                  _showVerificationUI = false;
                });
              },
              child: Text(
                "Cancel Registration",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Material(
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
            // Name field
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.008,
              ),
              child: TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Name';
                  }
                  return null;
                },
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: "Name",
                  hintText: "Please enter your name",
                  hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                  labelStyle: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
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

            // Email field
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
                  } else if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                  ).hasMatch(value)) {
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 10,
              ),
              child: IntlPhoneField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: "Please Enter Phone number ..",
                  hintStyle: TextStyle(fontWeight: FontWeight.w300),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.deepOrangeAccent,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(),
                  ),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  print(phone.completeNumber);
                },
              ),
            ),
            SizedBox(height: 10),
            // Password field
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.008,
              ),
              child: TextFormField(
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                obscureText: _secureText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Please enter your password",
                  hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                  labelStyle: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _secureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.deepOrange,
                    ),
                    onPressed: () {
                      setState(() {
                        _secureText = !_secureText;
                      });
                    },
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

            // Confirm Password field
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.008,
              ),
              child: TextFormField(
                controller: _confirmpasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please re-enter password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                obscureText: _securetext,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  hintText: "Re-enter your password",
                  hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                  labelStyle: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _securetext ? Icons.visibility_off : Icons.visibility,
                      color: Colors.deepOrange,
                    ),
                    onPressed: () {
                      setState(() {
                        _securetext = !_securetext;
                      });
                    },
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
            SizedBox(height: 30),

            // Sign Up button
            _isLoading
                ? CircularProgressIndicator(color: Colors.deepOrange)
                : AppWidget.customButton(
                    context: context,
                    text: "Sign Up",
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        setState(() {
                          email = _emailController.text;
                          name = _nameController.text;
                          password = _passwordController.text;
                          confirmpassword = _confirmpasswordController.text;
                        });
                        registration();
                      }
                    },
                  ),
            SizedBox(height: 10),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already a member?'),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text(
                    ' Login now',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    String hint,
    double screenWidth,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: screenWidth * 0.032,
        fontWeight: FontWeight.w300,
      ),
      labelStyle: TextStyle(
        color: Colors.deepOrange,
        fontWeight: FontWeight.w600,
        fontSize: screenWidth * 0.035,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: 12,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 1.5),
      ),
    );
  }

  InputDecoration _buildPasswordDecoration(
    String label,
    String hint,
    bool isObscured,
    VoidCallback toggleVisibility,
    double screenWidth,
  ) {
    return _buildInputDecoration(label, hint, screenWidth).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          isObscured ? Icons.visibility_off : Icons.visibility,
          color: Colors.deepOrange,
          size: screenWidth * 0.06,
        ),
        onPressed: toggleVisibility,
      ),
    );
  }
   addUserDetail(Map<String, dynamic> addUserInfo, String Id) async {
    return await FirebaseFirestore.instance
        .collection('user')
        .doc(Id)
        .set(addUserInfo);
  }
}
