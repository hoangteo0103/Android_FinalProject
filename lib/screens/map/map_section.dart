import 'dart:async';

import 'package:antap/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSection extends StatefulWidget {
  const MapSection({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MapSectionState();
  }
}

class _MapSectionState extends State<MapSection> {

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _hcmusPos = CameraPosition(
    target: LatLng(10.7605, 106.6818),
    zoom: 17,
  );
  Set<Marker> markers = {};

  @override
  void initState() {
    // TODO: implement initState
    setRestaurantMarker();
    setCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        markers: markers,
        zoomControlsEnabled: false,
        initialCameraPosition: _hcmusPos,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          controller.showMarkerInfoWindow(const MarkerId('currentLocation'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: setCurrentLocation,
        label: const Text("Now"),
        icon: const Icon(Icons.location_history),
      ),
    );
  }

  Future<void> setCurrentLocation() async {
    Position position = await _determinePosition();
    final c = await _controller.future;
    c.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 17)));

    if (markers.isNotEmpty &&
        markers.last.markerId == const MarkerId('currentLocation')) {
      markers.remove(markers.last);
    }

    markers.add(Marker(
      markerId: const MarkerId('currentLocation'),
      infoWindow: const InfoWindow(title: 'You'),
      position: LatLng(position.latitude, position.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      ),
    ));

    setState(() {});
  }

  void setRestaurantMarker() {
    List<Restaurant> restaurants = getRestaurantList();

    for (int i = 0; i < restaurants.length; i++) {
      markers.add(Marker(
          markerId: MarkerId(restaurants[i].id),
          infoWindow: InfoWindow(title: restaurants[i].name),
          position: restaurants[i].location,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          )));
    }
    setState(() {});
  }

  List<Restaurant> getRestaurantList() {
    List<Restaurant> restaurants = [];
    restaurants.add(Restaurant(
        'restaurant1', 'Name 1', const LatLng(10.764354, 106.682098)));
    restaurants.add(Restaurant(
        'restaurant2', 'Name 2', const LatLng(10.761160, 106.683385)));
    restaurants.add(Restaurant(
        'restaurant3', 'Name 3', const LatLng(10.761814, 106.681829)));
    return restaurants;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}
