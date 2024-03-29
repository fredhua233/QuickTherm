import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";

import '../Pages/ConnectingDevicesPage.dart';
import '../Pages/ProfilePage.dart';
import '../Pages/TempMonitorPage.dart';

class Utils {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<SharedPreferences> get pref  {
    return _prefs;
}

  /**
   * Template for error dialogs.
   */

  void errDialog(String title, String msg, BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.red[100],
        );
      },
    );
  }

  Widget getMenu(BuildContext context, String identity, String currentPage) {
    switch (identity) {
      case "resident":
        return PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case "profile":
                  if (currentPage != "Profile Page") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  }
                  break;
                case "TempMon":
                  if (currentPage != "Temp Monitor Page") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TempMonitorPage(Device, Services)));
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
                  PopupMenuItem(
                      value: "profile",
                      child: Text(
                        "Profile",
                      )),
                  PopupMenuItem(
                      value: "TempMon",
                      child: Text(
                        "Temperature Monitor",
                      ))
                ],
            icon: Icon(Icons.menu));
        break;
      case "manager":
        break;
      case "overseer":
        break;
    }
    return Container();
  }
}

//class Prefs {
//  //only one instance of SF for all app
//  SharedPreferences _prefs;
//
//  Prefs(){
//    _prefs = setPref();
//  }
//
//  static setPref() async {
//    SharedPreferences _prefs = await SharedPreferences.getInstance();
//    return _prefs;
//  }
//
//  //add primitives to SF
//  addStringToSF(String key, String value) {
//    _prefs.setString(key, value);
//  }
//
//  addIntToSF(String key, int value) {
//    _prefs.setInt(key, value);
//  }
//
//  addDoubleToSF(String key, double value) {
//    _prefs.setDouble(key, value);
//  }
//
//  addBoolToSF(String key, bool value) {
//    _prefs.setBool(key, value);
//  }
//
//  //retrieve values from SF
//  getStringValuesSF(String key) {
//    String stringValue = _prefs.getString(key);
//    return stringValue;
//  }
//  getBoolValuesSF(String key) {
//    bool boolValue = _prefs.getBool(key);
//    return boolValue;
//  }
//  getIntValuesSF(String key) {
//    int intValue = _prefs.getInt(key);
//    return intValue;
//  }
//  getDoubleValuesSF(String key) {
//    double doubleValue = _prefs.getDouble(key);
//    return doubleValue;
//  }
//
//  //remove values from SF
//  removeValue(String key){
//    _prefs.remove(key);
//  }
//
//  //check if value is present
//  bool isPresent(String key) {
//    return _prefs.containsKey(key);
//  }
//}