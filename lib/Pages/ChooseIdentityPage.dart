import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ConnectingDevicesPage.dart';

class ChooseIdentityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose my identity'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  sharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  String getDropDownItem() {
    setState(() {
      temp = _identity;
    });
    return temp;
  }

  addStringToSF(key, value) {
    sharedPref().setString(key, value);
  }

  String getValueSF() {
    return sharedPref().getstring('id');
  }

  bool isPresent() {
    sharedPref().containsKey('id');
  }

  autoLogin() {
    if (isPresent() != null) {
      switch (getValueSF()) {
        case 'resident':
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConnectingDevicesPage(
                      title: "Available Devices", storage: NameStorage())));
          break;
        case 'manager':
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConnectingDevicesPage(
                      title: "Available Devices", storage: NameStorage())));
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
                  addStringToSF('id', 'resident');

                  ///key: id, value: resident
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectingDevicesPage(title: "Available Devices", storage: NameStorage())));
                  //go to profile page TODO: finish profile page
                  break;
                case 'manager':
                  addStringToSF('id', 'manager');

                  ///key: id, value: manager
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectingDevicesPage(title: "Available Devices", storage: NameStorage())));
                  //go to profile page TODO: finish profile page
                  break;
//                case 'hospital':
//                go to checking building page
              }
            }
          },
        )
      ],
    ));
  }
}
