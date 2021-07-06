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
        .document("/followers/{userId}/userFollowers/{followerId}")
        .onCreate(async (snapshot, context) => {
            console.log("Follower Created", snapshot.id);
            const userId = context.params.userId;
            const followerId = context.params.followerId;

            // Get the followed users post

            const followUserRef = admin
                .firestore()
                .collection('posts')
                .doc(userId)
                .collection('userPosts')

            //Get following Users timeline

            const timelinePostRef = admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts');

            // Get followed users timeline ref

            const querySnapshot = await followUserRef.get();

            // add each users post to following users timeline

            querySnapshot.forEach(element => {
                if (element.exists) {

                    const postId = element.id;
                    const postData = element.data();
                    timelinePostRef.doc(postId).set(postData);
                }
            });


        });

exports.onDeleteFollowers = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onDelete(async (snapshot, context) => {

        console.log("Follower Deleted", snapshot.id);

        const userId = context.params.userId;
        const followerId = context.params.followerId;

        const timelinePostRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')
            .where("ownerId", "==", userId);

        const querySnapshot = await timelinePostRef.get();
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }

        });

    });


// when post is posted , add the post to timeline of each who follow 

exports.onCreatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}').onCreate(async (snapshot, context) => {

        const postCreated = snapshot.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        // get all the followes of the uers who made the post

        const userFollowersRef = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');


        const querySnapshot = await userFollowersRef.get();

        // add new post to each followes timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .set(postCreated);

        });



    });
//updat the post of user

exports.onUpdatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onUpdate(async (change, context) => {
        const postUpdated = change.after.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        const userFollowersRef = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');
        const querySnapshot = await userFollowersRef.get();
        //update each post in followers timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.update(postUpdated);
                    }


                });

        });

    });

exports.onDeletePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onDelete(async (snapshot, context) => {
        const userId = context.params.userId;
        const postId = context.params.postId;
        console.log(snapshot.id);

        const userFollowersRef = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();
        //Delte each post in followers timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {

                        doc.ref.delete();
                    }


                });

        });

    });

