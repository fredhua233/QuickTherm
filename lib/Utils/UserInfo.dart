import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserInfo {
  static String name, //
      address, //
      phoneNumber, //
      managerName, //
      sex, //
      identity,
      organization,
//      buildingNumber,
      roomNumber,
      primaryTag,
      secondaryTag,
      healthMsg,
      path,
      managerPath,
      lastMeasured;
  static int age;
  static DateTime Bday;
  static String healthHistory = 'None';
  static Map<String,dynamic> temperature = new Map<String, dynamic>();
  static bool priorHealth;
  static Illness condition;
  static TimeOfDay remindTimeAM, remindTimePM, remindTimeNOON;
  static SharedPreferences pref;
  static Firestore _firestore = Firestore.instance;
  static Map<String, dynamic> _userProfile = new Map<String, dynamic>();
  DocumentReference _userInfoCF;
  DocumentReference _unitInfo;
  CollectionReference _unitmates;

  UserInfo();

  UserInfo.defined() {
//    String unitPath = "";
//    String unitMates = "";
//    _userInfoCF = _firestore.document(path);
//    var directories = path.split("/");
//    for (var folder in directories.sublist(0, directories.length - 2)) {
//      unitPath += "/$folder";
//    }
//    unitMates = unitPath + "/Individuals";
//    _unitInfo = _firestore.document(unitPath);
//    _unitmates = _firestore.collection(unitMates);
    _userInfoCF = _firestore.document("/Organizations/Santa's Toy Factory/Managers/Miles/Units/Unit1/Individuals/Anthony");
    _unitInfo = _firestore.document("/Organizations/Santa's Toy Factory/Managers/Miles/Units/Unit1");
    _unitmates = _firestore.collection("/Organizations/Santa's Toy Factory/Managers/Miles/Units/Unit1/Individuals");
  }

  CollectionReference get mates => _unitmates;
  DocumentReference get unit => _unitInfo;
  DocumentReference get log => _userInfoCF;
  Firestore get fireStore => _firestore;

  dummyField() async {
    String temp = '/Organizations/$organization';
    await _firestore.document(temp).setData({'name' : organization});
    temp += '/Buildings/$address';
    await _firestore.document(temp).setData({'name' : address});
    temp += '/Units/$roomNumber';
    await _firestore.document(temp).setData({'name' : roomNumber});
    print('dummy added');
  }

  save() async {
    dummyField();
    path = '/Organizations/$organization/Manager/$managerName/Units/$roomNumber/Individuals/$name';
    managerPath = '/Organizations/$organization/Manager/$managerName';
    pref = await SharedPreferences.getInstance();
    pref.setString('path', path);
    _userInfoCF = _firestore.document(path);


    _userProfile = {
      'Name': name,
      'Contacts': phoneNumber,
      'Unit Name' : roomNumber,
      'Organization' : organization,
      'Address' : address,
      'Sex': sex,
      'Age' : age,
      'Date of Birth' : Bday.toString(),
      'Manager Name': managerName,
      'Primary Tag' : primaryTag,
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

