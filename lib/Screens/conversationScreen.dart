import 'package:chat_app/Services/constants.dart';
import 'package:chat_app/Services/helperfunctions.dart';
import 'package:chat_app/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:chat_app/model/messages.dart';

class ConversationScreen extends StatefulWidget {
  ConversationScreen({required this.chatRoomId});
  final chatRoomId;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseMethods dbMethods = new DatabaseMethods();
  TextEditingController messageController = TextEditingController();

  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> map = {
        "message": messageController.text,
        "sent_by": Constants.myName,
        
      };
      await dbMethods.addMessages(widget.chatRoomId, map);
    }
  }

  Stream<Iterable<Messages>> readMessages() {
    return FirebaseFirestore.instance
        .collection('Chatroom')
        .doc(widget.chatRoomId)
        .collection('Chats')
        .snapshots()
        .map((event) => event.docs.map((e) => Messages.fromJson(e.data())));
  }

  
  Stream<DocumentSnapshot<Map<String, dynamic>>>? chatStream;
  Widget ChatMessages() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Chatroom').doc(widget.chatRoomId).collection('Chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var snaps = snapshot.data!.docs[index];

                  print("HERE I AM ");
                  return MessageTile(
                      message: snaps.get('message'), sent_by:snaps.get('sent_by'));
                });
          }

          return Container();
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    dbMethods.getMessages(widget.chatRoomId).then((val) {
      setState(() {
        chatStream = val;
      });
    });
    super.initState();
  }

  Widget Message(Messages m) {
    return MessageTile(message: m.message!, sent_by: m.sentBy!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat App"),
      ),
      body: Container(
        child: Stack(
          children: [
            ChatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: "Message...",
                          border: InputBorder.none,
                        ),
                      )),
                      IconButton(
                          onPressed: () async {
                            await sendMessage();
                            messageController.clear();
                          },
                          icon: Icon(Icons.send)),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  MessageTile({required this.message, required this.sent_by});
  final String message;
  final String sent_by;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: sent_by == Constants.myName ? Colors.blue : Colors.white54,
      alignment: sent_by == Constants.myName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Text(
        message,
        style: TextStyle(
            color: sent_by == Constants.myName ? Colors.white : Colors.black),
      ),
    );
  }
}


// https://github.com/Sarvesh-10/ChatApp
// git config --global user.email "you@example.com"
//   git config --global user.name "Your Name"