import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;
  String email = '';
  String errorText = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Recieve an email to reset your password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 30,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onChanged: ((value) {
                        setState(() {
                          email = value;
                        });
                      }),
                      decoration: InputDecoration(
                          errorText: errorText,
                          icon: Icon(Icons.email_outlined),
                          iconColor: Colors.blue,
                          label: Text("Email")),
                    ),
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size(300,100),
                          backgroundColor: Colors.blueAccent),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (email == '') {
                          setState(() {
                            errorText = "Invalid email";
                          });
                        } else if (EmailValidator.validate(email)) {
                          final instance = await FirebaseAuth.instance;
                          await instance.sendPasswordResetEmail(email: email);
                          setState(() {
                            isLoading = false;
                          });
                          SnackBar(
                            content: Text("Email Sent",),
                          );
                          Navigator.pop(context);
                        } else {
                          SnackBar(
                            content: Text("Invalid Email"),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.arrow_back),
                          Text(
                            "Reset Password",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          )
                        ],
                      ))
                ],
              )),
      ),
    );
  }
}
