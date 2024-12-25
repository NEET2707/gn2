import 'package:flutter/material.dart';
import 'package:gn_account_manager/Authtentication/signup.dart';
import 'package:gn_account_manager/dashboard.dart';
import 'package:gn_account_manager/database_helper.dart';
import 'users.dart';
import 'users.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isVisible = false;
  bool isLoginTrue = false;

  final formKey = GlobalKey<FormState>();

  final db = AppDatabaseHelper();

  login() async {
    // Accessing username and password from controllers
    var response = await db.login(
      Users(
        usrName: usernameController.text,
        usrPassword: passwordController.text,
      ),
    );

    // Handle the response from the login function
    if (response == true) {
      // Navigate to the Notes screen if login is successful
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()), // Ensure Notes screen is defined
      );
    } else {
      // Show error if login fails
      setState(() {
        isLoginTrue = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset("assets/image/accound_image.png", width: 250),
                  SizedBox(height: 10),
                  // Username
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: usernameController,
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

                  // Password
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: passwordController,
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
                          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Login Button
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple,
                    ),
                    child: TextButton(
                      onPressed: (){
                        if(formKey.currentState!.validate()){
                          login();



                        }
                      }, // Use the login function
                      child: Text("LOGIN", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Signup()), // Navigate to Signup page
                          );
                        },
                        child: Text("SIGN UP"),
                      ),
                    ],
                  ),
                  isLoginTrue? Text("Username or passowrd is incorrect",
                  style: TextStyle(color: Colors.red ),
                  ) : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
