import 'package:chat_app/Screens/chatsection.dart';
import 'package:chat_app/Services/constants.dart';
import 'package:chat_app/Services/helperfunctions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/onboardingscreens.dart';
import 'Screens/signin.dart';
import 'Screens/signup.dart';
import 'Screens/chatsection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  final pref = await SharedPreferences.getInstance();

  bool? showsignin = pref.getBool('showsignin');
  String? name = pref.getString(HelperFunctions.sharedPreferenceUserNameKey);
  if (name != null)
    Constants.myName = name;
  else
    showsignin = true;
  runApp(MyApp(showsignin: showsignin));
}

class MyApp extends StatefulWidget {
  MyApp({required this.showsignin});
  final showsignin;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? islogin;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  Future<bool?> isLoggedIn() async {
    return HelperFunctions.getUserLoggedinSharedPreference();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool?>(
        builder: (context, snapshot) {
          if (widget.showsignin == true) {
            return SignIn();
          }
          if (snapshot.data == false) {
            return OnboardingScreens();
          }
          return ChatSection();
        },
        future: isLoggedIn(),
      ),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        applyElevationOverlayColor: true,
      ),
    );
  }
}
