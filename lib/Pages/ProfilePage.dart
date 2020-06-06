import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'StartUp/SetUpInfoPage.dart';
import '../Utils/UserInfo.dart';
import '../Utils/Utils.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _formKey = new GlobalKey<FormState>();
  UserInfo _user = new UserInfo.defined();
  String _path;
  double _lastTemp;
  Map<String, dynamic> _userInfo;
  DocumentReference _log;
  static Firestore _firestore = Firestore.instance;
  bool _edit = false;
  bool gotFS;

  @override
  void initState() {
    super.initState();
    getPathData();
    setState(() {
      gotFS = true;
    });
  }

  Future<Map<String, dynamic>> getPathData() async {

//    SharedPreferences _pref = await Utils().pref;
//    _path = _pref.getString('path');
//    print(_path);
    _log = _user.log;
    DocumentSnapshot _userInfoSS = await _log.get();
    _userInfo = _userInfoSS.data;
    _lastTemp = 36.0;
    return _userInfoSS.data;
  }

  Widget profileView(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getPathData(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot){
        if(!snapshot.hasData) return LoadingPage();
        return buildProfPage();
      },
    );
  }

  Widget buildProfPage() {
    return SafeArea(
      child: Form(
        key: _formKey,
        autovalidate: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget> [
                Text(_userInfo['Unit Number'] != null ? _userInfo['Unit Numeber'] : "DEFAULT"),
                TextFormField(
                  initialValue: _userInfo['Name'],
                  decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Ex. John Doe',
                      labelText: 'Name'
                  ),
                  enabled: _edit,
                  validator: (value) {
                    if (value.isEmpty || !value.contains(' ')){
                      return "Please enter in correct format: 'first last'";
                    }
                    return null;
                  },
                ),
                Text(_userInfo['Age'].toString()),
                Text(_userInfo['Sex'] != null ? _userInfo['Sex'] : "Sex"),
                Text('Last Measured: '),
                SizedBox(height: 10),
                Text(_userInfo['Last Measured'].toString().substring(0, 10)),
                Text((_lastTemp.toString() + String.fromCharCode(0x00B0) + 'C' ),
                    style: _lastTemp < 35 ? TextStyle(fontSize: 50, color: Colors.blue) :
                    _lastTemp > 37.5 ? TextStyle(fontSize: 50, color: Colors.red) :
                    TextStyle(fontSize: 50, color: Colors.green)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    _lastTemp = double.parse(_userInfo['Temperature'][_userInfo['Last Measured']]);
//    _lastTemp = 36.0;
//    print(_userInfo.values);
//    print(_userInfo['Last Measured'].toString());
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
              _edit = !_edit;
            });
            },
          )
        ],
      ),
      body: profileView(context),
    );
  }
}
