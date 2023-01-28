import 'package:chat_app/Screens/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final context;
  AuthMethods(this.context);

  FirebaseAuth get auth {
    return _auth;
  }

  Future signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential response = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = response.user!;
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'ERROR_WRONG_PASSWORD') {
        showDialog(
            context: context,
            builder: ((context) => AlertDialog(
                  title: Text("Wrong Password"),
                  content:
                      Text("Wrong Password!! Reset the password or try again"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return SignIn();
                          }));
                        },
                        child: Text("Ok"))
                  ],
                )));
      } else {
        showDialog(
            context: context,
            builder: ((context) => AlertDialog(
                  title: Text(
                    e.code,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return SignIn();
                          }));
                        },
                        child: Text("Ok"))
                  ],
                )));
      }
    }
  }

  Future signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential response = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return response.user!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        showDialog(
            context: context,
            builder: ((context) => AlertDialog(
                  title: Text("Already exist"),
                  content: Text("User already exists try login in"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return SignIn();
                          }));
                        },
                        child: Text("Ok"))
                  ],
                )));
      } else if (e.code == 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL') {
        showDialog(
            context: context,
            builder: ((context) => AlertDialog(
                  title: Text("Already exist"),
                  content: Text("Account exists with different credential"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return SignIn();
                          }));
                        },
                        child: Text("Ok"))
                  ],
                )));
      } else {
        showDialog(
            context: context,
            builder: ((context) => AlertDialog(
                  title: Text("Something went wrong"),
                  content: Text(e.code),
                  actions: [
                    TextButton(
                        onPressed: () {
                             Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return SignIn();
                          }));
                        },
                        child: Text("Ok"))
                  ],
                )));
      }
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (E) {}
    ;
  }

  Future signout() async {
    try {
      return await _auth.signOut();
    } catch (E) {}
    ;
  }
}
