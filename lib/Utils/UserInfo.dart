import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserInfo {
  static String name,
                address,
                phoneNumber,
                managerName,
                sex,
                identity,
                organization,
                unitName,
                primaryTag,
                secondaryTag,
                healthMsg,
                lastMeasured,
                path,
                managerPath,
                directorPath;
  static int age, currentNumRes;
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
  DocumentReference _managerInfoCF;
  DocumentReference _directorInfoCF;
  DocumentReference _unitInfo;
  CollectionReference _unitmates;

  UserInfo();

  UserInfo.defined() {
    String unitPath = "";
    String unitMates = "";
    _userInfoCF = _firestore.document(path);
    var directories = path.split("/");
    for (var folder in directories.sublist(1, directories.length - 2)) {
      unitPath += "/$folder";
    }
    unitMates = unitPath + "/Individuals";
    _unitInfo = _firestore.document(unitPath);
    _unitmates = _firestore.collection(unitMates);
//    _userInfoCF = _firestore.document("/Organizations/Santa's Toy Factory/Managers/Miles/Units/Unit1/Individuals/Anthony");
//    _unitInfo = _firestore.document("/Organizations/Santa's Toy Factory/Managers/Miles/Units/Unit1");
//    _unitmates = _firestore.collection("/Organizations/Santa's Toy Factory/Managers/Miles/Units/Unit1/Individuals");
  }

  CollectionReference get mates => _unitmates;
  DocumentReference get unit => _unitInfo;
  DocumentReference get log => _userInfoCF;
  Firestore get fireStore => _firestore;

//  dummyField() async {
//    String temp = '/Organizations/$organization';
//    await _firestore.document(temp).setData({'name' : organization});
//    temp += '/Managers/$managerName';
//    await _firestore.document(temp).setData({'name' : managerName});
//    temp += '/Units/$unitName';
//    await _firestore.document(temp).setData({'name' : unitName});
//    print('dummy added');
//deleted because individuals will set up last

  individualSave() async {

    path = '/Organizations/$organization/Managers/$managerName/Units/$unitName/Individuals/$name';
    pref = await SharedPreferences.getInstance();
    pref.setString('path', path);
    _managerInfoCF = _firestore.document(managerPath);
    _userInfoCF = _firestore.document(path);
//    DocumentSnapshot current = await _managerInfoCF.get();
//    currentNumRes = current.data['Num of Res'];
    print('Happening');

    _userProfile = {
      'Name': name,
      'Contacts': phoneNumber,
      'Unit Name' : unitName,
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
    _managerInfoCF.updateData({
      "Num of Res" : FieldValue.increment(1)
    });
  }
  managerSave(Map<String, dynamic> managerMap) async {
    managerPath = '/Organizations/${managerMap['Organization']}/Managers/${managerMap['Name']}';
    pref = await SharedPreferences.getInstance();
    pref.setString('path', managerPath);
    _managerInfoCF = _firestore.document(managerPath);

    await _managerInfoCF.setData(managerMap);
  }
  directorSave(Map<String, dynamic> directorMap) async {
    directorPath = '/Organizations/${directorMap['Organization']}';
    pref = await SharedPreferences.getInstance();
    pref.setString('path', directorPath);
    _directorInfoCF = _firestore.document(directorPath);

    await _directorInfoCF.setData(directorMap);
  }
}

  enum Illness { severe, potential, healthy }

