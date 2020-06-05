import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfo {
  static String name, //
      address, //
      phoneNumber, //
      managerName, //
      sex, //
      healthHistory, //
      DOB,
      age,

  ///doing this later
      identity,
      organization,
      roomNumber,
      primaryTag,
      secondaryTag,
      healthMsg,
      lastMeasured;

  static Map<String,dynamic> temperature = new Map<String, dynamic>();
  static bool priorHealth;
  static Illness condition;
  static TimeOfDay remindTimeAM, remindTimePM, remindTimeNOON;

  ///where to put persistence? here or Utils?
  ///NOTE: SharedPreference put in Utils
  Firestore _firestore = Firestore.instance;
  DocumentReference _userInfoCF;
  DocumentReference _unitInfo;
  CollectionReference _unitmates;
  Map<String, dynamic> _userProfile = new Map<String, dynamic>();

  UserInfo();

  UserInfo.defined(){
//    _userInfoCF = _firestore.document("/Organizations/$organization/Buildings/$address/Units/$roomNumber/Individuals/$name");
//    _unitInfo = _firestore.document("/Organizations/$organization/Buildings/$address/Units/$roomNumber");
//    _unitmates = _firestore.collection("/Organizations/$organization/Buildings/$address/Units/$roomNumber/Individuals");
    _userInfoCF = _firestore.document("/Organizations/Testing/Buildings/Building1/Units/Unit1/Individuals/JohnWhite");
    _unitInfo = _firestore.document("/Organizations/Testing/Buildings/Building1/Units/Unit1");
    _unitmates = _firestore.collection("/Organizations/Testing/Buildings/Building1/Units/Unit1/Individuals");
  }

  CollectionReference get mates => _unitmates;
  DocumentReference get unit => _unitInfo;
  DocumentReference get log => _userInfoCF;
  Firestore get fireStore => _firestore;

  save() async {
    _userInfoCF = _firestore.document("/Organizations/$organization/Buildings/$address/Units/$roomNumber/Individuals/$name");
    _userProfile = {
      'Name': name,
      'Contact': phoneNumber,
      'Sex': sex,
      /// doing this later 'Age' : age,
      'Manager': managerName,
      'Primany Tag' : primaryTag,
      'Secondary Tag' : secondaryTag,
      'Health Message' : healthMsg,
      'Temperature' : temperature,
      'Last Measured' : lastMeasured,
    };
    _userProfile['Prior Medical Condition'] =
    priorHealth ? healthHistory : priorHealth;
    await _userInfoCF.setData(_userProfile);
  }

}
enum Illness { severe, potential, healthy }

