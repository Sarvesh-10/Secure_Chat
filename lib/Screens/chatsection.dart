import 'package:chat_app/Screens/conversationScreen.dart';
import 'package:chat_app/Screens/signin.dart';
import 'package:chat_app/Services/auth.dart';
import 'package:chat_app/Services/constants.dart';
import 'package:chat_app/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/helperfunctions.dart';
import 'search.dart';

class ChatSection extends StatefulWidget {
  ChatSection({this.user});
  final user;

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  Stream<QuerySnapshot>? chatRooms;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    databaseMethods.getChatRooms(Constants.myName).then((val) {
      setState(() {
        chatRooms = val;
      });
    });
  }

  Widget chatRoomList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatRooms,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return ChatRoomTile(
                  userName: snapshot.data!.docs[index]
                      .get('chatRoomId')
                      .toString()
                      .replaceAll("_", "")
                      .replaceAll(Constants.myName, ""),
                  chatRoomId: snapshot.data!.docs[index].get('chatRoomId'),
                );
              });
        }
        return Container();
      },
    );
  }

  // getUserInfo() async {
  //   SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  //   Constants.myName =
  //       sharedPrefs.get(HelperFunctions.sharedPreferenceUserNameKey) as String;
  // }

  late AuthMethods _authMethods;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  _authMethods = AuthMethods(context);

                  await _authMethods.signout();
                  SharedPreferences sharedpref =
                      await SharedPreferences.getInstance();
                  sharedpref.setBool('showsignin', true);

                  HelperFunctions.saveUserLoggedInSharedPreference(false);
                  HelperFunctions.saveUserEmailSharedPreference("");
                  HelperFunctions.saveUserNameSharedPreference("");
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return SignIn();
                  }));
                },
                icon: Icon(Icons.logout))
          ],
          title: Text("Chat Section"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search_outlined),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: ((context) => Search())));
          },
        ),
        body: SafeArea(
          child: chatRoomList(),
        ));
  }
}

class ChatRoomTile extends StatelessWidget {
  ChatRoomTile({required this.userName, required this.chatRoomId});
  final String userName;
  final String chatRoomId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ConversationScreen(chatRoomId: chatRoomId,userName:userName);
        }));
      },
      child:  Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Text("${userName.substring(0, 1).toUpperCase()}"),
            ),
            SizedBox(
              width: 40,
            ),
            Text("${userName}")
          ],
        ),
      ),
    );
  }
}
