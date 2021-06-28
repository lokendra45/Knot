import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:knot/Screens/home.dart';
import 'package:knot/Screens/notification_screen.dart';
import 'package:knot/models/users.dart';
import 'package:knot/widgets/progress_bar.dart';

String capitalize(String? s) {
  return s![0].toUpperCase() + s.substring(1);
}

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchContoller = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;

  void searchUsers(String searchQuery) {
    Future<QuerySnapshot> users = usersRef
        .where('displayName', isGreaterThanOrEqualTo: searchQuery.trim())
        .where('displayName', isLessThan: searchQuery.trim() + "\u{f8ff}")
        .get();

    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    setState(() {
      searchContoller.clear();
      searchResultsFuture = null;
      FocusScope.of(context).unfocus();
    });
  }

  AppBar _buildSearchBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Container(
        margin: EdgeInsets.only(
          right: 0.0,
          top: 5.0,
        ),
        child: Column(
          children: [
            TextFormField(
              controller: searchContoller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                hintText: "Search With Name",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                prefixIcon: Icon(Icons.person_search_rounded),
                suffixIcon: IconButton(
                  onPressed: clearSearch,
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.deepPurple.shade900,
                    size: 30.0,
                  ),
                ),
              ),
              onFieldSubmitted: (value) {
                if (value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "Enter some Keywords",
                    ),
                    backgroundColor: Colors.red.shade500,
                  ));
                  return null;
                }

                if (value.isNotEmpty) {
                  searchUsers(capitalize(value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Container _buildSearchBody() {
    final Orientation orientation = MediaQuery.of(this.context).orientation;
    return Container(
      color: Colors.white,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Image(
              image: AssetImage(
                "assets/images/Search.png",
              ),
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.indigo,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w300,
                fontSize: 30.0,
              ),
            )
          ],
        ),
      ),
    );
  }

  buildUsersSearchResult() {
    return FutureBuilder<QuerySnapshot>(
        future: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData &&
              snapshot.data?.docs == null &&
              snapshot.connectionState == ConnectionState.none) {
            return circularProgressBar();
          }
          if (snapshot.hasError) {
            return SnackBar(
              content: Text(
                'Error ${snapshot.error}',
              ),
            );
          } else {
            List<UserResults> searchResultsList = [];

            snapshot.data?.docs.forEach((element) {
              Users users = Users.fromDocument(element);
              UserResults searchRes = UserResults(users);
              searchResultsList.add(searchRes);
            });
            return ListView(
              children: searchResultsList.toList(),
            );
          }
        });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: MediaQuery.of(context).size.height / 708,
      child: Scaffold(
        appBar: _buildSearchBar(),
        body: searchResultsFuture == null
            ? _buildSearchBody()
            : buildUsersSearchResult(),
      ),
    );
  }
}

class UserResults extends StatelessWidget {
  final Users user;

  UserResults(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.4),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              showProfile(context, profileId: user.id);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: GoogleFonts.philosopher(
                  color: Colors.black87,
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
          Divider(
            thickness: 1.0,
            height: 2.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
