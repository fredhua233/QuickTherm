import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mock_data/mock_data.dart';
import 'package:quicktherm/Utils/UserInfo.dart';

class GeneratePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GeneratePageState();
}

//FIXME: Change to more realistic data

class GeneratePageState extends State<GeneratePage> {

  @override
  Widget build(BuildContext context) {
    UserInfo _user = new UserInfo();
    Firestore firestore = _user.fireStore;

    return Scaffold(
      appBar: AppBar(
        title: Text("Generate"),
      ),
      body: Text("Generate"),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            CollectionReference managers = firestore.collection("/Organizations/Santa's Toy Factory/Managers");
            for (int i = 1; i <= 1; i++) {
              String managerName = mockName();
              DocumentReference manager = managers.document(managerName);
              await manager.setData({"Name" : managerName, "Num of Res" : 50});
              CollectionReference units = manager.collection("Units");
              for (int j = 1; j <= 25; j++) {
                String unitStatus = "";
                bool potential = false;
                bool ill = false;
                bool healthy = false;
                var names = [];
                CollectionReference inds = units.document("Unit$j").collection("Individuals");
                for (int k = 0; k < 2; k++) {
                  Individual person = new Individual(managerName, j);
                  String name = person.info["Name"];
                  names.add(name);
                  if (person.info["Primary Tag"] == Colors.black.toString()) {
                    ill = true;
                  } else if (person.info["Primary Tag"] == Colors.black45.toString()) {
                    potential = true;
                  } else if (person.info["Primary Tag"] == Colors.white.toString()) {
                    healthy = true;
                  }
                  if (healthy && !potential && !ill) {
                    unitStatus = "healthy";
                  } else if (ill) {
                    unitStatus = "ill";
                  } else if (potential && !ill) {
                    unitStatus = "potentially ill";
                  } else {
                    unitStatus = "unknown";
                  }
                  await inds.document(name).setData(person.info);
                }
                await units.document("Unit$j").setData({"Name" : "Unit $j",
                  "Unit Status" : unitStatus,
                  "Residents" : names});
              }
            }
          },
          label: Text("Generate")),
    );
  }
}

class Individual {
    Map<String, dynamic> _info = new Map<String, dynamic>();
    Random _random = new Random();
    String _sex = Random().nextInt(2) == 0 ? "Male" :"Female";
    Individual(String manager, int i) {
      _info.addAll({"Date of Birth" : mockDate(DateTime.parse("1930-06-04"), DateTime.parse("1960-06-04")).toString().substring(0, 10),
                    "Contacts" : mockInteger(100, 999).toString() + "-" + mockInteger(100, 999).toString() + "-" + mockInteger(1000, 9999).toString(),
                    "Unit Name" : "Unit $i",
                    "Manager Name": manager,
                    "Name" : mockName(_sex.toLowerCase()),
                    "Sex" : _sex,
                    "Address" : "123 North Pole Ave., Santa's Secret Village, NP, 10001",
                    "Organization" : "Santa's Toy Factory",
                    "Temperature" : _genTemp()});
      _genTags();
    }

    _genTags() {
      String _primaryTag, _secondaryTag, _healthMsg;
      Map temps = _info["Temperature"];
      var dates = temps.keys.toList();
      dates.sort((a, b) => a.compareTo(b));
      String lm = dates.last;
      double temp = temps[dates.last];
      if (temp < 35) {
          _primaryTag = Colors.black.toString();
          _secondaryTag = Colors.blue.toString();
          _healthMsg = "Ill, potential hypothermia ";
      } else if (temp > 37.5) {
          _primaryTag = Colors.black.toString();
          _secondaryTag = Colors.red.toString();
          _healthMsg = "Ill, potential fever";
      } else {
        int c = _random.nextInt(2);
        _primaryTag = c == 1 ? Colors.black45.toString() : Colors.white.toString();
        _healthMsg = c == 0 ?
             "Healthy, normal temperature"
            : "Potential illness/recovery, \n normal temperature";
        _secondaryTag = Colors.green.toString();
      }
      var pHlthCond = _getPCond();
      _info.addAll({"Prior Medical Condition" : pHlthCond,
                    "Last Measured" : lm,
                    "Health Message" : _healthMsg,
                    "Primary Tag" : _primaryTag,
                    "Secondary Tag" : _secondaryTag});
    }

    _getPCond() {
      switch (_random.nextInt(2)) {
        case 0:
          return false;
        case 1:
          switch (_random.nextInt(4)) {
            case 0:
              return "Diabetes";
            case 1:
              return "High blood pressure";
            case 2:
              return "Allergic to antibiotics";
            case 3:
              return "Major surgery before";
          }
          break;
      }
    }


    Map<String, dynamic> _genTemp() {
      Map<String, dynamic> temps = new Map<String, dynamic>();
      for (int i = 0; i < 1000; i ++) {
        double temp = _random.nextDouble() + _random.nextInt(4) + 34;
        temps.addAll({mockDate(DateTime.parse("2020-05-21 15:39:04"), DateTime.now()).toString() : temp});
      }
      return temps;
    }

    Map<String, dynamic> get info => _info;

}
