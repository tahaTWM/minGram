// ignore_for_file: prefer_const_constructors_in_immutables, file_names, deprecated_member_use, prefer_const_constructors, unnecessary_new, avoid_print

import '../../api/authFunctions.dart';
import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController emailController = TextEditingController();
  Api api = Api();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(54, 57, 63, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(49, 110, 125, 1),
        title: Text("Reset Your Password"),
      ),
      body: Container(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: textFieldInputDecoration("Email"),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 40),
            RaisedButton(
              onPressed: () => forgetPassword(),
              child: Text("Reset Password"),
              padding: EdgeInsets.symmetric(horizontal: 75, vertical: 15),
              shape: rectangleBorder(),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration textFieldInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white54),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    );
  }

  RoundedRectangleBorder rectangleBorder() => RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(30),
      );

  forgetPassword() => api
      .resetpassword(emailController.text)
      .then((value) => Navigator.popUntil(context, (route) => false));
}
