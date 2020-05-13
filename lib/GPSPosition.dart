import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class GpsPosition {
  static GpsPosition instance = GpsPosition();
  ///Stream User Position
  Stream<Position> getCurrentPositionAsStreamm() {
    return Geolocator().getPositionStream(
        LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 10));
  }
  ///Broadcasts locations/kalmanlocations collection
  Stream<QuerySnapshot> showMarkerAsStream(String collectionName) {
    CollectionReference reference = Firestore.instance.collection(collectionName);
    return reference.snapshots().asBroadcastStream();
  }
  ///Calculate distance traveled for desired feed.
  Future<double> distanceQuery(String collectionName)async{
    double distance = 0;
    await Firestore.instance.collection(collectionName).orderBy('timestamp',descending: true).getDocuments().then((docs)async {
      for(int i =0; i<docs.documents.length-1; i++){
        GeoPoint start = docs.documents[i].data["geohash"]["geopoint"];
        GeoPoint end = docs.documents[i+1].data["geohash"]["geopoint"];
        distance += (await Geolocator().distanceBetween(start.latitude, start.longitude, end.latitude, end.longitude))/1000;
      }
    });
    return distance;
  }
}
