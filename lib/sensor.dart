import 'package:basic_app/admin.dart';
import 'package:basic_app/sensor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:basic_app/login.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:io';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Admin Landing Page",
      theme: ThemeData(primarySwatch: Colors.green),
      home: AdminInterface(),
    );
  }
}

class AdminInterface extends StatefulWidget {
  const AdminInterface({super.key});

  @override
  State<AdminInterface> createState() => _AdminInterfaceState();
}

class _AdminInterfaceState extends State<AdminInterface> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var session = SessionManager();
  int _selectedIndex = 1;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Position? _currentPosition;
  bool _showAccelerometerData = false;
  String _sensorType = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Admin()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
        break;
    }
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = selectedImage;
      _currentPosition = null; // Reset location data when selecting an image
      _showAccelerometerData = false; // Reset accelerometer data when selecting an image
      _sensorType = 'Camera';
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    } 

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _image = null; // Reset image data when selecting location
      _showAccelerometerData = false; // Reset accelerometer data when selecting location
      _sensorType = 'Geolocator';
    });
  }

  void _toggleAccelerometer() {
    setState(() {
      _showAccelerometerData = !_showAccelerometerData;
      _image = null; // Reset image data when toggling accelerometer
      _currentPosition = null; // Reset location data when toggling accelerometer
      _sensorType = _showAccelerometerData ? 'Accelerometer' : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => {
                session.destroy(),
                session.remove("AdminPrivi"),
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()))
              },
              icon: Icon(Icons.arrow_circle_left_outlined),
            ),
            Text("Admin Landing Page"),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (){}, 
                  child: Icon(Icons.mic)
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _getCurrentLocation, 
                  child: Icon(Icons.map)
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Icon(Icons.camera)
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _toggleAccelerometer, 
                  child: Icon(Icons.compass_calibration)
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_sensorType.isNotEmpty) 
              Column(
                children: [
                  Text('$_sensorType', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 20),
                ],
              ),
            if (_image != null)
              Image.file(File(_image!.path)), // Display the selected image
            if (_currentPosition != null)
              Text('Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}'),
            if (_showAccelerometerData)
              StreamBuilder<AccelerometerEvent>(
                stream: accelerometerEvents,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("Waiting for accelerometer data...");
                  }
                  return Column(
                    children: [
                      Text("X: ${snapshot.data?.x.toStringAsFixed(2)}"),
                      Text("Y: ${snapshot.data?.y.toStringAsFixed(2)}"),
                      Text("Z: ${snapshot.data?.z.toStringAsFixed(2)}"),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "View Data"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: "Test Sensors"
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple[800], 
        onTap: (index) => {
          _onItemTapped(index)
        },
      ),
    );
  }
}
