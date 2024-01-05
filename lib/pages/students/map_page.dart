import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:location/location.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_up/model/error.dart';
import 'package:sign_in_up/model/response.dart';
import 'package:sign_in_up/util/userApi.dart';

class MapPage extends StatefulWidget{
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver{
  final MAIN_COLOR = Color.fromRGBO(224, 135, 255, 1.0);
  Location _locationController = Location();
  LatLng? myLocation = null;
  List<LatLng> walkRoute = <LatLng>[];
  Set<Polyline> _polylines = <Polyline>{};
  bool _isWorkout = false;
  bool _startPressed = false;
  bool _isKillo = false;
  var _totalDistance = 0.0;
  Timer? _timer;
  var _time = 0;
  var _lastTime = 0;
  FlutterSecureStorage storage = FlutterSecureStorage();



  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance!.removeObserver(this);
    _timer?.cancel();
    print('disposed');
    super.dispose();

  }


  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    getLocationUpdated();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
      case AppLifecycleState.hidden:
        print("app in hidden");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    int sec = _time % 60;
    int min = (_time / 60).toInt() % 60;
    int hour = ((_time / 60).toInt() / 60).toInt();

    return Scaffold(
      body: !_isWorkout? Center(
        child: button(
          width: deviceWidth * 6 / 10,
          height: deviceHeight / 16,
          textButton: 'START',
          pressed: (){
            setState((){
              _startPressed = true;
              _start();
            });
          },
        ),
      ) :
      myLocation == null ? const Center(child: Text("loading..."),) :
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Column(
              children: [
                Text('${doubleToDistanceString(_totalDistance)}',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Text(_isKillo ? 'Distance (Km)' : 'Distance (m)',
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0, bottom: 25),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('${timeToString(hour, min, sec)}',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text('Duration',
                        style: TextStyle(
                          fontSize: 18
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${_time != 0 ? (_totalDistance * 3.6 / _time * 100).round() / 100 : 0}',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text('Spped(km/h)',
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: deviceHeight / 1.8,
            child: GoogleMap(
              myLocationButtonEnabled: true,
              initialCameraPosition: CameraPosition(target: myLocation!, zoom: 13),
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              polylines: _polylines,
              markers: {
                Marker(
                    markerId: MarkerId('_current_location'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: myLocation!
                )
              },
            ),
          ),
          _isWorkout && _startPressed? Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: button(
              width: deviceWidth / 1.2,
              height: 40,
              textButton: 'PAUSE',
              pressed: (){
                setState(() {
                  _pause();
                  _startPressed = false;
                });
              }
            ),
          ): Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                button(
                    width: deviceWidth / 2.4,
                    height: 40,
                    textButton: 'RESUME',
                    pressed: (){
                        setState(() {
                          _start();
                          _startPressed = true;
                        });
                    }
                ),
                button(
                    width: deviceWidth / 2.4,
                    height: 40,
                    textButton: 'FINISH',
                    pressed: (){
                      _workoutDone();
                    }
                ),
              ],
            ),
          )
        ]
      ),
    );
  }


  initPolyline() async {
    if (walkRoute.isEmpty) return;
    if (walkRoute.length < 2) return;
    setState(() {
      _polylines.add(Polyline(
        geodesic: true,
        points: walkRoute,
        polylineId: PolylineId('walk route'),
        width: 5,
        color: Colors.deepPurpleAccent
      ));
    });
  }

  Future<void> getLocationUpdated() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if(_serviceEnabled){
      _serviceEnabled = await _locationController.requestService();
    }else{
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await _locationController.requestPermission();
      if(_permissionGranted != PermissionStatus.granted){
        return;
      }
    }

    _locationController.onLocationChanged.listen((currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(() {
            var latLng = LatLng(
                currentLocation.latitude!, currentLocation.longitude!);
            if (walkRoute.isNotEmpty) {
              var lastLoc = walkRoute.last;
              var distance = latlng.Distance();
              _totalDistance += distance.as(latlng.LengthUnit.Meter,
                    latlng.LatLng(lastLoc.latitude, lastLoc.longitude),
                    latlng.LatLng(latLng.latitude, latLng.longitude));
              _lastTime = _time;
            }
            myLocation = latLng;
            walkRoute.add(latLng);
          });

        }
    });
  }

  void _workoutDone() async {
    String? session = await storage.read(key: "session");
    List<String> split = session!.split(',,');
    var response = await http.post(Uri.parse(baseUrl + "/route"),
      headers: {
        'point_runner_token' : split[2],
      },
      body: {
        'duration' : _time.toString(),
        'route_length' : _totalDistance.toString()
      }
    );
    var statusCode = response.statusCode;
    if(statusCode != 200){
      var body = json.decode(utf8.decode(response.bodyBytes));
      ErrorMessage error = ErrorMessage.fromJson(body);
      _showErrorSnackBar(error);
    }else{
      reSetting();
    }
  }

  void _showErrorSnackBar(ErrorMessage error){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message),
          duration: const Duration(seconds: 3),
        )
    );
  }

  Widget button({VoidCallback? pressed, required double width, required double height, required String textButton}){
    return OutlinedButton(
      onPressed: pressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: MAIN_COLOR,
        fixedSize: Size(width, height),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
      ),
      child: Text('$textButton',
        style: TextStyle(
            fontSize: 25,
            color: Colors.white
        ),
      ),
    );
  }


  String doubleToDistanceString(double distance){
    if(distance < 1000){
      setState(() {
        _isKillo = false;
      });
      return '$distance';
    }
    setState(() {
      _isKillo = true;
    });
    distance = distance / 1000;
    String intPart = distance.toString().split(".").first.padLeft(2, '0');
    String decimal = ((distance * 100).round() / 100).toStringAsFixed(2).split(".").last;
    return '$intPart.$decimal';
  }

  void _start(){
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _time++;
        _isWorkout = true;
      });
    });
  }

  void _pause(){
    _timer?.cancel();
  }

  String timeToString(int h, int m, int s){
    if(h != 0)
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    else
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void reSetting(){
    setState(() {
      _time = 0;
      _lastTime = 0;
      walkRoute = <LatLng>[];
      _polylines = <Polyline>{};
      _isWorkout = false;
      _startPressed = false;
      _isKillo = false;
      _totalDistance = 0.0;
    });
  }
}
