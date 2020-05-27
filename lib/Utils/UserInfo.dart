import 'package:flutter/material.dart';

class UserInfo {
  String Name,  //
         address, //
         phoneNumber, //
         managerName,//
         sex, //
         healthHistory, //
         DOB,  ///changing to showDatePicker
         age, ///doing this later
         identity,//
         organization,
         roomNumber;//
  bool priorHealth; //
  Illness condition; //
  TimeOfDay remindTimeAM, remindTimePM, remindTimeNOON; //
  ///where to put persistence? here or Utils?
  ///NOTE: SharedPreference put in Utils
  save(){
    print('save to firebase or persistence');
  }
}

enum Illness { severe, potential, healthy }
