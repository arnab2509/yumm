import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yumm/Authentication/forgotPasswordPage.dart';
import 'package:yumm/admin/add_food.dart';
import 'package:yumm/widget/adminnavbar.dart';
import 'package:yumm/admin/viewitem.dart';
import 'package:yumm/view/home.dart';
import 'package:yumm/view/splashscreen.dart';
import 'package:yumm/widget/bottom_nav.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Import the generated file
import 'firebase_options.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
   
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // print(MediaQuery.of(context).size.width);
    // print(MediaQuery.of(context).size.height);

    return ScreenUtilInit(
      designSize: Size(392.72727272727275,  803.6363636363636),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Yumm',
        theme: ThemeData(
        
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: Splashscreen(),
        // home: AddFood(),
        // home: Viewitem(),
        // home: Adminnavbar(),
// home:BottomNav(),
// home: Forgotpasswordpage(),
      ),
    );
  }
}
