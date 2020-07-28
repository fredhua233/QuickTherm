import 'package:flutter/material.dart';
import 'package:quicktherm/Pages/StartUp/DirectorSetUpInfo.dart';
import 'package:quicktherm/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SetUpInfoPage.dart';
import 'ManagerSetUpInfo.dart';
import 'DirectorSetUpInfo.dart';
import '../ConnectingDevicesPage.dart';
import 'package:quicktherm/Pages/Director/Director.dart';

class ChooseIdentityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Utils().translate('Choose my identity')),
      ),
      body: Container(
        child: selectIdentity()
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
  Utils _utils = new Utils();
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
          break;
        case 'manager':
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => managerSetUpInfo()));
          break;
        case 'director':
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => directorSetUpInfo()));
          break;
        }
    }
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
              child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_utils.translate('I am a: ')),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            items: [
                              DropdownMenuItem<String>(
                                child: Text(_utils.translate('Resident')),
                                value: 'resident',
                              ),
                              DropdownMenuItem<String>(
                                child: Text(_utils.translate('Manager')),
                                value: 'manager',
                              ),
                              DropdownMenuItem<String>(
                                child: Text(_utils.translate('Director')),
                                value: 'director',
                              ),
                            ],
                            onChanged: (String value) {
                              setState(() {
                                _identity = value;
                              });
                              },
                            hint: Text(_utils.translate('identity')),
                            value: _identity,
                          )
                        ],
                      ),
                      RaisedButton(
                        child: Text(_utils.translate('Continue')),
                        onPressed: () {
                          if (_identity != null) {
                            switch (_identity) {
                              case 'resident':
                                //addStringToSF('id', 'manager');
                                addStringToSF('id', 'resident');
                                Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => setUpInfoPage()),
                                        (Route<dynamic> route) => false);
                                ///key: id, value: resident
                                //Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectingDevicesPage(title: "Available Devices", storage: NameStorage())));
                                //go to profile page TODO: finish profile page
                                break;
                                case 'manager':
                                  addStringToSF('id', 'manager');
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => managerSetUpInfo()), (Route<dynamic> route) => false);
                                  ///key: id, value: manager
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectingDevicesPage(title: "Available Devices", storage: NameStorage())));
                                  //go to profile page TODO: finish profile page
                                  break;
                                  case 'director':
                                    addStringToSF('id', 'director');
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => directorSetUpInfo()), (Route<dynamic> route) => false);
                                    break;
                            }
                          }
                          },
                      ),
                      SizedBox(height: 30),
                      Text(_utils.translate('Please Read!'), style: TextStyle(fontSize: 20, decoration: TextDecoration.underline, color: Colors.red)),
                      SizedBox(height: 10),
                      Card(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Text(_utils.translate('Director: '), style: TextStyle(color: Colors.black)),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.all(5),
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(_utils.translate("Only choose this if you are the organizer of an SRO, hospital, or care center. This identity is strictly for identities who oversees managers."), style: TextStyle(color: Colors.black54),),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Text(_utils.translate('Manager: '), style: TextStyle(color: Colors.black)),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.all(5),
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(_utils.translate("Only choose this if you are the manager of an SRO, hospital, or care center. This identity is strictly for identities who manage the tenants or patients"), style: TextStyle(color: Colors.black54),),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Card(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Text(_utils.translate('Resident: '), style: TextStyle(color: Colors.black)),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.all(5),
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(_utils.translate('Only choose this if you are a tenant of an SRO or a patient at a care center or a hospital.'), style: TextStyle(color: Colors.black54)),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
              ),
    );
  }
}
