const firebase_tools = require('firebase-tools');
const functions = require('firebase-functions');

/**
 * Initiate a recursive delete of documents at a given path.
 * 
 * The calling user must be authenticated and have the custom "admin" attribute
 * set to true on the auth token.
 * 
 * This delete is NOT an atomic operation and it's possible
 * that it may fail after only deleting some documents.
 * 
 * @param {string} data.path the document or collection path to delete.
 */
exports.recursiveDelete = functions
  .runWith({
    timeoutSeconds: 540,
    memory: '2GB'
  })
  .https.onCall(async (data, context) => {
    // Only allow admin users to execute this function.
    if (!(context.auth)) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Permission denied'
      );
    }
    
    const path = data.path;
    console.log(
      `User ${context.auth.uid} has requested to delete path ${path}`
    );

    // Run a recursive delete on the given document or collection path.
    // The 'token' must be set in the functions config, and can be generated
    // at the command line by running 'firebase login:ci'.
    await firebase_tools.firestore
      .delete(`/polls/${path}`, {
        project: process.env.GCLOUD_PROJECT,
        recursive: true,
        yes: true,
        token: functions.config().fb.token
      });

    return {
      path: path 
    };
  });


var GeoFirestore = require('geofirestore').GeoFirestore;
var admin = require('firebase-admin');
const database = admin.firestore();
const geoFirestore = new GeoFirestore(database);
const pollsCollection = geoFirestore.collection('polls');
const usersCollection = geoFirestore.collection('users');

// First find if viewer's location is in Firestore
exports.getInFirestore = functions
.runWith({
  timeoutSeconds: 540,
  memory: '2GB'
})
.https.onCall(async (location, context) => {
  // Only allow admin users to execute this function.
  if (!(context.auth)) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Permission denied'
    );
  }

    location.lat = Number(location.lat.toFixed(1));
    location.lng = Number(location.lng.toFixed(1));
    const hash = Geokit.hash(location);
  
    usersCollection.doc(hash).get().then((snapshot) => {
      let data = snapshot.data();
      if (!data) {
        data = {
          count: 1,
          coordinates: new firebase.firestore.GeoPoint(location.lat, location.lng)
        };
        console.log('Provided key is not in Firestore, adding document: ', JSON.stringify(data));
        // createInFirestore(hash, data);
        pollsCollection.doc(hash).set(data).then(() => {
            console.log('Provided document has been added in Firestore');
          }, (error) => {
            console.log('Error: ' + error);
          });
      } else {
        data.count++;
        console.log('Provided key is in Firestore, updating document: ', JSON.stringify(data));
        // updateInFirestore(hash, data);
        pollsCollection.doc(hash).update(data).then(() => {
            console.log('Provided document has been updated in Firestore');
          }, (error) => {
            console.log('Error: ' + error);
          });
      }
    }, (error) => {
      console.log('Error: ' + error);
    });
  });
  
  // Create/set viewer's location in Firestore
  function createInFirestore(key, data) {
    pollsCollection.doc(key).set(data).then(() => {
      console.log('Provided document has been added in Firestore');
    }, (error) => {
      console.log('Error: ' + error);
    });
  }
  
  // Update viewer's location in Firestore
  function updateInFirestore(key, data) {
    pollsCollection.doc(key).update(data).then(() => {
      console.log('Provided document has been updated in Firestore');
    }, (error) => {
      console.log('Error: ' + error);
    });
  }
