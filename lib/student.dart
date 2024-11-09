import 'package:basic_app/admin.dart';
import 'package:basic_app/api/auth.dart';
import 'package:basic_app/login.dart';
import 'package:flutter/material.dart';
import 'package:basic_app/api/insertInfo.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
class Student extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Student Landing Page",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StudentInterface(),
    );
  }
}

class StudentInterface extends StatefulWidget {
  const StudentInterface({super.key});

  @override
  State<StudentInterface> createState() => _StudentInterfaceState();
}

class _StudentInterfaceState extends State<StudentInterface> with SingleTickerProviderStateMixin {
  Authentication auth = new Authentication();
  late TabController _tabController;
  bool isAdmin = false;

  var session = SessionManager(); 
  Insertion info = Insertion(); 
  final Map<String, String> Info = {
    "UserID" : "",
    "FacultyName": "",
    "Department": "",
    "Position": "",
    "PhoneNumber": "",
    "Address": ""
  };
  final Map<String, String> Credentials = {
    "UserID" : "",
    "FacultyName": "",
    "Department": "",
    "Position": "",
    "PhoneNumber": "",
    "Address": ""
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchData();
    CheckAdmin();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> CheckAdmin () async {
    bool _isAdmin = await SessionManager().get('AdminPrivi'); 
    setState(() { isAdmin = _isAdmin; });

    print(_isAdmin);
  }

  Future<void> fetchData() async {
    final userData = await info.getInfo();

    if (userData != null) { 
      setState(() {
        Info["FacultyName"] = userData.data()?["FacultyName"] ?? 'Unknown Faculty Name';
        Info["Department"] = userData.data()?["Department"] ?? 'Unknown Department';
        Info["Position"] = userData.data()?["Position"] ?? 'Unknown Position';
        Info["PhoneNumber"] = userData.data()?["PhoneNumber"] ?? 'Unknown Phone Number';
        Info["Address"] = userData.data()?["Address"] ?? 'Unknown Address';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController facultyNameController = TextEditingController(); 
    final TextEditingController departmentController = TextEditingController(); 
    final TextEditingController positionController = TextEditingController(); 
    final TextEditingController phoneNumberController = TextEditingController(); 
    final TextEditingController addressController = TextEditingController();
    
    void SubmitInfo(Map<String, String> Details) async {
      bool checkNull = false;
      Credentials["UserID"] = await session.get("SeshID");

      for (String value in Details.values) { 
        if (value == null || value.isEmpty) { 
          checkNull = true;
        } 
      }

      if(checkNull){
        showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Error: Empty Fields"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              "Make sure all fields are filled, Try Again!",
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Ok'),
                    ),
                  ),
                ],
              ),
            );
      } else {
        if(await info.addInfo(Credentials)){
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Information Sent"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              "Your Information has been sent to the Database, reload the pages to view your changes",
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Ok'),
                    ),
                  ),
                ],
              ),
            );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => {
                session.remove("SeshID"),
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()))
              },
              icon: Icon(Icons.arrow_circle_left_outlined),
            ),
            Text("Student Landing Page"),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'View Credentials'),
            Tab(text: 'Update Information'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: ClipRRect( 
                          borderRadius: BorderRadius.circular(20.0), 
                          child: Image.network( 'https://picsum.photos/200', 
                            fit: BoxFit.cover
                          ),
                        )
                      ),
                      Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text("Faculty Name"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  Info["FacultyName"] != null && Info["FacultyName"]!.isNotEmpty
                                    ? Info["FacultyName"]! 
                                    : "None"
                                ),
                              ),
                            ]
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text("Working Department"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  Info["Department"] != null && Info["Department"]!.isNotEmpty
                                    ? Info["Department"]! 
                                    : "None"
                                ),
                              ),
                            ]
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text("Current Position"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  Info["Position"] != null && Info["Position"]!.isNotEmpty
                                    ? Info["Position"]! 
                                    : "None"
                                ),
                              ),
                            ]
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text("Phone Number"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  Info["PhoneNumber"] != null && Info["PhoneNumber"]!.isNotEmpty
                                    ? Info["PhoneNumber"]! 
                                    : "None"
                                ),
                              ),
                            ]
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text("Address"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  Info["Address"] != null && Info["Address"]!.isNotEmpty
                                    ? Info["Address"]! 
                                    : "None"
                                ),
                                ),
                            ]
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Warning: Delete Account"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              "This action is irreversible, are you sure you wanted to delete your account?",
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if(await auth.deleteUser()){
                                              session.destroy();
                                              if(isAdmin){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => Admin()));
                                              } else  {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                                              }
                                            }
                                          },
                                          child: Text('Yes, I want to delete My Account'),
                                        )
                                      ]
                                    )
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Delete My Account"),
                              SizedBox(width: 10),
                              Icon(Icons.delete)
                          ]),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      if(isAdmin)
                        Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Admin()));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Back to List"),
                              SizedBox(width: 10),
                              Icon(Icons.list)
                          ]),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ),
              ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                    child: TextField(
                      controller: facultyNameController,
                      onChanged: (text) => {
                        Credentials["FacultyName"] = text
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.account_balance),
                        labelText: "Faculty Name",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                    child: TextField(
                      controller: departmentController,
                      onChanged: (text) => {
                        Credentials["Department"] = text
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.grade),
                        labelText: "Working Department",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                    child: TextField(
                      controller: positionController,
                      onChanged: (text) => {
                        Credentials["Position"] = text
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.account_box_rounded),
                        labelText: "Current Position",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                    child: TextField(
                      controller: phoneNumberController,
                      onChanged: (text) => {
                        Credentials["PhoneNumber"] = text
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.local_phone),
                        labelText: "Phone Number",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
                    child: TextField(
                      controller: addressController,
                      onChanged: (text) => {
                        Credentials["Address"] = text
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.location_pin),
                        labelText: "Address",
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        SubmitInfo(Credentials);
                      },
                      child: Text('Submit Information'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
