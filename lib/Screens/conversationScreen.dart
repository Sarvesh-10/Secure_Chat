import 'package:chat_app/Services/constants.dart';
import 'package:chat_app/Services/helperfunctions.dart';
import 'package:chat_app/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as prefix;
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:chat_app/model/messages.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

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

  final key = prefix.Key.fromUtf8('my 32 length key................');
  final iv = IV.fromLength(16);

  Encrypter? encrypter;
  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> map = {
        "message": encrypter!.encrypt(messageController.text, iv: iv).base64,
        "sent_by": Constants.myName,
        "time": DateTime.now(),
      };
      await dbMethods.addMessages(widget.chatRoomId, map);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    encrypter = Encrypter(AES(key));
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
            // Expanded(child: ChatMessages()),
            Expanded(child: MessageStream(chatRoomId: widget.chatRoomId)),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Emoji(),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                        ),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: "Message...",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                          ),
                        ),
                      )),
                      IconButton(
                          onPressed: () async {
                            await sendMessage();
                            messageController.clear();
                            Focus.of(context).unfocus();
                          },
                          icon: Icon(
                            Icons.telegram_sharp,
                            color: Colors.blueGrey,
                            size: 40,
                          )),
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

class MessageStream extends StatefulWidget {
  MessageStream({required this.chatRoomId});
  final chatRoomId;

  @override
  State<MessageStream> createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  @override
  final key = prefix.Key.fromUtf8('my 32 length key................');
  final iv = IV.fromLength(16);
  Encrypter? encrypter;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    encrypter = Encrypter(AES(key));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Chatroom')
          .doc(widget.chatRoomId)
          .collection('Chats')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data!.docs;
          List<Messages> msgs = [];
          for (var m in messages) {
            Map data = m.data();

            final msg = encrypter!.decrypt64(data['message'], iv: iv);
            final sent_by = data['sent_by'];
            Timestamp time = data['time'];

            msgs.add(
                Messages(message: msg, sentBy: sent_by, time: time.toDate()));
          }
          return GroupedListView(
            reverse: true,
            
            useStickyGroupSeparators: true,
            floatingHeader: true,
            elements: msgs,
            groupBy: (Messages element) {
              return DateTime(
                  element.time.day, element.time.month, element.time.year);
            },
            groupHeaderBuilder: (Messages message) => SizedBox(
              height: 70,
              child: Center(
                  child: Card(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    DateFormat.yMMMMd().format(message.time),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )),
            ),
            itemBuilder: (context, Messages mssge) {
              return Align(
                alignment: Constants.myName == mssge.sentBy
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topLeft: mssge.sentBy == Constants.myName
                        ? Radius.circular(20)
                        : Radius.zero,
                    topRight: mssge.sentBy == Constants.myName
                        ? Radius.zero
                        : Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
                  color: mssge.sentBy == Constants.myName
                      ? Colors.deepOrange
                      : Colors.grey,
                  elevation: 8,
                  child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            mssge.message,
                            style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                fontSize: 17),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            mssge.time.hour.toString() +
                                ":" +
                                mssge.time.minute.toString(),
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      )),
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }
}

class Emoji extends StatelessWidget {
  const Emoji({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Icon(Icons.emoji_emotions_outlined),
        onPressed: (){},
      ),
    );
  }

  // void onClicked() async {
  //   await SystemChannels.textInput.invokeMethod('TextInput.hide');
  //   await Future.delayed(Duration(milliseconds: 100));
  // }
}
