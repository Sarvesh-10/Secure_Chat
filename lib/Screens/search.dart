import 'package:chat_app/Screens/conversationScreen.dart';
import 'package:chat_app/Services/constants.dart';
import 'package:chat_app/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:chat_app/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String? search;
  DatabaseMethods dbMethods = new DatabaseMethods();
  QuerySnapshot? snapshot;
  initiateSearch() {
    dbMethods.getUserbyUsername(search!).then((value) {
      setState(() {
        snapshot = value;
      });
    });
  }

  Widget SearchList() {
    return snapshot != null
        ? ListView.builder(
            itemBuilder: (context, index) {
              return SearchTile(
                email: snapshot!.docs[index].get('email'),
                userName: snapshot!.docs[index].get('name'),
              );
            },
            itemCount: snapshot!.docs.length,
          )
        : Container(
            child: Center(child: Text("USER DOES NOT EXISTS")),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search_sharp),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        label: Text(
                          "Search user name",
                          style: TextStyle(color: Colors.blue),
                        )),
                    onChanged: (value) {
                      search = value;
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      initiateSearch();
                    },
                    child: Text("Search")),
              ],
            ),
            Container(height: 200, child: SearchList())
          ],
        ),
      )),
    );
  }

  Widget userbuilder(USER user) {
    return SearchTile(userName: user.name, email: user.email);
  }
}

class SearchTile extends StatelessWidget {
  SearchTile({required this.userName, required this.email});
  DatabaseMethods dbMethods = DatabaseMethods();

  createChatRoomAndStartConvo(String userName, BuildContext context) {
    List<String> users = [userName, Constants.myName];

    String chatRoomId = generateChatRoomId(userName, Constants.myName);
    Map<String, dynamic> charRoomMap = {
      "users": users,
      "chatRoomId": chatRoomId
    };
    
    dbMethods.createChatRoom(chatRoomId, charRoomMap);
   
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ConversationScreen(chatRoomId: chatRoomId,userName: userName,);
    }));
  }

  generateChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    }

    return "$a\_$b";
  }

  final userName;
  final email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
              ),
              SizedBox(
                height: 15,
              ),
              Text(email)
            ],
          ),
          TextButton(
              onPressed: () {
                createChatRoomAndStartConvo(userName, context);
              },
              child: Text('Message', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18))))
        ],
      ),
    );
  }
}
