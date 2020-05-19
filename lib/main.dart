import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ConnectingDevicesPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(BLETherometer());

//TODO：If the user already set up info, move to profile page, else move to choose identity page
class BLETherometer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Thermometer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConnectingDevicesPage(title: "Available Devices", storage: NameStorage()),
    );
  }
}



















