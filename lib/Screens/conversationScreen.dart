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
  ConversationScreen({required this.chatRoomId, required this.userName});
  final chatRoomId;
  final userName;

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
        "time": DateTime.now().millisecondsSinceEpoch
      };
      await dbMethods.addMessages(widget.chatRoomId, map);
    }
  }

  ScrollController _controller = ScrollController();
  Stream<DocumentSnapshot<Map<String, dynamic>>>? chatStream;
  Widget ChatMessages() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Chatroom')
            .doc(widget.chatRoomId)
            .collection('Chats')
            .orderBy('time',descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              reverse: true,
                
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var snaps = snapshot.data!.docs[index];

                  return MessageTile(
                      message: snaps.get('message'),
                      sent_by: snaps.get('sent_by'));
                });
          }

          return Container();
        });
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

   
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName.toString()),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: ChatMessages()),
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
                            Focus.of(context).unfocus();
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
      width: MediaQuery.of(context).size.width,
      alignment: sent_by == Constants.myName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft:
                sent_by == Constants.myName ? Radius.circular(20) : Radius.zero,
            topRight:
                sent_by == Constants.myName ? Radius.zero : Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: sent_by == Constants.myName ? Colors.blue : Colors.green,
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}


// https://github.com/Sarvesh-10/ChatApp
// git config --global user.email "you@example.com"
//   git config --global user.name "Your Name"