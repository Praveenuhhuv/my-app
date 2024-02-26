import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:pbc/main.dart';
import '../main.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .0, vertical: 4),
      color: Color.fromARGB(255, 170, 213, 248),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0.5,
      child: InkWell(
        onTap: () {},
        child: const ListTile(
          leading: CircleAvatar(
              child: Icon(CupertinoIcons.person),
              backgroundColor: Color.fromARGB(255, 5, 133, 238)),
          title: Text('Demo User'),
          subtitle: Text('Last user message', maxLines: 1),
          trailing: Text(
            '12:00  PM',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
