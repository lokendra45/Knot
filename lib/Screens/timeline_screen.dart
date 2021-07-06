import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knot/Screens/home.dart';
import 'package:knot/Screens/post_screen.dart';
import 'package:knot/Screens/search_screen.dart';
import 'package:knot/models/users.dart';
import 'package:knot/widgets/progress_bar.dart';

final database = FirebaseFirestore.instance.collection("Users");

class TimeLineScreen extends StatefulWidget {
  final Users? currentUsers;

  TimeLineScreen({required this.currentUsers, Users? currentUser});

  @override
  _TimeLineScreenState createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  List<Post>? posts;
  List<String> followingList = [];
  @override
  void initState() {
    super.initState();
    getUserTimeLine();
    getFollowing();
  }

  Future getFollowing() async {
    QuerySnapshot querySnapshot = await followingRef
        .doc(currentUser!.id)
        .collection('userFollowing')
        .get();

    setState(() {
      followingList = querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  getUserTimeLine() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUsers!.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> _post =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    print(widget.currentUsers!.id);

    setState(() {
      this.posts = _post;
    });
  }

  buildTimeLine() {
    if (posts == null) {
      return circularProgressBar();
    } else if (posts!.isEmpty) {
      return buildSuggestionScreen();
    }

    return ListView(children: posts!);
  }

  buildSuggestionScreen() {
    return StreamBuilder<QuerySnapshot>(
      stream: usersRef
          .orderBy('timestanmp', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgressBar();
        }
        List<UserResults> userResults = [];
        snapshot.data!.docs.forEach(
          (doc) async {
            Users users = Users.fromDocument(doc);
            final bool isAuthUser = currentUser!.id == users.id;
            final bool isFollowingUser = followingList.contains(users.id);

            // remove the auth user form recommended list
            if (isAuthUser) {
              return;
            } else if (isFollowingUser) {
              return;
            } else {
              UserResults userResult = UserResults(
                user: users,
              );
              userResults.add(userResult);
            }
          },
        );
        return Container(
          color: Colors.white,
          child: Card(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(1.0),
                  child: (Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.deepPurple.shade800,
                        size: 25,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text("Follow Some users",
                          style: GoogleFonts.righteous(
                            color: Colors.black,
                            fontSize: 18,
                          )),
                    ],
                  )),
                ),
                Card(
                  elevation: 10.0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(children: userResults),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Knot",
          style: GoogleFonts.pacifico(
            color: Colors.white,
            fontWeight: FontWeight.w100,
          ),
        ),
        // backgroundColor: Colors.indigo.shade500,
      ),
      body: RefreshIndicator(
        child: buildTimeLine(),
        onRefresh: () => getUserTimeLine(),
      ),
    );
  }
}
