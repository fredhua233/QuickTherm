import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quicktherm/Pages/Manager/UnitsGrid.dart';
import 'package:quicktherm/Utils/UserInfo.dart';
import 'package:quicktherm/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
///FIXME: Change the format of some fields, add shared pref
class managerSetUpInfo extends StatefulWidget {
  @override
  _managerSetUpInfoState createState() => _managerSetUpInfoState();
}

class _managerSetUpInfoState extends State<managerSetUpInfo> {
  final _formKey = new GlobalKey<FormState>();
  Map<String, dynamic> _managerInfo = new Map<String, dynamic>();
  List<bool> isSelected = [true, false];
  UserInfo _user = new UserInfo();
  Utils _utils = new Utils();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_utils.translate('Fill out your information')),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Form(
              key: _formKey,
              autovalidate: true,
              child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget> [
                        TextFormField(
                            decoration: InputDecoration(
                                icon: Icon(Icons.person),
                                hintText: _utils.translate('Ex. John Doe'),
                                labelText: _utils.translate('Name')
                            ),
                            validator: (value) {
                              if (value.isEmpty || !value.contains(' ')){
                                return _utils.translate("Please enter in correct format: 'first last'");
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() {
                              _managerInfo['Name'] = val;
                            })
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                                icon: Icon(Icons.phone),
                                hintText: _utils.translate('Ex. 123-456-7890'),
                                labelText: _utils.translate('Contact')
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value){
                              if(value.isEmpty || value.length != 12 || !value.contains('-')){
                                return _utils.translate('Please enter in correct format: xxx-xxx-xxxx');
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() => _managerInfo['Contacts'] = val)
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                                hintText: _utils.translate('Ex. CCDC'),
                                labelText: _utils.translate('Your Organization')
                            ),
                            validator: (value){
                              if(value.isEmpty){
                                return _utils.translate('Please enter your organization name');
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() => _managerInfo['Organization'] = val)
                        ),
                      ///FIXME: add functionality for one or more building address
                        TextFormField(
                            decoration: InputDecoration(
                                icon: Icon(Icons.home),
                                hintText: _utils.translate('Ex. 1 Main st.'),
                                labelText: _utils.translate('Your Organization address:')
                            ),
                            validator: (value){
                              if(value.isEmpty){
                                return _utils.translate('Please enter your street address');
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() => _managerInfo['Address'] = val)
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                                hintText: _utils.translate('Ex. San Francisco'),
                                labelText: _utils.translate('City')
                            ),
                            validator: (value){
                              if(value.isEmpty){
                                return _utils.translate('Please enter your city');
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() => _managerInfo['Address'] += ', ' + val)
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: _utils.translate('Ex. CA'),
                                      labelText: _utils.translate('State')
                                  ),
                                  validator: (value){
                                    if(value.isEmpty || value.length > 2){
                                      return _utils.translate('Please enter your state');
                                    }
                                    return null;
                                  },
                                  onSaved: (val) => setState(() => _managerInfo['Address'] += ', ' + val)
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: _utils.translate('Ex. 94105'),
                                      labelText: _utils.translate('Zip code')
                                  ),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  validator: (value){
                                    if(value.isEmpty || value.length != 5){
                                      return _utils.translate('Please enter your zip code');
                                    }
                                    return null;
                                  },
                                  onSaved: (val) => setState(() => _managerInfo['Address'] += ' ' + val)
                              ),
                            )
                          ],
                        ),
                        Text(_utils.translate("Desired unit of temperature")),
                        ToggleButtons(
                          children: <Widget>[
                            Icon(MdiIcons.temperatureCelsius),
                            Icon(MdiIcons.temperatureFahrenheit),
                          ],
                          onPressed: (int index) async {
                            setState(() {
                              for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                                if (buttonIndex == index) {
                                  isSelected[buttonIndex] = true;
                                } else {
                                  isSelected[buttonIndex] = false;
                                }
                              }
                            });
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            if (index == 0) {
                              prefs.setString('Temp Unit', "C");
                              UNITPREF = "C";
                            } else {
                              prefs.setString('Temp Unit', "F");
                              UNITPREF = "F";
                            }
                          },
                          isSelected: isSelected,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            final form = _formKey.currentState;
                            if (form.validate()) {
                              form.save();
                              _managerInfo['Num of Res'] = 0;
                              _user.managerSave(_managerInfo);
                              Navigator.pushReplacement(context, MaterialPageRoute(
                                  builder: (context) => UnitsGrid(units: UserInfo().fireStore.collection("/Organizations/${_managerInfo['Organization']}/Managers/${_managerInfo['Name']}/Units"))));
                            }
                          },
                          child: Text(_utils.translate('Save')),
                        ),
                      ],
                    ),
                  )
              )
          ),
        )
    );
  }
}