import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:knot/widgets/progress_bar.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'home.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments(
      {required this.postId,
      required this.postOwnerId,
      required this.postMediaUrl});

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState(
      {required this.postId,
      required this.postOwnerId,
      required this.postMediaUrl});
  //  Comment view
  buildComments() {
    return StreamBuilder<QuerySnapshot>(
        // add type <QuerySnapshot>
        stream: commentRef
            .doc(postId)
            .collection('comments')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgressBar();
          }
          List<Comment> comments = [];
          snapshot.data!.docs.forEach((element) {
            comments.add(Comment.fromDocument(element));
          });
          return ListView(
            children: comments,
          );
        });
  }

  addComment() {
    commentRef.doc(postId).collection("comments").add({
      "username": currentUser!.username,
      "comment": commentController.text,
      "timestamp": Timestamp.now().toDate().toLocal(),
      "avatarUrl": currentUser!.photoUrl,
      "userId": currentUser!.id,
    });

    bool isNotPostOwner = postOwnerId != currentUser!.id;
    if (isNotPostOwner) {
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": timeStamp,
        "postId": postId,
        "userId": currentUser!.id,
        "username": currentUser!.username,
        "userProfilephoto": currentUser!.photoUrl,
        "mediaUrl": postMediaUrl,
      });
      commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 28.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Comments",
            style: GoogleFonts.pacifico(
              color: Colors.white,
              fontSize: 25.0,
              fontWeight: FontWeight.w100,
            )),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(
            height: 0.0,
            color: Colors.white,
          ),
          Card(
              margin: EdgeInsets.all(6.0),
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey, width: 1.1),
                  borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                contentPadding: EdgeInsets.all(1.2),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(style: BorderStyle.none),
                ),
                title: TextFormField(
                  controller: commentController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    labelText: "Write a Comment",
                    filled: true,
                  ),
                ),
                trailing: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        padding: EdgeInsets.only(left: 30.0)),
                    onPressed: () {
                      addComment();
                      FocusScope.of(context).unfocus();
                    },
                    icon: Icon(Icons.send_rounded),
                    label: Text(
                      "",
                    )),
              )),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;

  final Timestamp timestamp;

  Comment({
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
        username: doc['username'],
        userId: doc['userId'],
        avatarUrl: doc['avatarUrl'],
        comment: doc['comment'],
        timestamp: doc['timestamp']);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        ListTile(
          title: Text(
            comment,
            style: TextStyle(fontSize: 14),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(
          height: 0.0,
          color: Colors.white,
        ),
      ]),
    );
  }
}
