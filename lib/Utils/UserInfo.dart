import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfo {
  String Name,
      address,
      phoneNumber,
      managerName,
      sex,
      healthHistory,
      DOB,
      age, ///doing this later
      identity,
      organization,
      roomNumber;
  bool priorHealth;
  Illness condition;
  TimeOfDay remindTimeAM, remindTimePM, remindTimeNOON;
  ///where to put persistence? here or Utils?
  ///NOTE: SharedPreference put in Utils
  Firestore _firestore = Firestore.instance;
  DocumentReference _userInfoCF;
  Map<String, dynamic> _userProfile = new Map<String, dynamic>();

  UserInfo() {
    _userInfoCF = _firestore.document(
        "/Organizations/$organization/Buildings/$address/Units/$roomNumber/Individuals/$Name");
  }

  DocumentReference get log => _userInfoCF;
  Firestore get fireStore => _firestore;

  save() async {
    _userProfile = {
      'Name' : Name,
      'Contact' : phoneNumber,
      'Sex' : sex,
      /// doing this later 'Age' : age,
      'Manager' : managerName
    };
    _userProfile['Prior Medical Condition'] = priorHealth ? healthHistory : priorHealth;
    await _userInfoCF.setData(_userProfile);
  }
}

enum Illness { severe, potential, healthy }

