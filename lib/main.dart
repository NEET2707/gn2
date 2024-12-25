import 'package:flutter/material.dart';
import 'package:gn_account_manager/Authtentication/login.dart';
import 'dashboard.dart';

void main() {
  runApp(MaterialApp(
    title: 'Account Manager',
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}
