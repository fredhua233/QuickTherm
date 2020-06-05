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

class GeneratePageState extends State<GeneratePage> {

  @override
  Widget build(BuildContext context) {
    UserInfo _user = new UserInfo();
    Firestore firestore = _user.fireStore;
    Random random = new Random();

    return Scaffold(
      appBar: AppBar(
        title: Text("Generate"),
      ),
      body: Text("Generate"),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            CollectionReference units = firestore.collection("/Organizations/Testing/Buildings/Building1/Units");
            String manager = mockName();
            for (int i = 0; i < 500; i++) {
              var st = random.nextInt(3);
              await units.document("Unit$i").setData({"Name" : "Unit $i",
                                                "Unit Status" : st == 0 ? "Ill" : st == 1 ? "Potential" : "Healthy"});
              CollectionReference inds = units.document("Unit$i").collection("Individuals");
              for (int j = 0; j < 2; j++) {
                Individual person = new Individual(manager);
                String name = person.info["Name"];
                await inds.document(name).setData(person.info);
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

    Individual(String manager) {
      _info.addAll({"Contacts" : "123-456-7890",
                    "Health Message" : "N/A",
                    "Last Measured" : "N/A",
                    "Manager Name": manager,
                    "Name" : mockName(),
                    "Prior Medical Condition" : "N/A",
                    "Sex" : "N/A",
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
