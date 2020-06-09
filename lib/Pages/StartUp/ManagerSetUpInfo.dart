import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicktherm/Pages/Manager/UnitsGrid.dart';
import '../ConnectingDevicesPage.dart';
import 'package:quicktherm/Utils/Utils.dart'; //
import 'package:quicktherm/Utils/UserInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

///FIXME: Change the format of some fields
class managerSetUpInfo extends StatefulWidget {
  @override
  _managerSetUpInfoState createState() => _managerSetUpInfoState();
}

class _managerSetUpInfoState extends State<managerSetUpInfo> {
  final _formKey = new GlobalKey<FormState>();
  Map<String, dynamic> _managerInfo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Fill out your information'),
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
                                hintText: 'Ex. John Doe',
                                labelText: 'Name'
                            ),
                            validator: (value) {
                              if (value.isEmpty || !value.contains(' ')){
                                return "Please enter in correct format: 'first last'";
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() => _managerInfo['Name'] = val)
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                                icon: Icon(Icons.phone),
                                hintText: 'Ex. 123-456-7890',
                                labelText: 'Contact'
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value){
                              if(value.isEmpty || value.length != 12 || !value.contains('-')){
                                return 'Please enter in correct format: xxx-xxx-xxxx';
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() => _managerInfo['Contacts'] = val)
                        ),
//                        TextFormField(
//                            decoration: InputDecoration(
//                                icon: Icon(Icons.calendar_today),
//                                hintText: 'Ex. YYYY-MM-DD',
//                                labelText: 'Date of Birth'
//                            ),
//                            keyboardType: TextInputType.datetime,
//                            validator: (value){
//                              if(value.isEmpty || !value.contains('-')){
//                                return 'Please enter in correct format: YYYY-MM-DD';
//                              }
//                              return null;
//                            },
//                            onSaved: (val) => setState(() {
//                              String temp = val.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
//                              String tempYr = temp.substring(0, 4);
//                              String tempMo = temp.substring(5, 6) == '0' ? temp.substring(6, 7) : temp.substring(5, 7);
//                              String tempDa = temp.substring(8, 9) == '0' ? temp.substring(9, 10) : temp.substring(8, 10);
//                              UserInfo.Bday = DateTime(int.parse(tempYr), int.parse(tempMo), int.parse(tempDa));
//                              UserInfo.age =  (DateTime.now().difference(UserInfo.Bday).inDays/365).floor();
//                            })
//                        ),
                      ///FIXME: add functionality for one or more building address
                        TextFormField(
                            decoration: InputDecoration(
                                icon: Icon(Icons.home),
                                hintText: 'Ex. 1 Main st.',
                                labelText: 'Your Organization address:'
                            ),
                            validator: (value){
                              if(value.isEmpty){
                                return 'Please enter your street address';
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() => _managerInfo['Address'] = val)
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                                hintText: 'Ex. San Francisco',
                                labelText: 'City'
                            ),
                            validator: (value){
                              if(value.isEmpty){
                                return 'Please enter your city';
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
                                      hintText: 'Ex. CA',
                                      labelText: 'State'
                                  ),
                                  validator: (value){
                                    if(value.isEmpty || value.length > 2){
                                      return 'Please enter your state';
                                    }
                                    return null;
                                  },
                                  onSaved: (val) => setState(() => _managerInfo['Address'] += ', ' + val)
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: 'Ex. 94105',
                                      labelText: 'Zip code'
                                  ),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  validator: (value){
                                    if(value.isEmpty || value.length != 5){
                                      return 'Please enter your zip code';
                                    }
                                    return null;
                                  },
                                  onSaved: (val) => setState(() => _managerInfo['Address'] += ' ' + val)
                              ),
                            )
                          ],
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                                hintText: 'Ex. CCDC/',
                                labelText: 'Organization of your SRO'
                            ),
                            validator: (value){
                              if(value.isEmpty){
                                return 'Please enter the organization of your SRO';
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() => _managerInfo['Organization'] = val)
                        ),
//                        TextFormField(
//                            decoration: InputDecoration(
//                                hintText: 'Ex. 40',
//                                labelText: "Total number of residents currently managing"
//                            ),
//                            keyboardType: TextInputType.phone,
//                            inputFormatters: <TextInputFormatter>[
//                              WhitelistingTextInputFormatter.digitsOnly
//                            ],
//                            validator: (value){
//                              if(value.isEmpty){
//                                return "Please enter how many residents you are managing";
//                              }
//                              return null;
//                            },
//                            onSaved: (val) => setState(() => _managerInfo['Num of Res']= val)
//                        ),
                        RaisedButton(
                          onPressed: () async {
                            final form = _formKey.currentState;
                            if (form.validate()) {
                              form.save();
                              _managerInfo['Num of Res'] = 0;
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => UnitsGrid(units: UserInfo().fireStore.collection("/Organizations/${_managerInfo['Organization']}/Managers/${_managerInfo['Name']}/Units"))));
                            }
                          },
                          child: Text('Save'),
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