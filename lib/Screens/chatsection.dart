import 'package:chat_app/Screens/signin.dart';
import 'package:chat_app/Services/auth.dart';
import 'package:chat_app/Services/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/helperfunctions.dart';
import 'search.dart';

class ChatSection extends StatefulWidget {
  ChatSection({this.user});
  final user;

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  @override
  void initState() {
    // TODO: implement initState
    
    super.initState();
  }

  // getUserInfo() async {
  //   SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  //   Constants.myName =
  //       sharedPrefs.get(HelperFunctions.sharedPreferenceUserNameKey) as String;
  // }

  late AuthMethods _authMethods;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  _authMethods = AuthMethods(context);

                  await _authMethods.signout();
                  SharedPreferences sharedpref =
                      await SharedPreferences.getInstance();
                  sharedpref.setBool('showsignin', true);

                  HelperFunctions.saveUserLoggedInSharedPreference(false);
                  HelperFunctions.saveUserEmailSharedPreference("");
                  HelperFunctions.saveUserNameSharedPreference("");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return SignIn();
                  }));
                },
                icon: Icon(Icons.logout))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search_outlined),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: ((context) => Search())));
          },
        ),
        body: SafeArea(
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("CHAT SECTION",
                  style: TextStyle(color: Colors.blue, fontSize: 30)),
              Text(
                "LOGGED IN AS ",
              ),
              Text(Constants.myName),
            ]),
          ),
        ));
  }
}
