import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knot/Screens/comments.dart';
import 'package:knot/Screens/home.dart';
import 'package:knot/Screens/notification_screen.dart';
import 'package:knot/models/users.dart';
import 'package:knot/widgets/progress_bar.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  Post(
      {required this.postId,
      required this.ownerId,
      required this.username,
      required this.location,
      required this.description,
      required this.mediaUrl,
      required this.likes});

  factory Post.fromDocument(dynamic doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }
  int getLikeCounts(Map likes) {
    //if no likes, return 0
    if (this.likes == null) {
      return 0;
    }

    //if the key is explictly set to true, add like
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
      print(val);
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      likeCount: getLikeCounts(this.likes));
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser!.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool showHeart = false;
  bool? isLiked;

  _PostState({
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.mediaUrl,
    required this.likes,
    required this.likeCount,
  });
  buildPostHeader() {
    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgressBar();
          }
          Users users = Users.fromDocument(snapshot.data!);
          bool isPostOwner = currentUserId == ownerId;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(users.photoUrl),
              backgroundColor: Colors.grey.shade800,
            ),
            title: GestureDetector(
              onTap: () {
                //when click on userName
                showProfile(context, profileId: users.id);
              },
              child: Text(
                users.username,
                style: GoogleFonts.notoSans(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: (Text(location)),
            trailing: IconButton(
                onPressed: () {
                  if (isPostOwner) {
                    handleDeletePost(context);
                  } else {
                    Text('');
                  }
                },
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.deepPurple.shade600,
                )),
          );
        });
  }

// FUnction to handle the Delte post
  handleDeletePost(BuildContext parentContex) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            backgroundColor: Colors.white,
            title: const Text(
              'Delete Post',
              style: TextStyle(color: Colors.deepPurple),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('Are You Sure ?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Delete',
                  style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

// To  dele post its must be ownerid to curentuserid
  deletePost() async {
    postRef
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId)
        .get()
        .then((docPost) {
      if (docPost.exists) {
        docPost.reference.delete();
      }
    });
    // also delte user image for that post
    storageRef.child("post_$postId.jpg").delete();

    // Also delte the Notifications of that users
    QuerySnapshot feedSnapshot = await activityFeedRef
        .doc(ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: postId)
        .get();
    feedSnapshot.docs.forEach((notificationSnapshot) {
      if (notificationSnapshot.exists) {
        notificationSnapshot.reference.delete();
      }
    });
    // Also delte all comment of that users
    QuerySnapshot commentSnapshot =
        await commentRef.doc(postId).collection('comments').get();

    commentSnapshot.docs.forEach((commentDocSnapshot) async {
      if (commentDocSnapshot.exists) {
        commentDocSnapshot.reference.delete();
      }
    });
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      addLikeNotification();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  //Function for Like Notification
  dynamic addLikeNotification() {
    bool isNotPostOwner = ownerId != currentUserId;
    if (isNotPostOwner) {
      activityFeedRef.doc(ownerId).collection("feedItems").add({
        "type": "like",
        "username": currentUser!.username,
        "userId": currentUser!.id,
        "userProfilephoto": currentUser!.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timeStamp,
      });
    }
  }

  dynamic removeLikeFromActivityFeed() {
    bool isNotPostOwner = ownerId != currentUserId;
    if (isNotPostOwner) {
      activityFeedRef
          .doc(ownerId)
          .collection("feedItems")
          .doc(postId)
          .get()
          .then((value) {
        if (value.exists) {
          value.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        handleLikePost();
      },
      child: Stack(
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        children: <Widget>[
          CachedNetworkImage(imageUrl: mediaUrl),
          if (showHeart)
            Icon(
              Icons.favorite,
              size: 80.0,
              color: Colors.purple.shade900,
            )
          else
            Text(""),
        ],
      ),
    );
  }

  buildFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () {
                handleLikePost();
              },
              child: Icon(
                isLiked! ? Icons.favorite : Icons.favorite_border_rounded,
                size: 28.0,
                color: Colors.purple.shade900,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 18.0),
            ),
            GestureDetector(
              onTap: () {
                showUserComments(
                  context,
                  postId: postId,
                  ownerId: ownerId,
                  mediaUrl: mediaUrl,
                );
              },
              child: Icon(
                Icons.mode_comment_rounded,
                color: Colors.grey.shade700,
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: GoogleFonts.notoSans(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$description",
                style: GoogleFonts.notoSans(
                  color: Colors.black,
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        Divider(
          height: 15.0,
          thickness: 1,
          color: Colors.grey.shade300,
        ),
        buildFooter(),
      ],
    );
  }
}

showUserComments(BuildContext context,
    {required String postId,
    required String ownerId,
    required String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
