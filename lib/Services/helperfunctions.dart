import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String sharedPreferenceLoggedinKey = "ISLOGGEDIN";
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";
  static String sharedPreferenceUserEmailKey = "USEREMAILKEY";


  static Future<bool> saveUserLoggedInSharedPreference(
      bool isuserloggedIn) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return await sharedPrefs.setBool(
        sharedPreferenceLoggedinKey, isuserloggedIn);
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return await sharedPrefs.setString(sharedPreferenceUserNameKey, userName);
  }

  static Future<bool> saveUserEmailSharedPreference(String userEmail) async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return await sharedPrefs.setString(sharedPreferenceUserEmailKey, userEmail);
  }

  static Future<bool?> getUserLoggedinSharedPreference() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool(sharedPreferenceLoggedinKey);
  }

  static Future<String?> getUserNameSharedPreference() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString(sharedPreferenceUserNameKey);
    
  }
  static Future<String?> getUserEmailSharedPreference() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getString(sharedPreferenceUserEmailKey) == null?"":sharedPrefs.getString(sharedPreferenceUserEmailKey);

  }
}
