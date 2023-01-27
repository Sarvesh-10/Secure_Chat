import 'package:chat_app/Screens/chatsection.dart';
import 'package:chat_app/Services/auth.dart';
import 'package:chat_app/Services/constants.dart';
import 'package:chat_app/Services/helperfunctions.dart';
import 'package:chat_app/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();
  late AuthMethods auth;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = AuthMethods(context);
  }

  bool isLoading = false;

  String _username = '';
  String _email = '';
  String _password = '';

  late DatabaseMethods dbMethods;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
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
                    child: const Text("SIGN UP",
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
                                      _username = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Enter Username';
                                    },
                                    style: TextStyle(color: Colors.white),
                                    keyboardAppearance: Brightness.dark,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      icon: Icon(
                                        Icons.person,
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
                                        "Username",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(20),
                                ),
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
                                    onChanged: (value) {
                                      _password = value;
                                    },
                                    obscureText: true,
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
                                TextButton(
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        if (EmailValidator.validate(_email)) {
                                          Map<String, String> map = {
                                            "name": _username,
                                            "email": _email
                                          };
                                          HelperFunctions
                                              .saveUserLoggedInSharedPreference(
                                                  true);
                                          HelperFunctions
                                              .saveUserEmailSharedPreference(
                                                  _username);
                                          HelperFunctions
                                              .saveUserEmailSharedPreference(
                                                  _email);
                                          Constants.myName = _username;

                                          setState(() {
                                            isLoading = true;
                                          });
                                          User user = await auth
                                              .signUpWithEmailPassword(
                                                  _email, _password);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          dbMethods = new DatabaseMethods();
                                          dbMethods.uploaduserInfo(map);

                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ChatSection(
                                              user: user,
                                            );
                                          }));
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: ((context) {
                                                return AlertDialog(
                                                  title: Text("INVALID EMAIL!!",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18)),
                                                  content: Text(
                                                    "ENTER VALID EMAIL ID",
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
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
                                    child: Text("SIGN UP",
                                        style: TextStyle(color: Colors.blue)),
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        fixedSize: Size(100, 20))),
                                SizedBox(
                                  height: 20,
                                ),
                                const Text("OR",
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
