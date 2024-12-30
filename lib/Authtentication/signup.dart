import 'package:flutter/material.dart';
import 'package:gn_account_manager/clientscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Signup extends StatefulWidget {
  final String pincheck;
  const Signup({super.key, required this.pincheck});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final usernameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = true;



  @override
  void initState() {
    super.initState();
    _checkIfUserAlreadySignedUp();
  }

  // Check if user has already entered their name
  Future<void> _checkIfUserAlreadySignedUp() async {
    final prefs = await SharedPreferences.getInstance();
    bool isSignedUp = prefs.getBool('isSignedUp') ?? false;

    // Simulate splash screen behavior with a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (isSignedUp) {
        isLoading = false;
        // Navigate directly to the Dashboard if the user is signed up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }
    });
  }

  // Set the sign-up status in SharedPreferences
  Future<void> _setSignupStatus(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedUp', true); // Mark user as signed up
    await prefs.setString('username', username); // Store username
  }

  @override
  Widget build(BuildContext context) {
    print(widget.pincheck);

    return Scaffold(
      appBar:  isLoading ? null : AppBar(
        title: Text("Account Signup"),
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display the entered username in the header
                  Text(
                    "Welcome, ${usernameController.text.isEmpty ? 'New User' : usernameController.text}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 10),
                  // Sign up button
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple,
                    ),
                    child: TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // Set signup status and username
                          await _setSignupStatus(usernameController.text);
                          // After signup, navigate to the dashboard
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Dashboard()),
                          );
                        }
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
