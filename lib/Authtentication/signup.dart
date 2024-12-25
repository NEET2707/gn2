import 'package:flutter/material.dart';
import 'package:gn_account_manager/Authtentication/login.dart';
import 'package:gn_account_manager/Authtentication/users.dart';
import 'package:gn_account_manager/database_helper.dart';

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

                  ListTile(
                    title: Text("Register New Account", style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    margin:  EdgeInsets.all(8),
                    padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: username,
                      validator: (value){
                        if(value!.isEmpty){
                          return "username is required";
                        }
                        return null;
                      },
                      decoration:  InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Username",
                      ),
                    ),
                  ),

                  Container(
                    margin:  EdgeInsets.all(8),
                    padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple.withOpacity(.2),
                    ),
                    child: TextFormField(
                      controller: password,
                      validator: (value){
                        if(value!.isEmpty){
                          return "password is required";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                          icon: Icon(Icons.lock),
                          border: InputBorder.none,
                          hintText: "Password",
                          suffixIcon: IconButton(onPressed: (){
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                              icon: Icon(isVisible? Icons.visibility : Icons.visibility_off))
                      ),
                    ),
                  ),


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
                          return "Password is required";
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
                          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ),


                  SizedBox(height: 10,),

                  //login
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * 8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple),
                    child: TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // Calling the registerUser method to register the user


                          final db = AppDatabaseHelper();
                          db.signup(Users(usrName: username.text, usrPassword: password.text))
                              .whenComplete(() {
                             Navigator.push(context, MaterialPageRoute(builder: (context) =>LoginScreen()));
                          });
                        }
                      },
                      child: Text("SIGN UP", style: TextStyle(color: Colors.white)),
                    ),

                  ),


                  //sign up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?"),
                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
                      }, child: Text("LOGIN"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
