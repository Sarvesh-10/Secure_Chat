import 'package:chat_app/Screens/chatsection.dart';
import 'package:chat_app/Screens/forgotpassword.dart';
import 'package:chat_app/Screens/signup.dart';
import 'package:chat_app/Services/auth.dart';
import 'package:chat_app/Services/constants.dart';
import 'package:chat_app/Services/helperfunctions.dart';
import 'package:chat_app/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isloading = false;
  final formKey = GlobalKey<FormState>();
  bool correctMail = false;
  String _email = '';
  String _password = '';
  DatabaseMethods dbMethods = DatabaseMethods();
  late AuthMethods auth;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = AuthMethods(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(20),
                    child: const Text("LOGIN",
                        style: TextStyle(
                            fontSize: 30,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35)),
                          color: Colors.blueAccent.shade200),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Form(
                          key: formKey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      _email = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Enter Email Id';
                                    },
                                    style: TextStyle(color: Colors.white),
                                    keyboardAppearance: Brightness.dark,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      icon: Icon(
                                        Icons.email,
                                        color: Colors.white,
                                      ),
                                      focusColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      label: Text(
                                        "Email ID",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(20),
                                ),
                                Container(
                                  child: TextFormField(
                                    obscureText: true,
                                    onChanged: (value) {
                                      _password = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Enter password';
                                    },
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      icon: Icon(
                                        Icons.password_outlined,
                                        color: Colors.white,
                                      ),
                                      focusColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      label: Text(
                                        "Password",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(20),
                                ),
                                Container(
                                  padding: EdgeInsets.only(right: 15),
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return ForgotPassword();
                                      }));
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ),
                                TextButton(
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        if (EmailValidator.validate(_email)) {
                                          setState(() {
                                            isloading = true;
                                          });

                                          User user = await auth
                                              .signInWithEmailPassword(
                                                  _email, _password);

                                          await dbMethods
                                              .getUserbyUserEmail(_email)
                                              .then((value) {
                                            QuerySnapshot snap = value;
                                            snap.docs[0].get('name');
                                            Constants.myName =
                                                snap.docs[0].get('name');
                                            HelperFunctions
                                                .saveUserEmailSharedPreference(
                                                    _email);
                                            HelperFunctions
                                                .saveUserNameSharedPreference(
                                                    snap.docs[0].get('name'));
                                            HelperFunctions
                                                .saveUserLoggedInSharedPreference(
                                                    true);
                                          });
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          prefs.setBool('showsignin', false);
                                          setState(() {
                                            isloading = false;
                                          });
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ChatSection(user: user);
                                          }));
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: ((context) {
                                                return AlertDialog(
                                                  content: Text(
                                                      "INVALID EMAIL!!",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18)),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text("OK"))
                                                  ],
                                                );
                                              }));
                                        }
                                      }
                                    },
                                    child: Text("SIGN IN",
                                        style: TextStyle(color: Colors.blue)),
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        fixedSize: Size(100, 20))),
                                SizedBox(
                                  height: 40,
                                ),
                                Text("OR",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 30)),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.white),
                                          child: Image.asset(
                                              'assets/Images/icons8-google-48.png')),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.white),
                                          child: Image.asset(
                                              'assets/Images/icons8-meta-48.png')),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.white),
                                          child: Image.asset(
                                              'assets/Images/icons8-twitter-48.png')),
                                    ]),
                                SizedBox(
                                  height: 40,
                                ),
                                InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return Signup();
                                      }));
                                    },
                                    child: Text("Create an account",
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.white,
                                            fontSize: 12))),
                              ]),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
    );
  }
}
