const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports
    .onCreateFollower =
    functions
        .firestore
        .document("/followers/{userId}/userFollowers/{followersId}")
        .onCreate(async (snapshot, context) => {
            console.log("Follower Created", snapshot.id);
            const userId = context.params.userId;
            const followersId = context.params.followersId;

            // Get the followed users post

            const followUserRef = admin
                .firestore()
                .collection('posts')
                .document(userId)
                .collection('userPosts')

            //Get following Users timeline

            const timelinePostRef = admin
                .firestore()
                .collection('timeline')
                .doc(followersId)
                .collection('timelinePosts');

            // Get followed users timeline ref

            const querySnapshot = await followUserRef.get();

            // add each users post to following users timeline

            querySnapshot.forEach(element => {
                if (element.exists) {

                    const postId = element.id;
                    const postData = doc.data();
                    timelinePostRef.doc(postId).set(postData);
                }
            });


        });

exports.onDeleteFollowers = functions.firestore
    .document("/followers/{userId}/userFollowers/{followersId}")
    .onDelete(async (snapshot, context) => {

        console.log("Follower Deleted", snapshot.id);

        const userId = context.params.userId;
        const followersId = context.params.followersId;

        const timelinePostRef = admin
            .firestore()
            .collection('timeline')
            .doc(followersId)
            .collection('timelinePosts')
            .where("ownerId", "==", userId);

        const querySnapshot = await timelinePostRef.get();
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }

        });

    });


