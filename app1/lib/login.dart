import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app1/homepage.dart';
import 'package:app1/driver_page.dart';

import 'adminpage.dart'; 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    User? user = userCredential.user;
    if (user != null) {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users') 
          .where('email', isEqualTo: user.email) 
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userSnapshot.docs.first;
        String role = userDoc['role']; 

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Successful!")),
        );

        if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
          );
        } else if (role=="driver") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverHomePage()),
          );
        }else   {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not found in the database")),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF006f85),
      body: Padding(
        padding: const EdgeInsets.only(top: 200, left: 20, right: 20),
        child: Container(
          height: 400,
          width: 400,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Color(0xFF006f85)),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(color: Color(0xFFffffff)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
