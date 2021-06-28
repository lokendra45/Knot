import 'package:flutter/material.dart';
import 'package:knot/Screens/home.dart';
import 'package:knot/Screens/post_screen.dart';

import 'package:knot/widgets/progress_bar.dart';

class PostFullScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostFullScreen({required this.userId, required this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: postRef.doc(userId).collection('userPosts').doc(postId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgressBar();
          }
          Post post = Post.fromDocument(snapshot.data);
          return Center(
            child: Scaffold(
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
              ),
              body: ListView(
                children: [
                  Container(
                    child: post,
                  )
                ],
              ),
            ),
          );
        });
  }
}
