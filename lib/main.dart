import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gn_account_manager/Authtentication/signup.dart';
import 'pinverificationscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();

  // Check if the PIN is already set
  String? storedPin = await storage.read(key: 'user_pin');

  // Run the app with the correct screen based on PIN availability
  runApp(MyApp(storedPin: storedPin));
}

class MyApp extends StatelessWidget {
  final String? storedPin;

  MyApp({required this.storedPin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Account Manager',
      debugShowCheckedModeBanner: false,
      home: storedPin == null ? Signup(pincheck: storedPin.toString()) : PinVerificationScreen()
      // storedPin == null ? SetPinScreen() : PinVerificationScreen(),
    );
  }
}
