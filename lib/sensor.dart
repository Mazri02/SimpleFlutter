import 'package:basic_app/admin.dart';
import 'package:basic_app/sensor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:basic_app/login.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
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
  FlutterSoundRecorder? _soundRecorder;
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  double _audioLevel = 0.0;
  double _accelerometerValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _soundRecorder?.closeRecorder();
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
      _currentPosition = null;
      _showAccelerometerData = false;
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
      _image = null;
      _showAccelerometerData = false;
      _sensorType = 'Geolocator';
    });
  }

  void _toggleAccelerometer() {
    setState(() {
      _showAccelerometerData = !_showAccelerometerData;
      _image = null;
      _currentPosition = null;
      _sensorType = _showAccelerometerData ? 'Accelerometer' : '';
    });
    if (_showAccelerometerData) {
      accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          _accelerometerValue = event.x.abs() + event.y.abs() + event.z.abs();
        });
      });
    }
  }

Future<void> _initRecorder() async {
    _soundRecorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _soundRecorder!.openRecorder();
    _isRecorderInitialized = true;
  }

Future<void> _toggleRecording() async {
  if (!_isRecorderInitialized) return;

  if (_soundRecorder!.isStopped) {
    await _soundRecorder!.startRecorder(
      toFile: 'temp_recording.aac',
      codec: Codec.aacADTS,
      audioSource: AudioSource.microphone,
    );
    _soundRecorder!.setSubscriptionDuration(Duration(milliseconds: 100));
    _soundRecorder!.onProgress!.listen((event) {
      setState(() {
        _audioLevel = event.decibels ?? 0.0;
      });
    });
    setState(() {
      _isRecording = true;
    });
  } else {
    await _soundRecorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }
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
                  onPressed: _toggleRecording,
                  child: Icon(_isRecording ? Icons.mic_off : Icons.mic),
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
            if (_isRecording)
              Column(
                children: [
                  Text('Audio Level: ${_audioLevel.toStringAsFixed(2)} dB'),
                  SizedBox(height: 20),
                  SfLinearGauge(
                    minimum: 0,
                    maximum: 120,
                    ranges: [
                      LinearGaugeRange(startValue: 0, endValue: 60, color: Colors.green),
                      LinearGaugeRange(startValue: 60, endValue: 90, color: Colors.orange),
                      LinearGaugeRange(startValue: 90, endValue: 120, color: Colors.red),
                    ],
                    markerPointers: [
                      LinearShapePointer(value: _audioLevel),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (_currentPosition != null)
              Text('Location: Lat: ${_currentPosition!.latitude}, Lon: ${_currentPosition!.longitude}'),
            SizedBox(height: 20),
            if (_showAccelerometerData)
              Column(
                children: [
                  StreamBuilder<AccelerometerEvent>(
                    stream: accelerometerEvents,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text('Accelerometer: x=${snapshot.data!.x}, y=${snapshot.data!.y}, z=${snapshot.data!.z}');
                      } else {
                        return Text('Waiting for accelerometer data...');
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 30,
                        pointers: <GaugePointer>[
                          NeedlePointer(value: _accelerometerValue),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Container(
                              child: Text(
                                '$_accelerometerValue',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            angle: 90,
                            positionFactor: 0.5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (_image != null)
              Center(child: Image.file(File(_image!.path))),
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
        onTap: _onItemTapped,
      ),
    );
  }
}
