import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:techchallenge/kalman_filter.dart';
class Location {
  final double long;
  final double lat;
  final double distanceFromOrigin;

  CollectionReference databaseReference = Firestore.instance.collection(
      "locations");
  CollectionReference databaseReferenceKalman = Firestore.instance.collection(
      "kalmanLocations");
  Location({this.long, this.lat, this.distanceFromOrigin});
  ///Deconstruct GeoPosition
  static Location transformPositionToLatLong(Position pos) {
    return Location(
      lat: pos.latitude,
      long: pos.longitude,
    );
  }
  ///upsert firebase document/ set data for unfiltered feed.
  void createRecord(double lat, double long) async {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint myLocation = geo.point(latitude: lat, longitude: long);
    await databaseReference.document()
        .setData({
      'geohash': myLocation.data,
      'timestamp': FieldValue.serverTimestamp()
    });
  }
  ///upsert firebase document/ set data for kalman filter feed.
  void createRecordKalmans(double lat, double long,double accuracy) async {
    Geoflutterfire geo = Geoflutterfire();
    KalmanLatLong.instance.process(lat, long, accuracy, DateTime.now().millisecondsSinceEpoch.toDouble());
    GeoFirePoint myLocation = geo.point(latitude: KalmanLatLong.instance.getLat(), longitude: KalmanLatLong.instance.getLng());
    await databaseReferenceKalman.document()
        .setData({
      'geohash': myLocation.data,
      'timestamp': FieldValue.serverTimestamp()
    });
  }
}