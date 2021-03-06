// ignore_for_file: prefer_const_constructors, deprecated_member_use, avoid_print, unused_local_variable, curly_braces_in_flow_control_structures, prefer_typing_uninitialized_variables

import 'package:chat_app/api/databaseFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'charRoomScreen.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  QuerySnapshot querySnapshot;
  DataBase dataBase = DataBase();
  var userData;
  var name;
  var photoUrl;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(54, 57, 63, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(49, 110, 125, 1),
        title: Text("Searching..."),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                userData == null
                    ? Icon(Icons.account_circle_rounded, color: Colors.white)
                    : Container(
                        width: 30,
                        height: 30,
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
                SizedBox(width: 6),
                userData == null
                    ? Text("Profile", style: TextStyle(color: Colors.white))
                    : Text(name, style: TextStyle(color: Colors.white)),
              ],
            ),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(27),
        child: Column(
          children: [
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: " Search For Member",
                suffixIcon: IconButton(
                  onPressed: () async {
                    if (searchController.text.contains('@'))
                      await searchMethod("email");
                    else
                      await searchMethod("name");
                  },
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                hintStyle: TextStyle(color: Colors.white54),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
              ),
              style: TextStyle(color: Colors.white, fontSize: 22),
              // onChanged: (value) {
              //   setState(() {
              //     searchMethod();
              //   });
              // },
              onFieldSubmitted: (value) async {
                if (searchController.text.contains('@'))
                  await searchMethod("email");
                else
                  await searchMethod("name");
              },
              cursorColor: Colors.white,
            ),
            Expanded(
              child: querySnapshot == null
                  ? Center(
                      child: Text(
                        "Nothing Search yet",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w500),
                      ),
                    )
                  : querySnapshot.size == 0
                      ? Center(
                          child: Text(
                            "Nothing Found",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      : searchWidget(),
            )
          ],
        ),
      ),
    );
  }

  searchMethod(String type) {
    if (type == "name")
      dataBase.getUsersByUserNames(searchController.text).then(
        (value) {
          setState(() {
            querySnapshot = value;
          });
          FocusScope.of(context).unfocus();
        },
      );
    if (type == "email")
      dataBase.getUsersByEmail(searchController.text).then(
        (value) {
          setState(() {
            querySnapshot = value;
          });
          FocusScope.of(context).unfocus();
        },
      );
  }

  searchWidget() => ListView.builder(
        itemCount: querySnapshot.docs.length,
        padding: EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (BuildContext context, int index) {
          final data = querySnapshot.docs[index].data() as Map;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 60,
              height: 60,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(data['profileImage']),
                    fit: BoxFit.cover,
                  )),
            ),
            title: Text(
              data["name"],
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              data["email"],
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: ButtonTheme(
              padding: EdgeInsets.all(6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minWidth: 0,
              height: 0,
              child: RaisedButton(
                onPressed: () async {
                  List users = [];
                  var time = DateFormat('MMM d, yyyy');
                  var day = DateFormat('EEEE, hh:mm a');

                  String timeNow = time.format(DateTime.now()).toString();
                  String dayNow = day.format(DateTime.now()).toString();

                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  users.add(pref.getString("username"));
                  users.add(data["name"]);

                  String charRoomId =
                      "${pref.getString("username")}-${data["name"]}";

                  String charRoomIdRev =
                      "${data["name"]}-${pref.getString("username")}";

                  Map<String, dynamic> chatRoomMap = {
                    "chatRoomCreateDate": "$timeNow-$dayNow",
                    "charRoomId": charRoomId,
                    "users": users
                  };
                  var userID = await FirebaseFirestore.instance
                      .collection("Users")
                      .where("name", isEqualTo: data["name"])
                      .get();
                  print(data["name"]);
                  var resverID = userID.docs[0].id;

                  createRoom(charRoomId, chatRoomMap, resverID);
                },
                child: Text("Message", style: TextStyle(color: Colors.white)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.blue[300],
                elevation: 0,
              ),
            ),
          );
        },
      );

  getUserData() async {
    DataBase dataBase = DataBase();
    await dataBase.getUserData().then((value) {
      setState(() {
        userData = value;
        name = userData["name"];
        photoUrl = userData["photoUrl"];
      });
    });
  }

  createRoom(charRoomId, chatRoomMap, resverID) async {
    // QuerySnapshot result = await dataBase.checkIfChatRoom(charRoomId);
    // QuerySnapshot resul2 = await dataBase.checkIfChatRoom(chatRoomIdRversd);
    // if (result.size == 0 && resul2.size == 0) {
    await dataBase.createChatRoom(chatRoomMap);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatRoomScreen(charRoomId, resverID)));
    // }
  }
}
