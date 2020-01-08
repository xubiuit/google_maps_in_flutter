import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.extracted.google.json.dart' as locations;


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _googleMapControllerCompleter = Completer();
  static final CameraPosition _defaultPosition =
      CameraPosition(
        target: const LatLng(0, 0),
        zoom: 2,
  );
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  bool _inTheLake = false;
  final Map<String, Marker> _markers = {};
  MapType _currentMapType = MapType.normal;


  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onGoogleMarkerButtonPressed () async {
    final _random = new Random();
    final googleOffices = await locations.getGoogleOffices();
    var _random_office = googleOffices.offices[_random.nextInt(googleOffices.offices.length)];

    final GoogleMapController controller = await _googleMapControllerCompleter.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(_random_office.lat, _random_office.lng),
        zoom: 10,
      )
    ));
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _googleMapControllerCompleter.complete(controller);

    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();

      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.id),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address
          )
        );
        _markers[office.id] = marker;
      }
    });
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _googleMapControllerCompleter.future;
    if (!_inTheLake) {
      await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
      setState(() {
        _inTheLake = true;
      });
    } else {
      await controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
      setState(() {
        _inTheLake = false;
      });
    }
  }

  Future<void> _goToDefault() async {
    final GoogleMapController controller = await _googleMapControllerCompleter.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_defaultPosition));
      setState(() {
        _inTheLake = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Maps Sample App'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: (GoogleMapController controller) =>
                _onMapCreated(controller),
            initialCameraPosition: _defaultPosition,
            markers: _markers.values.toSet(),
            mapType: _currentMapType,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () => _onMapTypeButtonPressed(),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.map, size: 36.0),
                  ),
                  SizedBox(height: 8.0),
                  FloatingActionButton(
                    onPressed: () => _onGoogleMarkerButtonPressed(),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.directions_run, size: 36.0),
                  ),
                  SizedBox(height: 8.0),
                  FloatingActionButton(
                    onPressed: () => _goToTheLake(),
                    child: Icon(Icons.directions_boat),
                    // label: !_inTheLake ? Text('To the lake!') : Text('Go somewhere else!'),
                    // icon: Icon(Icons.directions_boat),
                  ),
                  SizedBox(height: 8.0),
                  FloatingActionButton(
                    onPressed: () => _goToDefault(),
                    child: Icon(Icons.home),
                    backgroundColor: Colors.orange,
                  ),
                ],
              )
            ),
          ),
        ],
      ),
    ));
  }
}
