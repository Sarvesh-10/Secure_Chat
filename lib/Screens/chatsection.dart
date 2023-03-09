import 'package:chat_app/Screens/conversationScreen.dart';
import 'package:chat_app/Screens/signin.dart';
import 'package:chat_app/Services/auth.dart';
import 'package:chat_app/Services/constants.dart';
import 'package:chat_app/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/helperfunctions.dart';
import 'search.dart';
import 'package:chat_app/model/messages.dart';
import 'package:encrypt/encrypt.dart' as prefix;

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
          return ListView.separated(
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
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                color: Colors.black,
              );
            },
          );
        }
        return Container();
      },
    );
  }

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
          return ConversationScreen(chatRoomId: chatRoomId, userName: userName);
        }));
      },
      child: ListTile(
          leading: Profile(
            userName: userName,
          ),
          title: Text(userName),
          subtitle: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Chatroom')
                .doc(chatRoomId)
                .collection('Chats')
                .orderBy('time', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final key =
                    prefix.Key.fromUtf8('my 32 length key................');
                final iv = IV.fromLength(16);
                Encrypter encrypter = Encrypter(AES(key));
                var snap = snapshot.data!.docs[0];
                String lasMsg = "";
                if (snap['type'] == 'text') {
                  lasMsg = encrypter.decrypt64(snap.get('message'), iv: iv);
                }
                Timestamp time = snap.get('time');
                DateTime fetched = time.toDate();
                String timeOrDate;
                if (DateFormat.yMMMMd().format(DateTime.now()) ==
                    DateFormat.yMMMMd().format(fetched)) {
                  timeOrDate =
                      fetched.hour.toString() + ":" + fetched.minute.toString();
                } else {
                  timeOrDate = DateFormat.yMMMMd().format(fetched);
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    snap['type'] == 'text'?Text(lasMsg):Icon(Icons.image),
                    Text(timeOrDate),
                  ],
                );
              }
              return Text("");
            },
          )),
    );
  }
}

class Profile extends StatelessWidget {
  Profile({required this.userName});
  final String userName;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Text(
        "${userName.substring(0, 1).toUpperCase()}",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
