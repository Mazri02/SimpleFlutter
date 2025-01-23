import 'package:basic_app/student.dart';
import 'package:basic_app/admin.dart';
import 'package:basic_app/staff.dart';
import 'package:basic_app/api/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:basic_app/api/auth.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext Context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(20), child: InputLogin())
          ]),
    );
  }
}

class InputLogin extends StatefulWidget {
  const InputLogin({super.key});

  @override
  State<InputLogin> createState() => _InputLoginState();
}

class _InputLoginState extends State<InputLogin> {
  bool showPass = true;
  String text = "", pass = "";
  final Controller = TextEditingController();
  Authentication auth = Authentication();
  late Future dialog;
  var session = SessionManager();
  final _auth = FirebaseAuth.instance;

  Future<void> _login(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("Logged in as: ${userCredential.user?.displayName}");

      // Navigate to the Student page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Student()),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${e.toString()}"),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showStatusRegister() async {
    if (double.tryParse(text) != null) {
      if (double.tryParse(text)! >= 2018000000 &&
          double.tryParse(text)! <= 2024999999) {
        if (await auth.addStudent(text, pass)) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Account Created !"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: const Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Your Account has been successfully created! You can use your credentials to login",
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
                    child: const Text('Ok'),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        if (text == 'root') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Admin()));
        }
      }
    } else if (double.tryParse(text) == null) {
      if (await auth.addStaff(text, pass)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Account Created !"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: const Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Your Account has been successfully created! You can use your credentials to login",
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
                  child: const Text('Ok'),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void OpenRegistrationForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Create an Account")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.account_circle),
                labelText: "Staff ID / Student ID",
              ),
              onChanged: (text) => setState(() {
                this.text = text;
              }),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.lock),
                labelText: "Insert Password",
              ),
              onChanged: (pass) => setState(() {
                this.pass = pass;
              }),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.lock_clock),
                labelText: "Confirm Password",
              ),
              onChanged: (pass) => setState(() {
                this.pass = pass;
              }),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, // Makes the button take up the full width
              child: ElevatedButton(
                onPressed: () {
                  showStatusRegister();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Text color
                  elevation: 5, // Elevation
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: Text('Sign Up'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void CheckPrivileges() async {
    if (double.tryParse(text) != null) {
      if (double.tryParse(text)! >= 2018000000 &&
          double.tryParse(text)! <= 2024999999) {
        if (await auth.getUser(text, pass)) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Student()));
        }
      }
    } else if (text == 'root') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Admin()));
    } else {
      if (await auth.getUser(text, pass)) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Staff()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: Controller,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.account_circle), labelText: "Username"),
          onChanged: (text) => {this.text = text},
        ),
        TextField(
          obscureText: showPass,
          onChanged: (text) => {
            setState(() {
              pass = text;
            })
          },
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              labelText: "Password",
              suffixIcon: IconButton(
                  icon: showPass
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                  tooltip: "Show Password",
                  splashColor: Colors.blue,
                  onPressed: () => {
                        setState(() {
                          showPass = !showPass;
                        })
                      })),
        ),
        SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () => {
                        CheckPrivileges(),
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                                topRight: Radius.circular(5.0),
                                bottomLeft: Radius.circular(5.0),
                                bottomRight: Radius.circular(5.0))),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text("Login"),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_circle_right)
                      ]),
                    )),
                ElevatedButton(
                  onPressed: () async {
                    await _login(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0),
                            bottomLeft: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0))),
                  ), // Call the SSO login method
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text("Login with SSO"),
                    SizedBox(width: 10),
                    Icon(Icons.login)
                  ]),
                ),
                GestureDetector(
                  onTap: () => OpenRegistrationForm(),
                  child: const Text('First Time? Register Here'),
                )
              ],
            ))
      ],
    );
  }
}
