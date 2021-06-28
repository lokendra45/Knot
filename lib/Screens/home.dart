import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:knot/Screens/notification_screen.dart';
import 'package:knot/Screens/profile_screen.dart';
import 'package:knot/Screens/search_screen.dart';
import 'package:knot/Screens/timeline_screen.dart';

import 'package:knot/Screens/upload_screen.dart';
import 'package:knot/models/users.dart';

import 'account_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

final GoogleSignIn googleSignIn = GoogleSignIn();
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection("Users");
final postRef = FirebaseFirestore.instance.collection("posts");
final commentRef = FirebaseFirestore.instance.collection("comments");
final activityFeedRef = FirebaseFirestore.instance.collection("notification");
final followersRef = FirebaseFirestore.instance.collection("followers");
final followingRef = FirebaseFirestore.instance.collection("following");

final timeStamp = DateTime.now().toLocal();
Users? currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoggedIn = false;

  PageController? pageController;

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController(
      initialPage: 0,
    );
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((dynamic event) {
      handleSigIn(event);
    }, onError: (err) {
      print(err);
    });
    // Reauthenticate user when app is opened

    googleSignIn.signInSilently(suppressErrors: false).then((dynamic event) {
      handleSigIn(event);
    }).catchError((err) {
      print(err);
    });
  }

  Future handleSigIn(dynamic account) async {
    if (account != null) {
      await _createUserInDatabase();
      setState(() {
        isLoggedIn = true;
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  Future login() async {
    await googleSignIn.signIn();
  }

  Future<Null> logout() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();

    setState(() {
      isLoggedIn = false;
    });
  }

//Create Account
  _createUserInDatabase() async {
    final GoogleSignInAccount? googleUser = googleSignIn.currentUser;
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    DocumentSnapshot documentSnapshot = await usersRef.doc(googleUser.id).get();
    if (!documentSnapshot.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      usersRef.doc(googleUser.id).set(
        {
          "id": googleUser.id,
          "username": username,
          "photoUrl": googleUser.photoUrl,
          "email": googleUser.email,
          "displayName": googleUser.displayName,
          "bio": "",
          "timestanmp": timeStamp,
        },
      );
      documentSnapshot = await usersRef
          .doc(googleUser.id)
          .get(); // update the snapshot from document
    }
    currentUser = Users.fromDocument(documentSnapshot);
    print(currentUser!.username);
    print(currentUser);
    print(googleUser.id);
    print(currentUser!.id);
    return await firebaseAuth.signInWithCredential(credential);
  }

  @override
  void dispose() {
    pageController!.dispose();

    super.dispose();
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 70),
          child: Text(
            'Knot',
            style: GoogleFonts.aclonica(
              fontSize: MediaQuery.of(context).size.height / 25,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {},
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.indigo,
            ),
            labelText: 'E-mail'),
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        onChanged: (value) {},
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.password_rounded,
            color: Colors.indigo,
          ),
          labelText: 'Password',
        ),
      ),
    );
  }

  Widget _buildForgetPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextButton(
          onPressed: () {},
          child: Text("Forgot Password"),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 45,
          width: 100,
          margin: EdgeInsets.only(bottom: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.indigo,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0))),
            onPressed: () {},
            child: Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1,
                fontSize: 20,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildOrRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Text(
            '- OR -',
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGoogleBtnRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () async {
            await login();
          },
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 7.0)
              ],
            ),
            child: Icon(
              FontAwesomeIcons.google,
              color: Colors.redAccent,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Login",
                        style: GoogleFonts.acme(
                          fontSize: MediaQuery.of(context).size.height / 30,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  _buildEmailRow(),
                  _buildPasswordRow(),
                  _buildForgetPasswordButton(),
                  _buildLoginButton(),
                  _buildOrRow(),
                  _buildGoogleBtnRow(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: TextButton(
            onPressed: () {},
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: 'Sign Up ',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

//Login screen view widget
  Widget buildLoginScreen() {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          //  resizeToAvoidBottomPadding: false,
          backgroundColor: Color(0xfff2f3f7),
          body: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(70),
                      bottomRight: const Radius.circular(70),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildLogo(),
                    _buildContainer(),
                    _buildSignUpBtn(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  onPageChnaged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController!.animateToPage(pageIndex,
        duration: Duration(milliseconds: 350), curve: Curves.easeOut);
  }

  Scaffold buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          //TimeLine(),
          ElevatedButton(
            onPressed: () async {
              await logout();
            },
            child: Text("Logout"),
          ),
          Search(),
          Upload(currentUser: currentUser),
          ActivityFeed(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChnaged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: pageIndex,
        onTap: onTap,
        selectedItemColor: Colors.deepPurple.shade900,
        backgroundColor: Colors.teal.shade50,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                size: 30.0,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search_rounded,
                size: 30.0,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.camera,
                size: 30.0,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
                size: 30.0,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle_outlined,
                size: 30.0,
              ),
              label: ""),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return buildHomeScreen();
    }
    return buildLoginScreen();
  }
}
