import 'dart:io';

import 'package:chat_app/Services/constants.dart';
import 'package:chat_app/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as prefix;
import 'package:chat_app/model/messages.dart';
import 'package:flutter/rendering.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

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

  File? imageFile;
  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> map = {
        "message": encrypter!.encrypt(messageController.text, iv: iv).base64,
        "sent_by": Constants.myName,
        "type": "text",
        "time": DateTime.now(),
      };
      await dbMethods.addMessages(widget.chatRoomId, map);
    }
  }

  Future getImage() async {
    ImagePicker picker = ImagePicker();

    await picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    }); //value is of type XFile
  }

  uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;
    await FirebaseFirestore.instance
        .collection('Chatroom')
        .doc(widget.chatRoomId)
        .collection('Chats')
        .doc(fileName)
        .set({
      "message": "",
      "sent_by": Constants.myName,
      "type": "img",
      "time": DateTime.now(),
    });
    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await FirebaseFirestore.instance
          .collection('Chatroom')
          .doc(widget.chatRoomId)
          .collection('Chats')
          .doc(fileName)
          .delete();
      status = 0;
    });
    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('Chatroom')
          .doc(widget.chatRoomId)
          .collection('Chats')
          .doc(fileName)
          .update({"message": imageUrl});

      return;
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.image,
                                size: 30,
                              ),
                              onPressed: () {
                                getImage();
                              },
                            ),
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
          .orderBy('time')
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data!.docs;
          List<Messages> msgs = [];
          for (var m in messages) {
            Map data = m.data();
            String msg;
            msg = data['message'];
            if (data["type"] == "text")
              msg = encrypter!.decrypt64(data['message'], iv: iv);

            final sent_by = data['sent_by'];
            Timestamp time = data['time'];

            msgs.add(Messages(
                message: msg,
                sentBy: sent_by,
                time: time.toDate(),
                type: data['type']));
          }
          return GroupedListView(
            reverse: true,
            order: GroupedListOrder.DESC,
            useStickyGroupSeparators: true,
            floatingHeader: true,
            elements: msgs,
            groupBy: (Messages element) {
              return DateTime(
                  element.time.year, element.time.month, element.time.day);
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
              return MessageTile(
                mssge: mssge,
              );
            },
          );
        }
        return Container();
      },
    );
  }
}

class MessageTile extends StatelessWidget {
  MessageTile({required this.mssge});
  Messages mssge;

  @override
  Widget build(BuildContext context) {
    return mssge.type == 'text'
        ? Align(
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
          )
        : Container(
            height: 200,
            width: 200,
            alignment: mssge.sentBy == Constants.myName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              height: 200,
              width: 200,
              alignment: Alignment.center,
              child: mssge.message != ""
                  ? Image.network(mssge.message)
                  : CircularProgressIndicator(),
            ));
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
        onPressed: () {},
      ),
    );
  }

  // void onClicked() async {
  //   await SystemChannels.textInput.invokeMethod('TextInput.hide');
  //   await Future.delayed(Duration(milliseconds: 100));
  // }
}
