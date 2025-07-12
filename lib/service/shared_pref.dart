import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey="USERKEY";
   static String userNameKey="USERNAMEKEY";
  static String userEmailKey="USEREMAILKEY";
     static String userLocationKey="USERLOCATIONKEY";
     static String userPhoneKey="USERPHONEKEY";
     static String userProfileKey="USERPROFILEKEY";



    Future<bool> saveUserId(String getUserId)async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userIdKey, getUserId);
    }
     Future<bool> saveUserName(String getUserName)async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userNameKey, getUserName);
    }
     Future<bool> saveUserEmail(String getUserEmail)async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userEmailKey, getUserEmail);
    }
     Future<bool> saveUserLocation(String getUserLocation)async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userLocationKey, getUserLocation);
    }
         Future<bool> saveUserPhone(String getUserPhone)async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userPhoneKey, getUserPhone);
    }
             Future<bool> saveUserProfile(String getUserProfile)async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userProfileKey, getUserProfile);
    }

    Future<String?>getUserId()async{
      SharedPreferences prefs= await SharedPreferences.getInstance();
      return prefs.getString(userIdKey);
    }
    Future<String?>getUserName()async{
      SharedPreferences prefs= await SharedPreferences.getInstance();
      return prefs.getString(userNameKey);
    }
    Future<String?>getUserEmail()async{
      SharedPreferences prefs= await SharedPreferences.getInstance();
      return prefs.getString(userEmailKey);
    }
    Future<String?>getUserLocation()async{
      SharedPreferences prefs= await SharedPreferences.getInstance();
      return prefs.getString(userLocationKey);
    }
        Future<String?>getUserPhone()async{
      SharedPreferences prefs= await SharedPreferences.getInstance();
      return prefs.getString(userPhoneKey);
    }
      Future<String?>getUserProfile()async{
      SharedPreferences prefs= await SharedPreferences.getInstance();
      return prefs.getString(userProfileKey);
    }
   Future<void> clearUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(userIdKey);
  await prefs.remove(userNameKey);
  await prefs.remove(userEmailKey);
  await prefs.remove(userLocationKey);
  await prefs.remove(userPhoneKey);
  await prefs.remove(userProfileKey);
}

}