import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Authentication {
  final CollectionReference staff = FirebaseFirestore.instance.collection("staff");
  final CollectionReference student = FirebaseFirestore.instance.collection("student");

  Future<bool> addStudent(String username, String password) async {
    Random random = Random();

    try {
     await student.add({
      'Username': username,
      'Userpass': password,
      'image' : 'https://picsum.photos/' + random.nextInt(200).toString()
    });

      return true;
    } catch (e) {
      print(e);
      return false;  
    }
  }

  Future<bool> addStaff(String username, String password) async {
    Random random = Random(200);

    try {
      await staff.add({
        'Username': username,
        'Userpass': password,
        'image' : 'https://picsum.photos/' + random.nextInt(200).toString()
      });
      return true;
    } catch (e) {
      print(e);
      return false;  
    }
  }

  Future<bool> getUser(String username, String userpass) async {
    if(double.tryParse(username) != null){
      if(double.tryParse(username)! >= 2018000000 && double.tryParse(username)! <= 2024999999){
        final querySnapshot = await FirebaseFirestore.instance
          .collection('student')
          .where('Username', isEqualTo: username)
          .get();

        if (querySnapshot.docs.isEmpty) {
          print('Username not found');
          return false;
        }

        if (querySnapshot.docs.first['Userpass'] == userpass) {
          print('Authentication successful');
          return true;
        } else {
          print('Incorrect password');
          return false;
        }
      } 
    } else {
       final querySnapshot = await FirebaseFirestore.instance
          .collection('staff')
          .where('Username', isEqualTo: username)
          .get();

        if (querySnapshot.docs.isEmpty) {
          print('Username not found');
          return false;
        }

        if (querySnapshot.docs.first['Userpass'] == userpass) {
          print('Authentication successful');
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

 
