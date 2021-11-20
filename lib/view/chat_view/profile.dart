// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables

import 'package:chat_app/api/authFunctions.dart';
import 'package:chat_app/view/auth/forgetPassword.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/api/databaseFunctions.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userData;
  var name, email, photoUrl;
  @override
  void initState() {
    searchMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(54, 57, 63, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(49, 110, 125, 1),
        title: Text("Profile"),
        actions: [
          IconButton(
            onPressed: () {
              Api api = Api();
              api.signOut(context);
            },
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: userData != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(500),
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                            )),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 20),
                          Text(name,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25)),
                          SizedBox(height: 20),
                          Text(email,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25)),
                          SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgetPassword()));
                            },
                            child: Text(
                              "reset Password",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  searchMethod() async {
    DataBase dataBase = DataBase();
    await dataBase.getUserData().then((value) {
      setState(() {
        userData = value;
        name = userData["name"];
        email = userData["email"];
        photoUrl = userData["photoUrl"];
      });
    });
  }
}
