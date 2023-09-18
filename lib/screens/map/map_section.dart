import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:antap/models/restaurant.dart';
import 'package:antap/screens/map/restaurant_detail/restaurant_detail_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  // HCMUS
  final LatLng _initialPosition = const LatLng(10.7628, 106.6825);
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _setRestaurantMarker();
    _setCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        markers: markers,
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 17,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _setCurrentLocation,
        label: const Text("Now"),
        icon: const Icon(Icons.location_history),
      ),
    );
  }

  Future<void> _setCurrentLocation() async {
    Position position = await _determinePosition();
    final c = await _controller.future;

    BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/images/icons/current_location.png');
    if (mounted) {
      setState(() {
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
          icon: markerIcon,
        ));
      });
    }
  }

  void showWidget(Restaurant restaurant) {
    Navigator.pushNamed(context, RestaurantDetailsScreen.id,
        arguments: ScreenArguments(
            imagePath: restaurant.imageUrl,
            restaurantName: restaurant.name,
            restaurantAddress: "HCMUS",
            category: 'Dining',
            distance: "5km",
            rating: "4"));
    // setState(() {
    //   showDialog(
    //     context: context,
    //     builder: (builder) => XenPopupCard(
    //       appBar: appBar,
    //       gutter: gutter,
    //       body: NewPostScreen(),
    //     ),
    //   );
    // });
  }

  Future<void> _setRestaurantMarker() async {
    List<Restaurant> restaurants = await getRestaurantList();

    for (int i = 0; i < restaurants.length; i++) {
      // final Uint8List resizedImageMarker =
      //     await loadNetWorkImageDataByte(restaurants[i].imageUrl, 110, 110);
      markers.add(Marker(
        markerId: MarkerId(restaurants[i].id),
        infoWindow: InfoWindow(title: restaurants[i].name),
        position: restaurants[i].location,
        onTap: () {
          showWidget(restaurants[i]);
        },
        icon: await NetworkImageMarker(restaurants[i].imageUrl,
            addBorder: true,
            size: 130,
            title: restaurants[i].name,
            borderColor: ui.Color.fromARGB(255, 1, 255, 86),
            borderSize: 15),
      ));
    }
    setState(() {});
  }

  Future<BitmapDescriptor> NetworkImageMarker(String path,
      {int size = 150,
      bool addBorder = false,
      Color borderColor = Colors.white,
      double borderSize = 10,
      String? title,
      Color titleColor = Colors.white,
      Color titleBackgroundColor = Colors.black}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final double radius = size / 2;

    //make canvas clip path to prevent image drawing over the circle
    final Path clipPath = Path();
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(100)));
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        Radius.circular(100)));
    canvas.clipPath(clipPath);

    //paintImage
    final Uint8List imageUint8List =
        await loadNetWorkImageDataByte(path, size, size);
    final ui.Codec codec = await ui.instantiateImageCodec(imageUint8List);
    final ui.FrameInfo imageFI = await codec.getNextFrame();
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: imageFI.image);

    if (addBorder) {
      //draw Border
      paint..color = borderColor;
      paint..style = PaintingStyle.stroke;
      paint..strokeWidth = borderSize;
      canvas.drawCircle(Offset(radius, radius), radius, paint);
    }

    if (title != null) {
      if (title.length > 9) {
        title = title.substring(0, 9);
      }
      //draw Title background
      paint..color = titleBackgroundColor;
      paint..style = PaintingStyle.fill;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
              Radius.circular(100)),
          paint);

      //draw Title
      textPainter.text = TextSpan(
          text: title,
          style: TextStyle(
            fontSize: radius / 2.5,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ));
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(radius - textPainter.width / 2,
              size * 9.5 / 10 - textPainter.height / 2));
    }

    //convert canvas as PNG bytes
    final _image = await pictureRecorder
        .endRecording()
        .toImage(size, (size * 1.1).toInt());
    final data = await _image.toByteData(format: ui.ImageByteFormat.png);

    //convert PNG bytes as BitmapDescriptor
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<Uint8List> loadNetWorkImageDataByte(String path, int h, int w) async {
    Uint8List? image = await loadNetworkImage(path);

    final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
      image!.buffer.asUint8List(),
      targetHeight: h,
      targetWidth: w,
    );

    final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final ByteData? byteData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedImageMarker = byteData!.buffer.asUint8List();
    return resizedImageMarker;
  }

  Future<Uint8List?> loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    NetworkImage image = NetworkImage(path);
    image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info)));

    final imageInfo = await completer.future;

    final byteData =
        await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<List<Restaurant>> getRestaurantList() async {
    List<Restaurant> restaurants = [];
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('restaurants').get();
    querySnapshot.docs.forEach((doc) {
      Restaurant restaurant = Restaurant.fromFirestore(doc, null);
      restaurants.add(restaurant);
    });
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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}
