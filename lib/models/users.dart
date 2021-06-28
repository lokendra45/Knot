import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  Users({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.bio,
  });

  factory Users.fromDocument(dynamic documentSnapshot) => Users(
        id: documentSnapshot.id,
        username: documentSnapshot['username'],
        email: documentSnapshot['email'],
        photoUrl: documentSnapshot['photoUrl'],
        displayName: documentSnapshot['displayName'],
        bio: documentSnapshot['bio'],
      );
}
