import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'StartUp/SetUpInfoPage.dart';
import '../Utils/UserInfo.dart';
import 'package:flutter/cupertino.dart' as cup;
import '../Utils/Utils.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _formKey = new GlobalKey<FormState>();
  UserInfo _user = new UserInfo.defined();
  Map<String, dynamic> _userInfo;
  DocumentReference _log;
  bool _edit = false;
  var _arrAddress = new List(4);

  @override
  void initState() {
    super.initState();
    getPathDataAndOthers();
  }

  cup.Color _primaryTag() {
    if (_userInfo != null) {
      String ptag = _userInfo["Primary Tag"];
      if (ptag == Colors.black.toString()) {
        return Colors.black;
      } else if (ptag == Colors.black45.toString()) {
        return Colors.black45;
      } else if (ptag == Colors.white.toString()) {
        return Colors.white;
      }
    }
    return Colors.white;
  }

  cup.Color _secondaryTag(String tag) {
    return tag != null && tag != "" && tag != " " && tag != "N/A" && (double.parse(tag) ?? 0) > 37.5 ? Colors.red :
    tag != null && tag != "" && tag != " " && tag != "N/A" && (double.parse(tag) ?? 36) < 35.0 ? Colors.blue :
    tag != null && tag != "" && tag != " " && tag != "N/A" && (double.parse(tag) ?? 90) < 37.5 && (double.parse(tag) ?? 0) > 35.0 ? Colors.green : Colors.white;
  }

  Widget _tag(cup.Color c) {
    return Container(
        width: 50,
        height: 20,
        decoration: BoxDecoration(
            color: c,
            border: Border.all(
                color: Colors.black,
                width: 2,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(5)));
  }

  Future<Map<String, dynamic>> getPathDataAndOthers() async {
    _log = _user.log;
    DocumentSnapshot _userInfoSS = await _log.get();
    _userInfo = _userInfoSS.data;
    _arrAddress = _userInfo['Address'].split(', ');
    return _userInfoSS.data;
  }

  Widget profileView(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getPathDataAndOthers(),
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
                            Text(_userInfo['Unit Name'],  style: TextStyle(fontSize: 40)),
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
                          Text((_userInfo['Temperature'][_userInfo['Last Measured']].toString().substring(0,5) + String.fromCharCode(0x00B0) + 'C' ),
                              style: _userInfo['Temperature'][_userInfo['Last Measured']] < 35 ? TextStyle(fontSize: 40, color: Colors.blue) :
                              _userInfo['Temperature'][_userInfo['Last Measured']] > 37.5 ? TextStyle(fontSize: 40, color: Colors.red) :
                              TextStyle(fontSize: 40, color: Colors.green)),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _userInfo['Health Message'],
                  decoration: InputDecoration(
                    labelText: 'Your current predicted condition',
                  ),
                  enabled: false,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _userInfo['Primary Tag'] == 'Color(0xff000000)' ? Column(children: [Text('Ill, seek medical help immediately')]) :
                      _userInfo['Primary Tag'] == 'Color(0x73000000)' ? Column(children: [Text('Potentially sick or recovering, Medical attention suggested')]) :
                      Column(children: [Text('Healthy, Saty safe!')])
                    ),
                    _tag(_primaryTag())
                  ],
                ),
                Divider(
                  color: Colors.blue[200],
                  height: 20,
                  thickness: 3,
                  indent: 0,
                  endIndent: 0,
                ),
                Row(
                  children: [
                    Expanded(
                        child: _userInfo['Secondary Tag'].substring(29, 46) == 'Color(0xfff44336)' ? Column(children: [Text('High Temperature, Potentially Fever or COVID-19')]) :
                        _userInfo['Secondary Tag'].substring(29, 46) == 'Color(0xff2196f3)' ? Column(children: [Text('Low Temperature, Potentially hypothermia')]) :
                        Column(children: [Text('Normal Temperature, Keep it up!')])
                    ),
                    _tag(_secondaryTag(_userInfo['Temperature'][_userInfo['Last Measured']].toString())),

                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _userInfo['Prior Medical Condition'] == false ? 'None' : _userInfo['Prior Medical Condition'],
                  decoration: InputDecoration(
                    labelText: 'Pre-existing health conditions',
                    hintText:'Please briefly describe your conditions',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  enabled: _edit,
                  onChanged: (val) => setState(() {
                    val == ' ' || val == '' ? _userInfo['Prior Medical Condition'] = false : _userInfo['Prior Medical Condtion'] = val;
                  }) ,
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
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => setState((){
                    String temp = val.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
                    String tempYr = temp.substring(0, 4);
                    String tempMo = temp.substring(5, 6) == '0' ? temp.substring(6, 7) : temp.substring(5, 7);
                    String tempDa = temp.substring(8, 9) == '0' ? temp.substring(9, 10) : temp.substring(8, 10);
                    _userInfo['Date of Birth'] = DateTime(int.parse(tempYr), int.parse(tempMo), int.parse(tempDa)).toString().substring(0, 10);
                    _userInfo['Age'] =  (DateTime.now().difference(DateTime.parse(_userInfo['Date of Birth'])).inDays/365).floor();
                  }),
                ),
                TextFormField(
                  initialValue: (DateTime.now().difference(DateTime.parse(_userInfo['Date of Birth'])).inDays/365).floor().toString(),
                  decoration: InputDecoration(
                    labelText: 'Age',
                  ),
                  enabled: false,
                ),
///FiXME: the _userInfo['Sex'} jsut does not change, tried radio list tiles and raisedbutton, even disabled saving current state of the form, using textformfield for now
//                Row(
//                  children: [
//                    Expanded(
//                      child: Text('My sex is ${_userInfo['Sex']}'),
//                    ),
//                    Expanded(
//                      child: RaisedButton(
//                        child: Text('Change your sex', style: TextStyle(fontSize: 20)),
//                        onPressed: _edit ?  () => _userInfo['Sex'] == 'Male' ? setState(() => _userInfo['Sex'] = 'Female') : setState(() => _userInfo['Sex'] = 'Male') : null
//
//                      ),
//                    )
//                  ],
//                ),
///FIXME: The TextFormField's initial value also fails to pass through the validator, and commented should be work but... it does not unfortunately
                TextFormField(
                  initialValue: _userInfo['Sex'],
                  decoration: InputDecoration(
                      hintText: 'Ex. Male/Female',
                      labelText: 'Sex'
                  ),
                  enabled: _edit,
                  autovalidate: true,
                  validator: (value) {
                    if (value.isEmpty /*|| value != 'Male' || value != 'Female' */){
                      return "Please enter either 'Male' or 'Female'";
                    }
                    return null;
                  },
                  onSaved: (val) => setState((){
                    _userInfo['Sex'] = val;
                  }),
                ),
                TextFormField(
                    initialValue: _arrAddress[0],
                    decoration: InputDecoration(
                        icon: Icon(Icons.home),
                        hintText: 'Ex. 1 Main st.',
                        labelText: 'Your address in ${_userInfo['Organization']}'
                    ),
                    enabled: _edit,
                    validator: (value){
                      if(value.isEmpty){
                        return 'Please enter your street address';
                      }
                      return null;
                    },
                    onSaved: (val) => setState((){
                      _arrAddress[0] = val;
                      _userInfo['Address'] = _arrAddress[0] + ', ' + _arrAddress[1] + ', ' + _arrAddress[2] + ', ' + _arrAddress[3];
                    })
                ),
                TextFormField(
                    initialValue: _arrAddress[1],
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
                    onSaved: (val) => setState((){
                      _arrAddress[1] = val;
                      _userInfo['Address'] = _arrAddress[0] + ', ' + _arrAddress[1] + ', ' + _arrAddress[2] + ', ' + _arrAddress[3];
                    })
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          initialValue: _arrAddress[2],
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
                          onSaved: (val) => setState(() {
                            _arrAddress[2] = val;
                            _userInfo['Address'] = _arrAddress[0] + ', ' + _arrAddress[1] + ', ' + _arrAddress[2] + ', ' + _arrAddress[3];
                          })
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                          initialValue: _arrAddress[3],
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
                          onSaved: (val) => setState(() {
                            _arrAddress[3] = val;
                            _userInfo['Address'] = _arrAddress[0] + ', ' + _arrAddress[1] + ', ' + _arrAddress[2] + ', ' + _arrAddress[3];
                          })
                      ),
                    ),
                    TextFormField(
                        initialValue: _userInfo['Manager Name'],
                        decoration: InputDecoration(
                            hintText: 'Ex. Jane Doe',
                            labelText: "Manager's Name"
                        ),
                        enabled: _edit,
                        validator: (value){
                          if(value.isEmpty){
                            return "Please enter your Manager's Name";
                          }
                          return null;
                        },
                        onSaved: (val) => setState((){
                          _userInfo['Manager Name'] = val;
                        })
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit my info',
            onPressed: () {
              setState(() {
                if(_edit == true){
                  final form = _formKey.currentState;
                  form.save();
                  _log.updateData(_userInfo);
                  _edit = _edit;
                }
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
