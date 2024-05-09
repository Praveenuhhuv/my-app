import 'dart:convert';
import 'dart:io';

import '../models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, QuerySnapshot;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:PicBlockChain/models/chat_user.dart';
import 'dart:developer' as devLog;

import 'package:http/http.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

//accessing cloud storage database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //accessing  firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing self info
  static late ChatUser me;

//to return current user
  static User get user => auth.currentUser!;

//for accessing firebase messaging (push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase message token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        devLog.log('push_token: $t');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      devLog.log('Got a message whilst in the foreground!');
      devLog.log('Message data: ${message.data}');

      if (message.notification != null) {
        devLog.log(
            'Message also contained a notification: ${message.notification}');
      }
    });
  }

  //for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAKYjGv34:APA91bGRmp_GA7oqfWc75Bz-E7rlya9RSsTyl-_kEs3uGMvz0bIeo7LRO_37SrpFjSqLyk7RWFhZwiEOKq4NCoRYNgqJr6IFblo5QRjxcUT5JJdsDfzvTLxD1xDed9H_TxNBnfXqfyBw'
          },
          body: jsonEncode(body));

      devLog.log('Response status: ${res.statusCode}');
      devLog.log('Response body: ${res.body}');
    } catch (e) {
      devLog.log('\nsendPushNotificationE: $e');
    }
  }

//for gt current user exit or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for adding chatuser user for conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    devLog.log('data: ${data.docs}');

    if (data.docs.isNotEmpty) {
      // Check if the user exists and is not the current user
      if (data.docs.first.id != user.uid) {
        devLog.log('User exists: ${data.docs.first.data()}');

        // Add the user to the current user's list of chat users
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('my_users')
            .doc(data.docs.first.id)
            .set({});

        return true; // User added successfully
      } else {
        devLog.log('Current user is the same as the found user.');
        return false; // Current user is the same as the found user
      }
    } else {
      devLog.log('User with email $email does not exist.');
      return false; // User with the provided email does not exist
    }
  }

  //for checking if user exit or not
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for getting user status to active
        APIs.updateActiveStatus(true);
        devLog.log('My Data:)${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: " Hey, I'm using PicBlockChain",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

// get id's of known users from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

// get all users from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    if (userIds.isEmpty) {
      // If userIds list is empty, return an empty stream
      devLog.log('UserIds list is empty');
      return Stream.empty();
    } else {
      // If userIds list is not empty, perform the Firestore query
      devLog.log('\nUserIds : $userIds');
      return firestore
          .collection('users')
          .where('id', whereIn: userIds)
          .snapshots();
    }
  }

  //for updating user information
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

//for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    devLog.log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('Profile_Pictures/${user.uid}.$ext');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      devLog.log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

//for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  //update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///****************** chat screen related apis*******

  //chats (collection) --> conversation_id(doc)-->messages(collection)-->msg(doc)

  //useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';
// get all messages of specific conversation from a firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //msg time(also user as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

// get only last msg of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent',
            descending: true) // Order by sent time in descending order
        .limit(1) // Limit to retrieve only one document (the last message)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      devLog.log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deteteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updateMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages')
        .doc(message.sent)
        .update({'msg': updateMsg});
  }
}
