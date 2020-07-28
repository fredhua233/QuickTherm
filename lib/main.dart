import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicktherm/Generate.dart';
import 'package:quicktherm/Pages/Director/Director.dart';
import 'package:quicktherm/Pages/HelpPage.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import 'package:quicktherm/Pages/Manager/IndividualPage.dart';
import 'package:quicktherm/Pages/Manager/UnitsGrid.dart';
import 'package:quicktherm/Pages/ProfilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/StartUp/ChooseIdentityPage.dart';
import 'Pages/StartUp/ChooseLanguage.dart';
import 'Pages/StartUp/SetUpInfoPage.dart';
import 'Pages/ConnectingDevicesPage.dart';
import 'Utils/Utils.dart';
import 'Utils/UserInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Pages/HistoryPage.dart';

void main() => runApp(BLETherometer());

String PATH, UNITPREF, LANG;
//TODO：If the user already set up info, move choose devices, which moves to temperature else move to choose identity page
//Clean Data base aka only keep recent 2 weeks
class BLETherometer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'BLE Thermometer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
//        home: GeneratePage()
//        home: ChooseIdentityPage(),
//        home: UnitsGrid(units: UserInfo().fireStore.collection("/Organizations/Santa's Toy Factory/Managers/Miles/Units"))
//      home: Director(managers: UserInfo().fireStore.collection("/Organizations/Santa's Toy Factory/Managers"))
//        home: HelpPage(),
        home: Initialize(),
//    home: setUpInfoPage(),
//        home: ProfilePage(),
//        home: IndividualPage(UserInfo.defined().log, UserInfo.defined().unit)
    );
  }
}


class Initialize extends StatefulWidget{
  Initialize({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => InitializeState();
}

class InitializeState extends State<Initialize> {
  String _identity;
  String _path;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void>_init() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
      _identity = pref.getString('id') ?? "";
//    _identity = "";
      _path = pref.getString("path") ?? "";
      PATH = _path;
      // if prefrence unit not avaliable, default is C
      UNITPREF = pref.getString("Temp Unit") ?? "C";
      LANG = pref.getString("lang") ?? "en";
      UserInfo.path = _path;
      await Utils().load();
//      _path = "/Organizations/Santa's Toy Factory/Managers/Miles/Units/Unit1/Individuals/Anthony";
  }

  @override
  Widget build(BuildContext context) {
      return FutureBuilder<void>(
        future: _init(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return LoadingPage();
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                switch (_identity) {
                  case "resident":
                    return ConnectingDevicesPage(title: "Available Devices", storage: NameStorage(), autoConnect: true);
                  case "manager":
                    return UnitsGrid(units: UserInfo().fireStore.collection(_path + "/Units"));
//                    return UnitsGrid(units: UserInfo().fireStore.collection("/Organizations/Santa's Toy Factory/Managers/John White/Units"));
                  case "director":
                    return Director(managers: UserInfo().fireStore.collection(_path + "/Managers"));
//                    return Director(managers: UserInfo().fireStore.collection("/Organizations/Santa's Toy Factory/Managers"));
                  case "":
                    return ChooseLanguagePage();
//                    return ChooseIdentityPage();
                  default:
                    return Container();
                }
              }
          }
        });
  }
}