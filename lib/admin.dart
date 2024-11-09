import 'package:basic_app/login.dart';
import 'package:basic_app/staff.dart';
import 'package:basic_app/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class Admin extends StatelessWidget {
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteDocument(String collection, String docId) async {
    await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
  }

  Widget _buildList(String collection) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection(collection).snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      final documents = snapshot.data!.docs;
      return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final data = documents[index].data() as Map<String, dynamic>;
          return GestureDetector(
            onTap: () {
              session.set("AdminPrivi", "true");
              session.set("SeshID", documents[index].id);
              print("Clicked item from $collection collection");
              // Use the collection name to determine the next action
              if (collection == 'staff') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Staff()));
              } else if (collection == 'student') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Student()));
              }
            },
            child: ListTile(
              leading: Container(
                width: 56, // Slightly larger than the image for border
                height: 56,
                padding: EdgeInsets.all(3), // Space for the border
                decoration: BoxDecoration(
                  color: Colors.white, // Border color (can be any color)
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                    data['image'], // Replace with your direct image URL
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 50); // Fallback if image fails
                    },
                  ),
                ),
              ),
              title: Text(data['Username'] ?? 'No Name'),
              subtitle: Text(data['Userpass'] ?? 'No Position'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteDocument(collection, documents[index].id),
              ),
            ),
          );
        },
      );
    },
  );
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Staff'),
            Tab(text: 'Student'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList('staff'),  // Assumes collection name is 'staff' in Firestore
          _buildList('student'), // Assumes collection name is 'student' in Firestore
        ],
      ),
    );
  }
}