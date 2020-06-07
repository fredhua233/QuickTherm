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
  double _lastTemp;
  Map<String, dynamic> _userInfo;
  DocumentReference _log;
  bool _edit = false;
  bool _gotFS;
  String _street, _city, _state, _zip, _address;

  @override
  void initState() {
    super.initState();
    getPathData();
    setState(() {
      _gotFS = true;
    });
  }

  Future<Map<String, dynamic>> getPathData() async {
    _log = _user.log;
    DocumentSnapshot _userInfoSS = await _log.get();
    _userInfo = _userInfoSS.data;
//    _address = _userInfo['Address'].replaceAll(new RegExp(r"\s+\b|\b\s"), "");
//    int countComma = 0;
//    for(int i = 0; i < _address.length; i++){
//      if(_address[i] == ','){
//        _street = _address.substring(countComma, i);
//        countComma = i;
//      }
//
//    }
    _lastTemp = 34.0;
    return _userInfoSS.data;
  }

  Widget profileView(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getPathData(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return LoadingPage();
        } else {
          return buildProfPage();
        }
      }
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Row(
                  children: [
                    Expanded(
                        child: Column(
                          children: [
                            Text('Unit Name: ',  style: TextStyle(fontSize: 20)),
                            SizedBox(height: 10),
                            Text(' ', style: TextStyle(fontSize: 20) ),
                            Text(_userInfo['Unit Name'] != null ? _userInfo['Unit Name'] : "N/A",  style: TextStyle(fontSize: 40)),
                          ],
                          mainAxisAlignment: MainAxisAlignment.start,
                        ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('Last Measured: ', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 10),
                          Text(_userInfo['Last Measured'].toString().substring(0, 10), style: TextStyle(fontSize: 20) ),
                          Text((_lastTemp.toString() + String.fromCharCode(0x00B0) + 'C' ),
                              style: _lastTemp < 35 ? TextStyle(fontSize: 40, color: Colors.blue) :
                              _lastTemp > 37.5 ? TextStyle(fontSize: 40, color: Colors.red) :
                              TextStyle(fontSize: 40, color: Colors.green)),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _userInfo['Name'],
                  decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Ex. John Doe',
                      labelText: 'Name',
                  ),
                  enabled: _edit,
                  autovalidate: true,
                  validator: (value) {
                    if (value.isEmpty || !value.contains(' ')){
                      return "Please enter in correct format: 'first last'";
                    }
                    return null;
                  },
                  onSaved: (val) => setState((){
                    _userInfo['Name'] = val;
                  })
                ),
                TextFormField(
                  initialValue: _userInfo['Contacts'],
                    decoration: InputDecoration(
                        icon: Icon(Icons.phone),
                        hintText: 'Ex. 123-456-7890',
                        labelText: 'Contact'
                    ),
                    enabled: _edit,
                    keyboardType: TextInputType.phone,
                    validator: (value){
                      if(value.isEmpty || value.length != 12 || !value.contains('-')){
                        return 'Please enter in correct format: xxx-xxx-xxxx';
                      }
                      return null;
                    },
                    onSaved: (val) => setState(() => _userInfo['Contacts'] = val)
                ),
                TextFormField(
                  initialValue: _userInfo['Date of Birth'],
                  decoration: InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      hintText: 'Ex. MM-DD-YYYY',
                      labelText: 'Date of Birth'
                  ),
                  enabled: _edit,
                  autovalidate: true,
                  validator: (value){
                    if(value.isEmpty || !value.contains('-')){
                      return 'Please enter in correct format: MM-DD-YYYY';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.datetime,
                  onSaved: (val) => setState((){
                    String temp = val.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
                    String tempYr = temp.substring(6);
                    String tempMo = temp.substring(3, 4) == '0' ? temp.substring(4, 5) : temp.substring(3, 5);
                    String tempDa = temp.substring(0, 1) == '0' ? temp.substring(1, 2) : temp.substring(0, 2);
                    _userInfo['Date of Birth'] = DateTime(int.parse(tempYr), int.parse(tempMo), int.parse(tempDa));
                    _userInfo['Age'] =  (DateTime.now().difference(_userInfo['Date of Birth']).inDays/365).floor();
                  }),
                ),
                TextFormField(
                  initialValue: (DateTime.now().difference(DateTime.parse(_userInfo['Date of Birth'])).inDays/365).floor().toString(),
                  decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: (DateTime.now().difference(DateTime.parse(_userInfo['Date of Birth'])).inDays/365).floor().toString()
                  ),
                  enabled: false,
                ),
                TextFormField(
                  initialValue: _userInfo['Sex'] != null ? _userInfo['Sex'] : "N/A",
                  decoration: InputDecoration(
                      hintText: 'Ex. Male/Female',
                      labelText: 'Sex'
                  ),
                  keyboardType: TextInputType.text,
                  enabled: _edit,
                  autovalidate: true,
                  validator: (value) {
                    if (value.isEmpty || value != 'Male' || value != 'Female'){
                      return "Please enter either 'Male' or 'Female'";
                    }
                      return null;
                    },
                  onSaved: (val) => setState((){
                    _userInfo['Sex'] = val;
                  }),
                ),
                TextFormField(
                    decoration: InputDecoration(
                        icon: Icon(Icons.home),
                        hintText: 'Ex. 1 Main st.',
                        labelText: 'Your address in ${_userInfo['Organization']}: '
                    ),
                    enabled: _edit,
                    validator: (value){
                      if(value.isEmpty){
                        return 'Please enter your street address';
                      }
                      return null;
                    },
                    onSaved: (val) => setState(() => UserInfo.address = val)
                ),
                TextFormField(
                    decoration: InputDecoration(
                        hintText: 'Ex. San Francisco',
                        labelText: 'City'
                    ),
                    enabled: _edit,
                    validator: (value){
                      if(value.isEmpty){
                        return 'Please enter your city';
                      }
                      return null;
                    },
                    onSaved: (val) => setState(() => UserInfo.address += ', ' + val)
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Ex. CA',
                              labelText: 'State'
                          ),
                          enabled: _edit,
                          validator: (value){
                            if(value.isEmpty || value.length > 2){
                              return 'Please enter your state';
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => UserInfo.address += ', ' + val)
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Ex. 94105',
                              labelText: 'Zip code'
                          ),
                          keyboardType: TextInputType.phone,
                          enabled: _edit,
                          validator: (value){
                            if(value.isEmpty || value.length != 5){
                              return 'Please enter your zip code';
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => UserInfo.address += ' ' + val)
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(_userInfo['Health Message']),
                Text(_userInfo['Primary Tag']),
                Text(_userInfo['Secondary Tag']),
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
            tooltip: 'Edit my info',
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
