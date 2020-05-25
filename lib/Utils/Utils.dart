import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";

import '../Pages/ConnectingDevicesPage.dart';
import '../Pages/ProfilePage.dart';
import '../Pages/TempMonitorPage.dart';

class Menu {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String identity;

  Future<String> getIdentity() async {
    SharedPreferences pref = await _prefs;
    identity = pref.getString("id");
    return pref.getString("id");
  }

  Widget getMenu(BuildContext context) {
    switch (identity) {
      case "resident":
        print("resident");
        return PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case "profile":
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                  break;
                case "TempMon":
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TempMonitorPage(Device, Services)));
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
                      value: "Temperature Monitor",
                      child: Text(
                        "TempMon",
                      ))
                ],
            icon: Icon(Icons.menu));
        break;
      case "manager":
        break;
      case "overseer":
        break;
    }
  }
}
