import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knot/Screens/home.dart';
import 'package:knot/Screens/post_full_screen.dart';
import 'package:knot/Screens/profile_screen.dart';

import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  void initState() {
    super.initState();
    getActivityFeed();
  }

  Future getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(currentUser!.id)
        .collection('feedItems')
        .limit(50)
        .orderBy('type', descending: true)
        .get();
    List<ActivityFeedItem> notificationItems = [];
    snapshot.docs.forEach((docs) async {
      dynamic _docdata = docs.data();
      notificationItems.add(ActivityFeedItem.fromDocument(docs, _docdata));
    });

    return notificationItems;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getActivityFeed,
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              "Notifications",
              style: GoogleFonts.pacifico(
                color: Colors.white,
                fontWeight: FontWeight.w100,
              ),
            ),
            backgroundColor: Colors.indigo.shade500),
        body: Container(
          color: Colors.white.withOpacity(0.0),
          child: FutureBuilder<dynamic>(
              future: getActivityFeed(),
              builder: (context, snapshot) {
                print(snapshot.data.toString());

                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      "No Notifications",
                      style: GoogleFonts.righteous(
                        fontSize: 18,
                        color: Colors.grey.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return ListView(
                  children: snapshot.data,
                );
              }),
        ),
      ),
    );
  }
}

Widget? notificationContentView;
String? notificationItemText;

class ActivityFeedItem extends StatelessWidget {
  final String? username;
  final String? userId;
  final String? type;
  final String? mediaUrl;
  final String? postId;
  final String? userProfilephoto;
  final String? commentData;
  final Timestamp? timestamp;

  ActivityFeedItem({
    required this.username,
    required this.userId,
    required this.type,
    required this.postId,
    required this.userProfilephoto,
    required this.commentData,
    required this.timestamp,
    required this.mediaUrl,
  });
  factory ActivityFeedItem.fromDocument(DocumentSnapshot? docs, Map? docdata) {
    return ActivityFeedItem(
      username: docdata!['username'],
      userId: docs!['userId'],
      type: docdata['type'],
      postId: docdata['postId'],
      userProfilephoto: docdata['userProfilephoto'],
      commentData: docdata['commentData'],
      timestamp: docdata['timestamp'],
      mediaUrl: docdata['mediaUrl'],
    );
  }
  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PostFullScreen(userId: userId!, postId: postId!)));
  }

  notificationViewType(context) {
    if (this.type == "like" || this.type == "comment") {
      notificationContentView = GestureDetector(
        onTap: () async {
          await showPost(context);
        },
        child: Container(
          height: 60.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(mediaUrl!),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      notificationContentView = Text(" ");
    }
    if (this.type == "like") {
      notificationItemText = "Liked Your Photo";
    } else if (this.type == "follow") {
      notificationItemText = "is following you";
    } else if (this.type == "comment") {
      notificationItemText = "replied : $commentData";
    } else {
      notificationItemText = "Something went wrong$this.type";
    }
    print(type.toString());
  }

  @override
  Widget build(BuildContext context) {
    notificationViewType(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: 15.0,
      ),
      child: Container(
        color: Colors.white,
        child: Card(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey, width: 0),
              borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(style: BorderStyle.none),
            ),
            title: GestureDetector(
              onTap: () {
                //when click on notification
                showProfile(context, profileId: userId!);
              },
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: GoogleFonts.amiko(fontSize: 17, color: Colors.black),
                  children: [
                    TextSpan(
                      text: username,
                      style:
                          GoogleFonts.varelaRound(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text: " $notificationItemText",
                    ),
                  ],
                ),
              ),
            ),
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfilephoto!),
            ),
            subtitle: Text(
              timeago.format(timestamp!.toDate()),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: notificationContentView,
          ),
        ),
      ),
    );
  }
}

// show profile when user click on photo
showProfile(BuildContext context, {required String profileId}) {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => Profile(profileId: profileId)));
}
