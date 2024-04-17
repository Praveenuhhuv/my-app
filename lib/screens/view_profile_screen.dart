import 'package:PicBlockChain/helper/my_date_until.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:PicBlockChain/models/chat_user.dart';
import '../main.dart';

//view profile screen to view profile of user
class viewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const viewProfileScreen({super.key, required this.user});

  @override
  State<viewProfileScreen> createState() => _viewProfileScreenState();
}

class _viewProfileScreenState extends State<viewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //hide keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.user.name)),

        floatingActionButton: //user about
            Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joined On:',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
            Text(
                MyDateUntil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: const TextStyle(color: Colors.black54, fontSize: 15)),
          ],
        ),

        //body:
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            // to solve scroll issue
            child: Column(
              children: [
                // adding space
                SizedBox(width: mq.width, height: mq.height * .03),
                //user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    //placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),

                // adding space
                SizedBox(height: mq.height * .03),
                //user email label
                Text(widget.user.email,
                    style:
                        const TextStyle(color: Colors.black87, fontSize: 16)),
                // adding space
                SizedBox(height: mq.height * .02),

                //user about
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'About:',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                    Text(widget.user.about,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
