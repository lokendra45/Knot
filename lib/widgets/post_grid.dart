import 'package:flutter/material.dart';
import 'package:knot/Screens/post_full_screen.dart';
import 'package:knot/Screens/post_screen.dart';
import 'package:knot/widgets/custom_image.dart';

class PostGrid extends StatelessWidget {
  final Post? post;

  PostGrid({required this.post});

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostFullScreen(userId: post!.ownerId, postId: post!.postId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        //when click on Grid Images
         await showPost(context);
      },
      child: cachedNetworkImage(post!.mediaUrl),
    );
  }
}
