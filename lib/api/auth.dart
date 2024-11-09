import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class Authentication {
  final CollectionReference staff = FirebaseFirestore.instance.collection("staff");
  final CollectionReference student = FirebaseFirestore.instance.collection("student");
  final CollectionReference info = FirebaseFirestore.instance.collection("information");
  var session = SessionManager(); 

  Future<bool> deleteUser() async {
    try {
      staff.doc((await session.get("SeshID"))).delete();
      student.doc((await session.get("SeshID"))).delete();
      info.doc((await session.get("SeshID"))).delete();
      return true;
    } catch(e) {
      print(e);
      return false;
    }
  }

  Future<bool> addStudent(String username, String password) async {
    Random random = Random();

    try {
     await student.add({
      'Username': username,
      'Userpass': password,
      'image' : 'https://picsum.photos/${random.nextInt(200)}'
    });

      return true;
    } catch (e) {
      print(e);
      return false;  
    }
  }

  Future<bool> addStaff(String username, String password) async {
    Random random = Random();

    try {
      await staff.add({
        'Username': username,
        'Userpass': password,
        'image' : 'https://picsum.photos/${random.nextInt(200)}'
      });
      return true;
    } catch (e) {
      print(e);
      return false;  
    }
  }

  Future<bool> getUser(String username, String userpass) async {
    if(double.tryParse(username) != null){
      if(double.tryParse(username)! >= 800000000 && double.tryParse(username)! <= 2024999999){
        final querySnapshot = await student
          .where('Username', isEqualTo: username)
          .get();

        if (querySnapshot.docs.isEmpty) {
          print('Username not found');
          return false;
        }

        if (querySnapshot.docs.first['Userpass'] == userpass) {
          print('Authentication successful');
          session.set("SeshID", querySnapshot.docs.first.id);
          return true;
        } else {
          print('Incorrect password');
          return false;
        }
      } 
    } else {
       final querySnapshot = await staff
          .where('Username', isEqualTo: username)
          .get();

        if (querySnapshot.docs.isEmpty) {
          print('Username not found');
          return false;
        }

        if (querySnapshot.docs.first['Userpass'] == userpass) {
          print('Authentication successful');
          session.set("SeshID", querySnapshot.docs.first.id);
          return true;
        } else {
          print('Incorrect password');
          return false;
        }
    }

    print('Error Fetching Data');
    return false;
  }
}
