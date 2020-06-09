import 'package:flutter/material.dart';
import 'package:quicktherm/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SetUpInfoPage.dart';
import 'ManagerSetUpInfo.dart';
import '../ConnectingDevicesPage.dart';
import 'package:quicktherm/Pages/Director/Director.dart';

class ChooseIdentityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose my identity'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('I am a:'),
            selectIdentity(),
          ],
        ),
      ),
    );
  }
}

class selectIdentity extends StatefulWidget {
  @override
  _selectIdentityState createState() => _selectIdentityState();
}

class _selectIdentityState extends State<selectIdentity> {
  String _identity;
  String temp;
  bool checkValue;
  SharedPreferences _pref;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  getPref () async {
    _pref = await Utils().pref;
  }
  String getDropDownItem() {
    setState(() {
      temp = _identity;
    });
    return temp;
  }

  addStringToSF(key, value) {
    _pref.setString(key, value);
  }

  String getValueSF(String key) {
    return _pref.getString(key);
  }

  bool isPresent() {
    return _pref.containsKey('id');
  }

  autoLogin() {
    if (isPresent() != null) {
      switch (getValueSF('id')) {
        case 'resident':
          Navigator.push(
              context,
              MaterialPageRoute(
                 builder: (context) =>  setUpInfoPage()));
//                  ConnectingDevicesPage(
//                      title: "Available Devices", storage: NameStorage())));
          break;
        case 'manager':
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => managerSetUpInfo()));
//                      ConnectingDevicesPage(
//                      title: "Available Devices", storage: NameStorage())));
          break;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: <Widget>[
        DropdownButton<String>(
          items: [
            DropdownMenuItem<String>(
              child: Text('SRO Resident'),
              value: 'resident',
            ),
            DropdownMenuItem<String>(
              child: Text('SRO Manager'),
              value: 'manager',
            ),
            DropdownMenuItem<String>(
              child: Text('Hospital'),
              value: 'hospital',
            ),
          ],
          onChanged: (String value) {
            setState(() {
              _identity = value;
            });
          },
          hint: Text('identity'),
          value: _identity,
        ),
        RaisedButton(
          child: Text('Continue'),
          onPressed: () {
            if (_identity != null) {
              switch (_identity) {
                case 'resident':
                  //addStringToSF('id', 'manager');
                  addStringToSF('id', 'resident');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => setUpInfoPage()));
                  print('My identity is ' + getValueSF('id'));
                  ///key: id, value: resident
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectingDevicesPage(title: "Available Devices", storage: NameStorage())));
                  //go to profile page TODO: finish profile page
                  break;
                case 'manager':
                  addStringToSF('id', 'manager');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => managerSetUpInfo()));
                  ///key: id, value: manager
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectingDevicesPage(title: "Available Devices", storage: NameStorage())));
                  //go to profile page TODO: finish profile page
                  break;
//                case 'hospital':
//                  addStringToSF('id', 'director');
//                  Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                          builder: (context) => ));
//                  break;
              }
            }
          },
        )
      ],
    ));
  }
}
