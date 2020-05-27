import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfo {
  String Name, //
      address, //
      phoneNumber, //
      managerName, //
      sex, //
      healthHistory, //
      DOB,

      ///changing to showDatePicker
      age,

      ///doing this later
      identity, //
      organization,
      building,
      roomNumber; //
  bool priorHealth; //
  Illness condition; //
  TimeOfDay remindTimeAM, remindTimePM, remindTimeNOON; //
  ///where to put persistence? here or Utils?
  ///NOTE: SharedPreference put in Utils
  Firestore _firestore = Firestore.instance;
  DocumentReference _userInfo;

  UserInfo() {
//    _userInfo = _firestore.document("/Organizations/" +
//        organization +
//        "/Buildings/" +
//        building +
//        "/Units/" +
//        roomNumber +
//        "/Individuals/" +
//        Name);
    _userInfo = _firestore.document(
        "/Organizations/Testing/Buildings/Building1/Units/Unit1/Individuals/JohnWhite");
  }

  DocumentReference get log => _userInfo;
  Firestore get fireStore => _firestore;

  save() {
    print('save to firebase or persistence');
  }
}

enum Illness { severe, potential, healthy }
