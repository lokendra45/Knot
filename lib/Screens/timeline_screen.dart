import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:knot/widgets/header.dart';
import 'package:knot/widgets/progress_bar.dart';

final database = FirebaseFirestore.instance.collection("Users");

class TimeLine extends StatefulWidget {
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  @override
  void initState() {
    //createUser();
    // updateUser();
    //deleteUser();
    super.initState();
  }

  createUser() async {
    await database.add({
      "username": "lokiz33333",
      "PostCount": 5,
      "isAdmin": false,
    });
  }

  updateUser() async {
    final document = await database.doc("d0V5LVnz45WB8OtVv9Ys").get();
    if (document.exists) {
      document.reference.update({
        "username": "bokiz",
      });
    }
  }

  deleteUser() async {
    final doce = await database.doc("qDQGZbvADCHgN2SXlNuX").get();
    if (doce.exists) {
      doce.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isApplicationTitle: true, titleText: "Knot"),
      body: StreamBuilder<QuerySnapshot>(
        stream: database.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgressBar();
          }
          final List<Text> userData =
              snapshot.data!.docs.map((e) => Text(e['username'])).toList();

          return Container(
            child: ListView(
              children: userData,
            ),
          );
        },
      ),
    );
  }
}
