import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knot/Screens/post_screen.dart';
import 'package:knot/models/users.dart';

import 'home.dart';

class DebugScreen extends StatefulWidget {
  final Users? currentUsers;

  DebugScreen({required this.currentUsers});

  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<Post>? posts;
  List<String>? followingList = [];
  @override
  void initState() {
    super.initState();
    getUserTimeLine();
    getFollowing();
  }

  Future getFollowing() async {
    QuerySnapshot querySnapshot = await followersRef
        .doc(currentUser!.id)
        .collection('userFollowing')
        .get();
    if (mounted) {
      setState(() {
        followingList = querySnapshot.docs.map((e) => e.id).toList();
      });
    }
  }

  getUserTimeLine() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUsers!.id)
        .collection('timeline')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> posts = snapshot.docs.map((e) => Post.fromDocument(e)).toList();
    if (mounted) {
      setState(() {
        this.posts = posts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
