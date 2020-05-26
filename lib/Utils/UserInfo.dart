//  import 'package:flutter/material.dart';

class UserInfo {
  String Name,
      address,
      phoneNumber,
      managerName,
      sex,
      healthHistory,
      DOB,
      age,
      identity;
  bool reminderDaily;
  Illness condition;
//  TimeOfDay remindTime;
  ///where to put persistence? here or Utils?
  ///NOTE: SharedPreference put in Utils
}

enum Illness { severe, potential, healthy }
