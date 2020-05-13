import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:techchallenge/GPSPosition.dart';
import 'package:techchallenge/Location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  //attributes
  String feed = "locations";
  bool useKalman = false;
  List<bool> selections =  List.generate(2, (index) => true);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<MarkerId, Marker> markersKalman = <MarkerId, Marker>{};

  GeoPoint start;
  double distanceInKm = 0.0;
  GpsPosition obj = new GpsPosition();
  double initialLat = 0.0;
  double initialLong = 0.0;
  GpsPosition location;
  GoogleMapController mapController;

  //methods
  @override
  void initState() {
    super.initState();
    navigateToCurrentLocation();
    displayMarkers();
    displayMarkersKalman();
  }
  @override
  void dispose() {
    super.dispose();

  }
  _onMapCreated(GoogleMapController controller){
    setState(() {
      mapController = controller;
    });
  }
  ///Listener for Location Stream. Animates Camera to current position. Triggers upsert functions.
  void navigateToCurrentLocation() async {
    GpsPosition.instance.getCurrentPositionAsStreamm().listen((Position event) {

      Location loc = Location.transformPositionToLatLong(event);
      mapController.animateCamera(CameraUpdate.newLatLng(LatLng(
        loc.lat,
        loc.long,
      )));
      loc.createRecord(loc.lat, loc.long);
      loc.createRecordKalmans(loc.lat, loc.long,event.accuracy);
    });
  }
  ///Takes latlong of current GeoPoint and Starting Geo point to calculate geoDistance also triggers update distance function.
  void getDistanceFromFirstPointToLastPoint(double lastLat, double lastLong, GeoPoint pos) async{
    double dist = await Geolocator().distanceBetween(start.latitude, start.longitude, lastLat, lastLong)/1000;
    setState(() {
      distanceInKm = dist;
    });
  }
  /// Listens to broadcast stream form changes to location collection and maps new markers.
  void displayMarkers() {///parse in location collection name
    GpsPosition.instance.showMarkerAsStream("locations").listen(( event)async {
      for (var doc in event.documents) {
      GeoPoint pos = doc.data["geohash"]["geopoint"];
      MarkerId markerId= MarkerId(doc.data["geohash"]["geohash"]);
      Marker marker= Marker(position: LatLng(pos.latitude,pos.longitude),markerId: markerId,icon: BitmapDescriptor.defaultMarker);
      markers[markerId]= marker;
    }setState(() {
    });
    });
  }
  void displayMarkersKalman() {///parse in location collection name
    Stream<QuerySnapshot> stream = GpsPosition.instance.showMarkerAsStream("kalmanLocations");
    stream.listen(( event)async {
      for (var doc in event.documents) {
        GeoPoint pos = doc.data["geohash"]["geopoint"];
        MarkerId markerId= MarkerId(doc.data["geohash"]["geohash"]);
        Marker marker= Marker(position: LatLng(pos.latitude,pos.longitude),markerId: markerId,icon: BitmapDescriptor.defaultMarker);
        markersKalman[markerId]= marker;
      }setState(() {
      });
    });
  }
  ///deletes all recorded locations. Resets markers and distance.
  void refresh() async{
    await Firestore.instance.collection('locations').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
      ds.reference.delete();
      }});
    await Firestore.instance.collection('kalmanLocations').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      }});

    setState(() {
      markers.clear();
      markersKalman.clear();
    });
}

  Widget myToggleButton() {
    return Padding(
      padding: EdgeInsets.all(8),
      child:
      Material(
        child: Switch(
          value: useKalman,
          activeColor: Colors.green,
          onChanged: (bool b) {
             changeFeed(b);
             setState(() {

             });
          },
        ),
      ),
    );
  }
  ///toggle between feed and clear markers[]. (Set the name of collection to be referenced)
  void changeFeed(bool b) {
       if(b){
         feed = "kalmanLocations";
         useKalman = b;
       }else{
         feed = "locations";
         useKalman = b;
       }

  }

  //Widget Tree
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          GoogleMap(
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
              target: LatLng(initialLat,initialLong),
              zoom: 14),
          onMapCreated: _onMapCreated,
          markers:Set<Marker>.from( (useKalman)?markersKalman.values:markers.values)
        ),
          Align(alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  FloatingActionButton(onPressed: () {
                    refresh();
                  },
                    child: Icon(Icons.refresh),
                  ),
                  SizedBox(width: 20,),
                  Material(
                    child: Container(
                      width: 150,
                      height: 30,
                      color: Colors.white,
                      child: FutureBuilder<double>(
                        future: GpsPosition.instance.distanceQuery(feed),
                         builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                          if(!snapshot.hasData){
                            return  Center(child: CircularProgressIndicator());

                           }else{
                            return  Center(child: Text(snapshot.data.toString() + ' KM'));

                         }
                         }

                      //    child:
                    ),
                  ),
                  )],
              ),
            ),
          ),
          Align(
              alignment: Alignment.topLeft,
              child: myToggleButton()),

        ],
      ),
    );
  }


}
