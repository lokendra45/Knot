import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:knot/Screens/home.dart';

import 'package:knot/models/users.dart';

import 'package:knot/widgets/progress_bar.dart';

class EditProfilePageWidget extends StatefulWidget {
  final String? currentUserId;

  const EditProfilePageWidget({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  _EditProfilePageWidgetState createState() => _EditProfilePageWidgetState();
}

class _EditProfilePageWidgetState extends State<EditProfilePageWidget> {
  TextEditingController displayNameTextController = TextEditingController();
  TextEditingController userNametextController = TextEditingController();
  TextEditingController bioTextController = TextEditingController();

  bool _displayNameValid = true;
  bool _userNameValid = true;
  bool _bioValid = true;

  bool isLoading = false;
  Users? _user;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    Users.fromDocument(doc);
    _user = Users.fromDocument(doc);
    displayNameTextController.text = _user!.displayName;
    userNametextController.text = _user!.username;
    bioTextController.text = _user!.bio;
    setState(() {
      isLoading = false;
    });
  }

//Text Field View
  Column buildDisplayNameField() {
    //DisplayName filed
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Display Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          maxLength: 20,
          enableSuggestions: true,
          autofocus: true,
          keyboardType: TextInputType.name,
          controller: displayNameTextController,
          decoration: InputDecoration(
              hintText: "Update Display Name",
              errorText: _bioValid ? null : "Display Name is Not set"),
        )
      ],
    );
  }

  Column buildUserNameFiled() {
    //Username Text FIled
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Username",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          maxLength: 10,
          controller: userNametextController,
          decoration: InputDecoration(
              hintText: "Update username",
              errorText: _userNameValid ? null : "UserName is not Set"),
        )
      ],
    );
  }

  Column buildBioTextFiled() {
    //Bio Filed
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          keyboardType: TextInputType.text,
          maxLength: 30,
          controller: bioTextController,
          decoration: InputDecoration(
              hintText: "Update Bio",
              errorText: _bioValid ? null : "Bio is not Set"),
        )
      ],
    );
  }

  Future updateUserData() async {
    setState(() {
      displayNameTextController.text.trim().length < 3 ||
              displayNameTextController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;

      userNametextController.text.trim().length < 3 ||
              userNametextController.text.isEmpty
          ? _userNameValid = false
          : _userNameValid = true;

      bioTextController.text.toString().isEmpty
          ? _bioValid = false
          : _bioValid = true;
    });
    if (_displayNameValid && _userNameValid && _bioValid) {
      await usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameTextController.text.toString(),
        "username": userNametextController.text.toString(),
        "bio": bioTextController.text.toString(),
      });
    }
  }

  @override
  void dispose() {
    displayNameTextController.dispose();
    userNametextController.dispose();
    bioTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            await showMyDialog();

            // Navigator.pop(context);
          },
          icon: Icon(
            Icons.cancel_rounded,
            color: Colors.red.shade900,
            size: 29.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Lato',
          ),
        ),
        actions: <Widget>[
          IconButton(
            disabledColor: Colors.grey.shade900,
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.done_rounded,
              color: Colors.red.shade900,
              size: 31,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgressBar()
          : SafeArea(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: GestureDetector(
                            onTap: () {
                              print('profile pic update');
                            },
                            child: CircleAvatar(
                              radius: 51.0,
                              backgroundImage:
                                  CachedNetworkImageProvider(_user!.photoUrl),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(children: <Widget>[
                            buildDisplayNameField(),
                            buildUserNameFiled(),
                            buildBioTextFiled(),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10.0,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () {
                              updateUserData();
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  "Profile Updated ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: Colors.green.shade600,
                              ));
                            },
                            icon: Icon(Icons.edit_rounded),
                            label: Text(
                              "Done",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(38.0),
                          child: TextButton.icon(
                              onPressed: () async {},
                              icon: Icon(Icons.logout_outlined),
                              label: Text(
                                "Logout",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  showProfilePage(context) {
    Navigator.pop(this.context);
  }

  Future<void> showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: Colors.white.withOpacity(0.7),
          title: const Text(
            'Discard Editing',
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
                'Yes',
                style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                showProfilePage(context);
                Navigator.pop(context);
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
      },
    );
  }
}
