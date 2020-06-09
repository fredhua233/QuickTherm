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
import 'Pages/StartUp/SetUpInfoPage.dart';
import 'Pages/ConnectingDevicesPage.dart';
import 'Utils/Utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Utils/UserInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Pages/HistoryPage.dart';

void main() => runApp(BLETherometer());

//TODO：If the user already set up info, move choose devices, which moves to temperature else move to choose identity page
//Clean Data base aka only keep recent 2 weeks
class BLETherometer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'BLE Thermometer',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        //FIXME: Change below to ChooseIdentity
//        home: GeneratePage()
//        home: ChooseIdentityPage(),
        home: UnitsGrid(units: UserInfo().fireStore.collection("/Organizations/Santa's Toy Factory/Managers/Miles/Units"))
//      home: Director(managers: UserInfo().fireStore.collection("/Organizations/Santa's Toy Factory/Managers"))
//        home: HelpPage(),
//        home: Initialize(),
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
  Future<SharedPreferences> _prefs = Utils().pref;
  String _identity;
  String _path;
  Firestore _firestore = Firestore.instance;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void>_init() async {
    SharedPreferences pref = await _prefs;
    setState(() {
      _identity = pref.getString('id') ?? "";
//    _identity = "";
      _path = pref.getString("path") ?? "";
//      _path = "/Organizations/Santa's Toy Factory/Managers/Miles/Units/Unit1/Individuals/Anthony";
      UserInfo.path = _path;
    });
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
                    return UnitsGrid(units: UserInfo().fireStore.collection(_path));
//                    return UnitsGrid(units: UserInfo().fireStore.collection("/Organizations/Santa's Toy Factory/Managers/John White/Units"));
                  case "director":
                    return Director(managers: UserInfo().fireStore.collection(_path));
//                    return Director(managers: UserInfo().fireStore.collection("/Organizations/Santa's Toy Factory/Managers"));
                  case "":
                    return ChooseIdentityPage();
                  default:
                    return Container();
                }
              }
          }
        });
  }
}