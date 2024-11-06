import 'package:basic_app/student.dart';
import 'package:basic_app/admin.dart';
import 'package:basic_app/staff.dart';
import 'package:basic_app/api/auth.dart';
import 'package:flutter/material.dart';
import 'package:basic_app/api/auth.dart';

class MyPage extends StatelessWidget {
   @override
   Widget build(BuildContext Context){
    return Scaffold(
      appBar: AppBar(title: Text('Login Page')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: InputLogin()
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center
      ),
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
  String text="", pass="";
  final Controller = TextEditingController();
  Authentication auth = Authentication();
  late Future dialog;

  @override
  void dispose(){
    super.dispose();
  }

  void showStatusRegister() async {
    if(double.tryParse(this.text) != null){
      if(double.tryParse(this.text)! >= 2018000000 && double.tryParse(this.text)! <= 2024999999){
         if(await auth.addStudent(this.text, this.pass)){
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Account Created !"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Row(
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
                    child: Text('Ok'),
                  ),
                ),
              ],
            ),
          );
        }
      } else if(this.text == 'root'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Admin()));
      } 
    } else {
         if(await auth.addStaff(this.text, this.pass)){
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Account Created !"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Row(
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
                    child: Text('Ok'),
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
      title: Center(child: Text("Create an Account")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.account_circle),
              labelText: "Staff ID / Student ID",
            ),
            onChanged: (text) => setState(() {
              this.text = text;
            }),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.lock),
              labelText: "Insert Password",
            ),
            onChanged: (pass) => setState(() {
              this.pass = pass;
            }),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.lock_clock),
              labelText: "Confirm Password",
            ),
            onChanged: (pass) => setState(() {
              this.pass = pass;
            }),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity, // Makes the button take up the full width
            child: ElevatedButton(
              onPressed: () {
                showStatusRegister();
                Navigator.of(context).pop();
              },
              child: Text('Sign Up'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, 
                backgroundColor: Colors.blue, // Text color
                elevation: 5, // Elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}


  void CheckPrivileges() async {
    if(double.tryParse(this.text) != null){
      if(double.tryParse(this.text)! >= 2018000000 && double.tryParse(this.text)! <= 2024999999){
        if(await auth.getUser(this.text, this.pass)){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Student()));
        }
      }
    } else if(this.text == 'root'){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Admin()));
    } else {
      if(await auth.getUser(this.text, this.pass)){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Staff()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: Controller,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.account_circle),
            labelText: "Username"
          ),
          onChanged: (text) => {
              this.text = text
          },
        ),
        Text(this.text),
        TextField(
          obscureText: this.showPass,
          onChanged: (text) => {
            setState(() {
              this.pass = text;
            })
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            labelText: "Password",
            suffixIcon: IconButton(
              icon: showPass ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
              tooltip: "Show Password",
              splashColor : Colors.blue,
              onPressed: () => {
                setState((){
                  this.showPass = !this.showPass;
                })
              }
            )
          ),
        ),
      SizedBox(
        width: double.infinity,
        child:  Column(children: [
          Container(
          margin: EdgeInsets.only(
            top: 20.0,
            bottom: 20.0
          ),
          child: ElevatedButton(
            onPressed : () => {
              CheckPrivileges(),
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Login"),
                SizedBox(width: 10),
                Icon(Icons.arrow_circle_right)
              ]),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0)
                )
              ),
            ),
          )
        ),
        GestureDetector(
          onTap: () => this.OpenRegistrationForm(),
          child: Text('First Time? Register Here'),
        )
        ],)
      )
      ],
    );
  }
}