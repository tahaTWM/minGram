// ignore_for_file: unused_field, avoid_print, missing_return, curly_braces_in_flow_control_structures, file_names, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';
import '../view/chat_view/conversionScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'databaseFunctions.dart';

class Api {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DataBase dataBase = DataBase();
  Future<bool> singIn(String email, String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      await pref.setString("username", result.user.displayName);

      await pref.setString("uid", result.user.uid.toString());

      Map<String, String> userData = {
        "name": result.user.displayName,
        "email": result.user.email,
        "profileImage": result.user.photoURL,
      };
      print(userData);
      dataBase.setUserData(userData);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("the passwors is too weak");
      } else if (e.code == 'email-already-in-use') {
        print("account is already exists");
      }
      return false;
    } catch (e) {
      print(e.toString());
    }
  }

  signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAuthentication googleSignInAuthentication;

      GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        googleSignInAuthentication = await googleSignInAccount.authentication;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final result = await _auth.signInWithCredential(credential);

      if (result == null) {
        print('result is null');
      } else {
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("uid", result.user.uid.toString());
        await pref.setString("username", googleSignInAccount.displayName);

        Map<String, String> userData = {
          "name": googleSignInAccount.displayName,
          "email": googleSignInAccount.email,
          "profileImage": googleSignInAccount.photoUrl,
        };

        dataBase.setUserData(userData);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ConversionScreen()));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> singUp(
      String fullname, String photoURL, String email, String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _auth.currentUser.updateDisplayName(fullname);
      await _auth.currentUser.updatePhotoURL(photoURL);
      if (result != null) return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("the passwors is too weak");
      } else if (e.code == 'email-already-in-use') {
        print("account is already exists");
      }
      return false;
    } catch (e) {
      print(e.toString());
    }
  }

  Future resetpassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (cotext) => MyApp()), (route) => false);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
