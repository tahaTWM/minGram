// ignore_for_file: file_names, prefer_const_constructors, avoid_print, deprecated_member_use, missing_required_param, curly_braces_in_flow_control_structures, prefer_typing_uninitialized_variables

import './/api/databaseFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'charRoomScreen.dart';
import 'profile.dart';
import 'search.dart';

class ConversionScreen extends StatefulWidget {
  @override
  _ConversionScreenState createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  var userData;
  var name;
  var photoUrl;

  @override
  void initState() {
    getChatsRoom();
    getSenderData();
    super.initState();
  }

  Stream querySnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(54, 57, 63, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(49, 110, 125, 1),
        title: Text("Home Screen"),
        actions: [
          FlatButton.icon(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Profile()));
            },
            icon: userData == null
                ? Icon(Icons.account_circle_rounded, color: Colors.white)
                : Container(
                    width: 30,
                    height: 30,
                    padding: EdgeInsets.all(1.2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(500),
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                        )),
                  ),
            label: userData == null
                ? Text("Profile", style: TextStyle(color: Colors.white))
                : Text(name, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: querySnapshot == null
          ? Center(
              child: Text(
                "You didn't\ndo any Chat yet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : chatsRoomsWidget(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(49, 110, 125, 1),
        child: Icon(Icons.search),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => Search())),
      ),
    );
  }

  getChatsRoom() async {
    DataBase dataBase = DataBase();
    await dataBase.getChatRooms().then(
      (value) {
        setState(() {
          querySnapshot = value;
        });
      },
    );
  }

  chatsRoomsWidget() {
    return StreamBuilder(
      stream: querySnapshot,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                padding: EdgeInsets.symmetric(vertical: 10),
                itemBuilder: (BuildContext context, int index) {
                  final data = snapshot.data.docs[index].data() as Map;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {
                        print(data['charRoomId'].toString().split('-')[1]);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChatRoomScreen(data["charRoomId"])));
                      },
                      onLongPress: () async {
                        FirebaseFirestore.instance
                            .collection("ChatRoom")
                            .doc(data["charRoomId"])
                            .delete();
                      },
                      leading: Container(
                        width: 55,
                        height: 55,
                        padding: EdgeInsets.all(1.2),
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
                      title: Text(
                        data["users"][1],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        data["chatRoomCreateDate"]
                            .toString()
                            .split('-')[1]
                            .toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        data["chatRoomCreateDate"]
                            .toString()
                            .split('-')[0]
                            .toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  getSenderData() async {
    DataBase dataBase = DataBase();
    await dataBase.getUserData().then((value) {
      setState(() {
        userData = value;
        name = userData["name"];
        photoUrl = userData["photoUrl"];
      });
      print(userData);
    }).catchError((onError) => print(onError.toString()));
  }
}
