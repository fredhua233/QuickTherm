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
            CollectionReference units = firestore.collection("/Organizations/Testing/Buildings/Building2/Units");
            String manager = mockName();
            for (int i = 3; i <= 30; i++) {
              String unitStatus = "";
              bool potential = false;
              bool ill = false;
              bool healthy = false;
              var names = [];
              CollectionReference inds = units.document("Unit$i").collection("Individuals");
              for (int j = 0; j < 3; j++) {
                Individual person = new Individual(manager, i);
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
              await units.document("Unit$i").setData({"Name" : "Unit $i",
                                                      "Unit Status" : unitStatus,
                                                      "Residents" : names});
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
      _info.addAll({"Date of Birth" : mockDate(DateTime.parse("1930-06-04"), DateTime.parse("1960-06-04")).toString(),
                    "Contacts" : mockInteger(100, 999).toString() + "-" + mockInteger(100, 999).toString() + "-" + mockInteger(1000, 9999).toString(),
                    "Health Message" : "N/A",
                    "Last Measured" : mockDate(DateTime.parse("2020-06-04 14:13:04"), DateTime.now()).toString(),
                    "Unit Number" : "Unit $i",
                    "Manager Name": manager,
                    "Name" : mockName(_sex),
                    "Prior Medical Condition" : "N/A",
                    "Sex" : _sex,
                    "Temperature" : _genTemp()});
      _genTags();
    }

    _genTags() {
      switch (_random.nextInt(3)) {
        case 0:
          String stag = "";
          String ptag = Colors.black.toString();
          switch (_random.nextInt(2)) {
            case 0:
              stag = Colors.red.toString();
              break;
            case 1:
              stag = Colors.blue.toString();
              break;
          }
          _info.addAll({"Primary Tag" : ptag,
                         "Secondary Tag" : stag});
          break;
        case 1:
          String ptag = Colors.black45.toString();
          String stag = Colors.green.toString();
          _info.addAll({"Primary Tag" : ptag,
            "Secondary Tag" : stag});
          break;
        case 2:
          String ptag = Colors.white.toString();
          String stag = Colors.green.toString();
          _info.addAll({"Primary Tag" : ptag,
            "Secondary Tag" : stag});
          break;
      }
    }

    Map<String, dynamic> _genTemp() {
      Map<String, dynamic> temps = new Map<String, dynamic>();
      for (int i = 0; i < 1000; i ++) {
        double temp = _random.nextDouble() + _random.nextInt(6) + 35;
        temps.addAll({mockDate(DateTime.parse("2020-05-21 15:39:04"), DateTime.now()).toString() : temp});
      }
      return temps;
    }

    Map<String, dynamic> get info => _info;

}
