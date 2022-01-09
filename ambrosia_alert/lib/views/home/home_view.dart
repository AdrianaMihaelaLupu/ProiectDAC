import 'dart:async';

import 'package:ambrosia_alert/classes/ReportedLocation.dart';
import 'package:ambrosia_alert/views/login/login_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../blocs/geolocation/geolocation_bloc.dart';
import '../../widgets/location_search_box.dart';

class MapHomePage extends StatefulWidget {
  @override
  State<MapHomePage> createState() => MapHomePageState();
}

class MapHomePageState extends State<MapHomePage> {
  final TextEditingController _searchLocationController =
      new TextEditingController();

  Completer<GoogleMapController> _controller = Completer();

  bool addMode = false;

  Set<Marker> _markers = Set<Marker>();
  List<Polygon> _polygons = <Polygon>[];
  List<LatLng> _customPolygonsLatLngsTemp = <LatLng>[];
  int _markerIdCounter = 1;

  @override
  void initState() {
    super.initState();

    setState(() {
      addMode = false;
    });
  }

  void _setMarker(LatLng point) {
    final String markerIdVal = "custom_marker_$_markerIdCounter";
    _markerIdCounter++;

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerIdVal),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    });
  }

  Polygon _createCustomPolygon(
      String polygonId, List<LatLng> customPoints, Color color,
      {int nrOfReports = 1}) {
    return new Polygon(
      polygonId: PolygonId(polygonId),
      fillColor: color.withOpacity(0.15),
      strokeColor: color,
      strokeWidth: 2,
      points: customPoints,
      visible: true,
      consumeTapEvents: true,
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
              content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Raportat de: $nrOfReports persoane"),
              MaterialButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    new SnackBar(
                      content: Text("Test confirmare locatie raportata"),
                    ),
                  );
                },
                color: Colors.green,
                elevation: 2.0,
                child: Text(
                  "Confirma",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )),
        );
      },
    );
  }

  final reportedLocationsRef = FirebaseFirestore.instance
      .collection('reported_locations')
      .withConverter<ReportedLocation>(
        fromFirestore: (snapshots, _) =>
            ReportedLocation.fromJson(snapshots.data()!),
        toFirestore: (reportedLocation, _) => reportedLocation.toJson(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<ReportedLocation>>(
        stream: reportedLocationsRef.snapshots(),
        builder:
            (context, AsyncSnapshot<QuerySnapshot<ReportedLocation>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          List<Polygon> _dbPolygons = <Polygon>[];
          final data = snapshot.requireData;
          for (int i = 0; i < data.size; i++) {
            ReportedLocation _reportedLocation = data.docs[i].data();
            List<LatLng> _points = [];
            for (int j = 0; j < _reportedLocation.points.length; j++) {
              _points.add(
                LatLng(
                  _reportedLocation.points[j].latitude,
                  _reportedLocation.points[j].longitude,
                ),
              );
            }

            _dbPolygons.add(
              _createCustomPolygon(
                "database_polygon_$i",
                _points,
                _reportedLocation.confirmedByAuthorities
                    ? Colors.red
                    : Colors.orange,
                nrOfReports: _reportedLocation.nrOfConfirmations,
              ),
            );
          }

          initializeDatabasePolygons(_dbPolygons);

          return Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: BlocBuilder<GeolocationBloc, GeolocationState>(
                  builder: (context, state) {
                    if (state is GeolocationLoaded) {
                      return GoogleMap(
                        mapToolbarEnabled: false,
                        minMaxZoomPreference: MinMaxZoomPreference(15, 21),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            state.position.latitude,
                            state.position.longitude,
                          ),
                          zoom: 19,
                        ),
                        markers: _markers,
                        polygons: Set<Polygon>.of(_polygons),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        onTap: (point) {
                          if (addMode) {
                            setState(() {
                              _setMarker(point);
                              _customPolygonsLatLngsTemp.add(point);
                            });
                          } else {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              new SnackBar(
                                content: Text("Actiunea nu este permisa..."),
                              ),
                            );
                          }
                        },
                      );
                    } else if (state is GeolocationLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.green[500],
                        ),
                      );
                    } else {
                      return Center(
                        child: Text('Ceva nu a functionat....'),
                      );
                    }
                  },
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: Container(
                  height: 100,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/plant.png',
                        height: 50,
                      ),
                      Expanded(
                        child: LocationSearchBox(
                          searchLocationController: _searchLocationController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        child: Row(
          children: [
            !addMode
                ? ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser?.uid == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                      } else {
                        setState(() {
                          addMode = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3.0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      primary: Colors.orange[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Raporteaza",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 6.0,
                        ),
                        Icon(
                          Icons.add_location_alt_outlined,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _markers.clear();
                          _polygons.add(
                            _createCustomPolygon(
                              "custom_polygon",
                              _customPolygonsLatLngsTemp,
                              Colors.orange,
                            ),
                          );
                          sendPolygonToFirebase();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 3.0,
                          primary: Colors.green[600],
                          shape: CircleBorder(),
                          padding: const EdgeInsets.all(14),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }

  void sendPolygonToFirebase() {
    List<GeoPoint> _points = [];
    for (int i = 0; i < _customPolygonsLatLngsTemp.length; i++) {
      _points.add(
        GeoPoint(
          _customPolygonsLatLngsTemp[i].latitude,
          _customPolygonsLatLngsTemp[i].longitude,
        ),
      );
    }
    ReportedLocation _reportedLocation = new ReportedLocation(
      user_uid: FirebaseAuth.instance.currentUser!.uid,
      nrOfConfirmations: 1,
      confirmedByAuthorities: false,
      points: _points,
    );
    FirebaseFirestore.instance
        .collection('reported_locations')
        .add(_reportedLocation.toJson());

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: Text("Locatia a fost raportata!"),
    ));

    setState(() {
      addMode = false;
      _customPolygonsLatLngsTemp = [];
    });
  }

  void initializeDatabasePolygons(dbPolygons) async {
    setState(() {
      _polygons = dbPolygons;
    });
  }
}
