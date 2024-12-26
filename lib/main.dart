import 'package:flutter/material.dart';
import 'package:gn_account_manager/Authtentication/login.dart';
import 'package:gn_account_manager/Authtentication/signup.dart';
import 'dashboard.dart';
import 'Authtentication/splashscreen.dart';

void main() {
  runApp(MaterialApp(
    title: 'Account Manager',
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}
