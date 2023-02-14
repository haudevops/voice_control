import 'dart:async';

import 'package:driver_vm/routes/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;

class DriverMapPage extends StatefulWidget {
  const DriverMapPage({Key? key, required this.data}) : super(key: key);
  final ScreenArguments data;
  static const routeName = '/DriverMapPage';

  @override
  State<DriverMapPage> createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  late Completer<GoogleMapController> _controller = Completer();

  late LatLng sourceLocation;
  LatLng? destination;

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;

  String? nameDriver;
  String? currentPosition;
  String? imgUser;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    setCustomMakerIcon();
    // getPolyPoints();
    sourceLocation = LatLng(widget.data.arg1, widget.data.arg2);
    destination = const LatLng(11.3557733, 107.0259363);
    nameDriver = widget.data.arg3;
    currentPosition = widget.data.arg4;
    imgUser = widget.data.arg5;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
      });
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLocation) {
      currentLocation = newLocation;
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: LatLng(sourceLocation.latitude, sourceLocation.longitude),
          ),
        ),
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyDW4U-Pba7etX8BhXv2Mrrv6XQBcTrKU7w',
      PointLatLng(10.7994064, 106.7116703),
      PointLatLng(11.3557733, 107.0259363),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    }
  }

  void setCustomMakerIcon() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/img/truck_icon.png', 150);
    currentIcon = BitmapDescriptor.fromBytes(markerIcon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Tìm đường',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Stack(
          children: [
            currentLocation == null
                ? Container(
                    color: const Color(0xFF222222),
                    child: Center(
                      child: Text(
                        'Đang tải',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : GoogleMap(
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                        // target: LatLng(currentLocation!.latitude!,
                        //     currentLocation!.longitude!),
                        target: LatLng(sourceLocation!.latitude,
                            sourceLocation!.longitude),
                        zoom: 13),
                    polylines: {
                      Polyline(
                          polylineId: const PolylineId('route'),
                          points: polylineCoordinates,
                          color: Colors.black,
                          width: 5),
                    },
                    markers: {
                      Marker(
                          markerId: MarkerId('source'),
                          icon: currentIcon,
                          position: sourceLocation ?? const LatLng(0.0, 0.0)),
                      // Marker(
                      //     markerId: MarkerId('current'),
                      //     icon: currentIcon,
                      //     position: LatLng(currentLocation!.latitude!,
                      //         currentLocation!.longitude!)),
                      // Marker(
                      //     markerId: MarkerId('destination'),
                      //     position: destination ?? const LatLng(0.0, 0.0)),
                    },
                    onMapCreated: (mapController) {
                      _controller.complete(mapController);
                    },
                  ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _locationWidget(),
            )
          ],
        ));
  }

  Widget _locationWidget() {
    return Container(
      padding: EdgeInsets.all(14),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imgUser ?? '',
                  fit: BoxFit.cover,
                )),
          ),
          SizedBox(width: 30),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Tên tài xế:',
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(width: 8),
                Text(nameDriver ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
              ]),
              SizedBox(height: 16),
              Row(children: [
                Text('Vị trí:',
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(width: 8),
                Text(currentPosition ?? '',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
