import 'package:basic_app/student.dart';
import 'package:basic_app/admin.dart';
import 'package:basic_app/staff.dart';
import 'package:basic_app/api/auth.dart';
import 'package:flutter/material.dart';
import 'package:basic_app/api/auth.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  final FlutterAppAuth appAuth = const FlutterAppAuth();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> _login() async {
    try {
      final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          'your_client_id',
          'your_redirect_uri',
          issuer: 'https://your_issuer',
          scopes: ['openid', 'profile', 'email'],
        ),
      );

      if (result != null) {
        await secureStorage.write(
            key: 'access_token', value: result.accessToken);
        await secureStorage.write(key: 'id_token', value: result.idToken);
        // Navigate to the next page or perform other actions
      }
    } catch (e) {
      print('Error during SSO login: $e');
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Student()));
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
                    margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
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
                const SizedBox(height: 20), // Add some spacing between buttons
                ElevatedButton(
                  onPressed: _login,
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
