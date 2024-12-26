import 'package:flutter/material.dart';
import 'package:gn_account_manager/Authtentication/login.dart';
import 'package:gn_account_manager/Authtentication/users.dart';
import 'package:gn_account_manager/dashboard.dart';
import 'package:gn_account_manager/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();
  bool isVisible = false;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }



  Future<void> _setSignupStatus(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedUp', true);
    await prefs.setString('username', username); // Save username
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/image/omram.png",
                    width: 350,
                  ),
                  // Username input field
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: username,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Username is required";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Username",
                      ),
                    ),
                  ),
                  // Password input field
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        border: InputBorder.none,
                        hintText: "Password",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: Icon(isVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),
                  // Confirm Password input field
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: confirmpassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Confirm Password is required";
                        } else if (password.text != confirmpassword.text) {
                          return "Passwords don't match";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock),
                        border: InputBorder.none,
                        hintText: "Confirm Password",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: Icon(isVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Sign up button
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * 8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple),
                    child: TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final db = AppDatabaseHelper();
                          bool userExists = await db.doesUserExist(username.text);
                          //
                          if (userExists) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(content: Text('Username already exists!')));
                            db.login(Users(
                                usrName: username.text, usrPassword: password.text))
                                .whenComplete(() async {
                              await _setSignupStatus(username.text); // Pass username
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Dashboard()),
                              );
                            }
                            );
                          }
                          else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Not Exist')));
                          }

                          }
                        },

                      child:
                      Text("Login ", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  // Login redirect

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
