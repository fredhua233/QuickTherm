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
  //FIXME: remember to change line below
  Illness condition = Illness.severe;
//  TimeOfDay remindTime;
  ///where to put persistence? here or Utils?
  ///NOTE: SharedPreference put in Utils
}

enum Illness { severe, potential, healthy }
