import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicktherm/Generate.dart';
import 'package:quicktherm/Pages/Director/Director.dart';
import 'package:quicktherm/Pages/Manager/UnitsGrid.dart';
import 'package:quicktherm/Pages/ProfilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/StartUp/ChooseIdentityPage.dart';
import 'Pages/ConnectingDevicesPage.dart';
import 'Utils/Utils.dart';
import 'Utils/UserInfo.dart';
//Menu menu = new Menu();

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
//        home: UnitsGrid(units: UserInfo().fireStore.collection("/Organizations/Testing/Buildings/Building1/Units"))
      home: Director()
//        home: ProfilePage(),
    );
  }
}


//class Initialize extends StatefulWidget{
//  Initialize({Key key}) : super(key: key);
//  @override
//  State<StatefulWidget> createState() => InitializeState();
//}
//
//class InitializeState extends State<Initialize> {
//  Future<SharedPreferences> _prefs = Utils().pref;
//  Future<String> _identity;
//
//  @override
//  void initState() {
//    super.initState();
//    _identity = _prefs.then((SharedPreferences prefs) {
//      return (prefs.getString('id') ?? "");
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//      return FutureBuilder<String>(
//        future: _identity,
//        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//          switch (snapshot.connectionState) {
//            case ConnectionState.waiting:
//              return const LinearProgressIndicator();
//            default:
//              if (snapshot.hasError) {
//                return Text('Error: ${snapshot.error}');
//              } else {
//                String id = snapshot.data;
//                switch (id) {
//                  case "resident":
//                    return ConnectingDevicesPage(title: "Avaliable Devices", storage: NameStorage(), autoConnect: true);
//                  case "":
//                    return ChooseIdentityPage();
//                  default:
//                    return Container();
//                }
//              }
//          }
//        });
//  }
//}