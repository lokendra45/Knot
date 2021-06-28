import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knot/Screens/home.dart';
import 'package:knot/Screens/post_screen.dart';
import 'package:knot/models/users.dart';
import 'package:knot/widgets/header.dart';
import 'package:knot/widgets/post_grid.dart';
import 'package:knot/widgets/progress_bar.dart';

import 'edit_profile.dart';
import 'no_post_screen.dart';

class Profile extends StatefulWidget {
  final String? profileId;

  Profile({required this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String? currentUserId = currentUser?.id;
  String postViewStyle = "gridView";
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowersCount();
    getFollowingCount();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    // Check if already follow that users
    DocumentSnapshot document = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();

    setState(() {
      isFollowing = document.exists;
    });
    print(isFollowing);
  }

  getFollowersCount() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection("userFollowers")
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
    print(followerCount);
  }

  getFollowingCount() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection("userFollowing")
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
    print(followerCount);
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs
          .map((doc) => Post.fromDocument(doc))
          .toList(growable: true);
    });
  }

  editProfile() {
    Navigator.push(
      this.context,
      MaterialPageRoute(
          builder: (context) => EditProfilePageWidget(
                currentUserId: currentUserId,
              )),
    );
  }

  //build button on users condtion
  buildButton({required String text, required Function function}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: isFollowing
                ? MaterialStateProperty.all(Colors.white)
                : MaterialStateProperty.all(Colors.indigo.shade600),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                    color:
                        isFollowing ? Colors.grey.shade900 : Colors.deepPurple,
                    width: 1,
                  )),
            )),
        onPressed: () async {
          await function();
        },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 18,
            color: isFollowing ? Colors.blue.shade700 : Colors.white,
          ),
        ),
      ),
    );
  }

  // Button for Profile header
  buildProfileButton() {
    // View our own profile and follow button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: "Edit Profile", function: editProfile);
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnFollowUsers,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUsers,
      );
    }
  }

  handleUnFollowUsers() {
    setState(() {
      isFollowing = false;
    });
    // Remove the followers
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    // reomve Following
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    // Delte Notifiication to users
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  handleFollowUsers() {
    setState(() {
      isFollowing = true;
    });
    //Make auth user follower of antoehre user update their followers collection
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});

    // Users on our folowing collections
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    // Notifiication to users
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser!.username,
      "userId": currentUserId,
      "userProfilephoto": currentUser!.photoUrl,
      "timestamp": timeStamp,
    });
  }

  buildProfilePost() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (posts.isEmpty) {
      return NoPostScreen();
    } else if (postViewStyle == "gridView") {
      List<GridTile> gridTiles = [];
      posts.forEach((element) {
        gridTiles.add(
          GridTile(
            child: PostGrid(post: element),
          ),
        );
      });
      return GridView.count(
        padding: EdgeInsets.zero,
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 2.5,
        mainAxisSpacing: 2.5,
        shrinkWrap: true,
        primary: false,
        //  physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: gridTiles,
      );
    } else if (postViewStyle == "listView") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: posts,
      );
    }
  }

  buildToogleView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () {
            setState(() {
              postViewStyle = "gridView";
            });
          },
          icon: Icon(
            Icons.grid_view_rounded,
            size: 25,
          ),
          color: postViewStyle == "gridView"
              ? Colors.deepPurple.shade500
              : Colors.grey,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              postViewStyle = "listView";
            });
            print(postViewStyle);
          },
          icon: Icon(
            Icons.photo_size_select_actual_outlined,
            size: 25,
          ),
          color: postViewStyle == "listView"
              ? Colors.deepPurple.shade500
              : Colors.grey,
        )
      ],
    );
  }

  Future<Null> logout() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgressBar();
        }
        Users user = Users.fromDocument(snapshot.data);
        return Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Knot",
                style: GoogleFonts.pacifico(
                  color: Colors.white,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    logout();
                  },
                  icon: Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 31,
                  ),
                ),
              ],
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 28.0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  })),
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 8, 0, 0),
                            child: Icon(
                              Icons.alternate_email_rounded,
                              color: Colors.grey.shade600,
                              size: 17,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(1, 8, 0, 0),
                            child: Text(
                              user.username,
                              style: GoogleFonts.aBeeZee(
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(12, 0, 0, 1),
                              child: Container(
                                width: 100,
                                height: 100,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment(-0.4, -0.02),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(1, 0, 0, 0),
                                        child: Container(
                                          width: 100,
                                          height: 96,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image(
                                            image: CachedNetworkImageProvider(
                                                user.photoUrl),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment(1, 1),
                                      child: Container(
                                        width: 27,
                                        height: 27,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF1062AE),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          CupertinoIcons.add_circled,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        "$postCount".toString(),
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 17,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 3, 0, 0),
                                        child: Text('Posts',
                                            style: GoogleFonts.monda(
                                              fontSize: 16,
                                            )),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          followingCount.toString(),
                                          style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 17,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 3, 0, 0),
                                          child: Text(
                                            'Following',
                                            style: GoogleFonts.monda(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        followerCount.toString(),
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 17,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 3, 0, 0),
                                        child: Text(
                                          'Followers',
                                          style: GoogleFonts.monda(
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.55,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Align(
                                alignment: Alignment(-1, 0),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.displayName,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 3, 0, 0),
                                        child: Text(
                                          user.bio,
                                          style: TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 15,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      buildProfileButton(),
                      Divider(
                        height: 0.0,
                      ),
                      buildToogleView(),
                      Divider(
                        height: 0.0,
                      ),
                      buildProfilePost(),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
