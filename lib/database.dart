import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseMethods {
  getUserbyUsername(String userName) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("name", isEqualTo: userName)
        .get();
  }

  getUserbyUserEmail(String Email) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: Email)
        .get();
  }

  uploaduserInfo(Map<String, String> userMap) {
    FirebaseFirestore.instance.collection("users").add(userMap).catchError((e) {
      // ignore: avoid_print
      print('error');
    });
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection('Chatroom')
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addMessages(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection('Chatroom')
        .doc(chatRoomId)
        .collection('Chats')
        .add(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  // getMessages(String chatRoomId) async {
  //   return await FirebaseFirestore.instance
  //       .collection('Chatroom')
  //       .doc(chatRoomId)
  //       .collection('Chats')
  //       .orderBy('time')
  //       .snapshots();
  // }

  getChatRooms(String userName) async {
    return await FirebaseFirestore.instance
        .collection('Chatroom')
        .where('users', arrayContains: userName)
        .snapshots();
  }
}
