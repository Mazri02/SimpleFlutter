import 'package:flutter/material.dart';
import './login.dart';
import 'package:basic_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure Firebase is only initialized once
  await initializeFirebase();

  final cameras = await availableCameras(); 
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

Future<void> initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(name: 'LabActivity3',options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAppCheck.instance.activate();
  }
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({Key? key, required this.camera}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page Labs',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: MyPage(),
    );
  }
}
