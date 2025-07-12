import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:yumm/widget/adminnavbar.dart';
import 'package:yumm/widget/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure you import this


class Adminlogin extends StatefulWidget {
  const Adminlogin({super.key});

  @override
  State<Adminlogin> createState() => _AdminloginState();
}

class _AdminloginState extends State<Adminlogin> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController userIdController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool _secureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // title: Text("AdminLogin"),
      //   backgroundColor: Colors.transparent,
      // ),
      backgroundColor: Colors.white,
      body: Container(
          height: double.infinity,
          width: double.infinity,
        margin: EdgeInsets.only(top: 50, left: 20, right: 20),

          // alignment: Alignment.center,

          // decoration: BoxDecoration(image:DecorationImage(image: AssetImage("assets/images/food.png")
          //,fit: BoxFit.fill  ),
          //  ),
          //width: sWidth,
          //height: sHeight,
          //color: Colors.deepOrange,
          // decoration: BoxDecoration(gradient: LinearGradient( colors: [

          //     Color.fromARGB(255, 130, 3, 3),
          //      Colors.deepOrange,
          //   ],
          //   begin: Alignment.bottomCenter,
          //   end: Alignment.topCenter,
          //   )),
          child: SingleChildScrollView(
              child: Form(
            key: _formkey,
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
            
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
              // SizedBox(height: 20), // This is for gaping
              Lottie.network(
                  "https://lottie.host/58100636-226e-4348-a7c1-657f73ee1f28/nybTH2ctty.json",
                  height: 110,
                  fit: BoxFit.fill),
              // Image.asset("assets/images/setting.png",
              //  height: 110, fit: BoxFit.fill),
              //Image(image: AssetImage('assets/login3.png')),
              SizedBox(height: 40),

             
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: "Login as ",
                    style: TextStyle(color: Colors.black, fontSize: 23)),
                TextSpan(text: "Admin",style: AppWidget.getPlayLargeOrangeTextStyle() )
              ])),

              SizedBox(height: 60), // This is for gaping




              SizedBox(height: 10), // This is for gaping
              Material(
                elevation: 7,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                padding: EdgeInsets.all(10),
                
                  decoration: BoxDecoration(
                    border: Border.all( color: Colors.deepOrange),
                    borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 237, 237, 237),
                  ),
                  child: Column(
                    children: [
                          SizedBox(height: 20,)      ,
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                    vertical: MediaQuery.of(context).size.height * 0.008,
                  ),
                  child: TextFormField(
                    controller: userIdController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: "Admin ID",
                      hintText: "Enter your admin ID",
                      hintStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.032,
                        fontWeight: FontWeight.w300,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                 Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                    vertical: MediaQuery.of(context).size.height * 0.008,
                  ),
                  child: TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    obscureText: _secureText,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your password",
                      hintStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.032,
                        fontWeight: FontWeight.w300,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 1.5,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _secureText = !_secureText;
                          });
                        },
                        icon: Icon(
                          _secureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.deepOrange,
                          size: MediaQuery.of(context).size.width * 0.06,
                        ),
                      ),
                    ),
                  ),
                ),  SizedBox(height: 30.h), // This is for gaping
                
                AppWidget.customButton(
                  context: context,
                  text: "Log In",
                  // onPressed: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => Adminnavbar()),
                  //   );
                  // },
                  onPressed: () async {
  if (_formkey.currentState!.validate()) {
    await loginAdmin();
  }
},

                ),
                          SizedBox(height: 20,)      ,
                
                    ],
                  ),
                ),
              )
            
            
,
            
            ]),
          ))),
    );
  }
  // LoginAdmin() {
  //   FirebaseFirestore.instance.collection("Admin").get().then((snapshot) {
  //     snapshot.docs.forEach((result) {
  //       if (result.data()['id'] != userIdController.text.trim()) {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //             backgroundColor: Colors.orangeAccent,
  //             content: Text(
  //               "Your id is not correct",
  //               style: TextStyle(fontSize: 18.0),
  //             )));
  //       } else if (result.data()['password'] !=
  //           passwordController.text.trim()) {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //             backgroundColor: Colors.orangeAccent,
  //             content: Text(
  //               "Your password is not correct",
  //               style: TextStyle(fontSize: 18.0),
  //             )));
  //       } else {
  //         Route route = MaterialPageRoute(builder: (context) => Admindash());
  //         Navigator.pushReplacement(context, route);
  //       }
  //     });
  //   });
  // }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    Widget? suffixIcon,
    required String validatorMsg,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) {
        if (value == null || value.isEmpty) return validatorMsg;
        return null;
      },
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontWeight: FontWeight.w300),
        labelStyle: const TextStyle(
            color: Colors.deepOrange, fontWeight: FontWeight.bold),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Colors.deepOrangeAccent, width: 1.8),
        ),
      ),
    );
  }

Future<void> loginAdmin() async {
  String enteredId = userIdController.text.trim();
  String enteredPassword = passwordController.text.trim();

  try {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Admin")
        .where("id", isEqualTo: enteredId)
        .get();

    if (snapshot.docs.isEmpty) {
      _showSnackBar("Admin ID not found");
      return;
    }

    final adminData = snapshot.docs.first.data() as Map<String, dynamic>;
    if (adminData['password'] == enteredPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Adminnavbar()),
      );
    } else {
      _showSnackBar("Incorrect password");
    }
  } catch (e) {
    _showSnackBar("Error: ${e.toString()}");
  }
}void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.deepOrange,
      content: Text(message, style: TextStyle(fontSize: 16)),
    ),
  );
}


}
