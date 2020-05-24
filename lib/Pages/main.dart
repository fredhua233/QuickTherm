import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'ConnectingDevicesPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChooseIdentityPage.dart';
import 'package:flutterapp/Utils/Utils.dart';

Menu menu = new Menu();
void main() => runApp(BLETherometer());

//TODO：If the user already set up info, move choose devices, which moves to temperature else move to choose identity page
class BLETherometer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
//    _prefs.then((identity) {
//      //FIXME: delete line below
//      identity.setString("id", "resident");
//      ///////////////////////////////////////
//      if (identity.containsKey("id")) {
//        String id = identity.getString("id");
//        switch (id) {
//          case "resident":
//            return MaterialApp(
//                title: 'BLE Thermometer',
//                theme: ThemeData(
//                  primarySwatch: Colors.blue,
//                ),
//                //FIXME: Change below to ChooseIdentity
//                home: ConnectingDevicesPage(title: "Available Devices", storage: NameStorage(), autoConnect: true)
//            );
//            break;
//          case "manager":
//          //FIXEME: below only true if manager decides to connect to a device.
//            return MaterialApp(
//                title: 'BLE Thermometer',
//                theme: ThemeData(
//                  primarySwatch: Colors.blue,
//                ),
//                //FIXME: Change below to ChooseIdentity
//                home: ConnectingDevicesPage(title: "Available Devices", storage: NameStorage(), autoConnect: true)
//            );
//            break;
//          case "overseer":
//            break;
//        }
//      }
//    });
    return MaterialApp(
      title: 'BLE Thermometer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //FIXME: Change below to ChooseIdentity
      home: ConnectingDevicesPage(title: "Available Devices", storage: NameStorage(), autoConnect: true)
    );
  }
}



















