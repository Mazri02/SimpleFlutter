import 'package:basic_app/login.dart';
import 'package:basic_app/staff.dart';
import 'package:basic_app/sensor.dart';
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
  List<String> _selectedValue = List.empty(growable: true);
  bool _isCheckboxSelected = false;
  var currentCollection;
  int _selectedIndex = 0;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Admin()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
        break;
    }
  }

  Future<void> _deleteDocument(String collection, String docId) async {
    await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
  }

  Future<void> _deleteMultipleDocuments(String collection, List<String> docIds) async {
    for (String docId in docIds) {
      await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
    }

    print(collection);
    print(docIds);
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

                if (collection == 'staff') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Staff()));
                } else if (collection == 'student') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Student()));
                }
              },
              child: ListTile(
                leading: Container(
                  width: 56,
                  height: 56,
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      data['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image, size: 50);
                      },
                    ),
                  ),
                ),
                title: Text(data['Username'] ?? 'No Name'),
                subtitle: Text(data['Userpass'] ?? 'No Position'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDocument(collection, documents[index].id),
                    ),
                    Checkbox(
                      value: _selectedValue.contains(documents[index].id),
                      onChanged: (bool? newValue) {
                        setState(() {
                          currentCollection = collection;
                          List<String> itemsToRemove = [];
                          if (newValue == true) {
                            _selectedValue.add(documents[index].id);
                          } else {
                            itemsToRemove.add(documents[index].id);
                          }
                          
                          // Remove the items after iteration
                          for (String item in itemsToRemove) {
                            _selectedValue.remove(item);
                          }

                          _isCheckboxSelected = _selectedValue.isNotEmpty;
                        });
                      },
                    )
                  ],
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
          _buildList('staff'),
          _buildList('student'),
        ],
      ),
      floatingActionButton: _isCheckboxSelected ? FloatingActionButton(
        onPressed: () {
          _deleteMultipleDocuments(currentCollection, _selectedValue); // Replace 'your_collection' with the actual collection name
        },
        child: Icon(Icons.delete),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
