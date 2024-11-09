import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class Insertion {
  final CollectionReference info = FirebaseFirestore.instance.collection("information");
  var session = SessionManager(); 

  Future<bool> addInfo(Map<String, String> details) async {
    final String userId = await session.get("SeshID");
    final querySnapshot = await info.where('UserID', isEqualTo: userId).get();

    try {
      if (querySnapshot.docs.isEmpty) {
        // Add new user info
        await info.add(details);
      } else {
        // Update existing user info
        final docId = querySnapshot.docs.first.id;
        await info.doc(docId).update(details);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getInfo() async {
    final querySnapshot = await FirebaseFirestore.instance
    .collection('information')
    .where('UserID', isEqualTo: await session.get("SeshID"))
    .get();

    if (querySnapshot.docs.isEmpty) {
      print('Username not found');
      return null;
    } 
    
    return querySnapshot.docs.first;
  }
}

 
