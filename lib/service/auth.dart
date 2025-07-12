import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumm/service/shared_pref.dart';


class Authmethods {
  final FirebaseAuth auth=FirebaseAuth.instance;
  getCurrentUser()async{
    return await auth.currentUser;
  }

  Future SignOut()async{
    await SharedPreferenceHelper().clearUserData();
    await FirebaseAuth.instance.signOut();

  }
  Future deleteUser()async{
    User? user=await FirebaseAuth.instance.currentUser;
    user?.delete();
  }


}
