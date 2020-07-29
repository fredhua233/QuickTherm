import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import '../../Utils/UserInfo.dart';
import '../../main.dart';
import '../Director/Director.dart';
import '../ConnectingDevicesPage.dart';
import 'ChooseIdentityPage.dart';
import 'package:quicktherm/Utils/Utils.dart'; //
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

///FIXME: Change the format of some fields
class directorSetUpInfo extends StatefulWidget {
  @override
  _directorSetUpInfoState createState() => _directorSetUpInfoState();
}

class _directorSetUpInfoState extends State<directorSetUpInfo> {
  final _formKey = new GlobalKey<FormState>();
  UserInfo _user = new UserInfo();
  Map<String, dynamic> _directorInfo = new Map<String, dynamic>();
  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Utils.translate('Fill out your information')),
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
                                hintText: Utils.translate('Ex. CCDC'),
                                labelText: Utils.translate('Organization Name')
                            ),
                            validator: (value) {
                              if (value.isEmpty){
                                return Utils.translate("Please enter your Organization name");
                              }
                              return null;
                            },
                            onSaved: (val) => setState((){
                              UserInfo.name = val;
                              _directorInfo['Organization'] = val;
                            })
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                                icon: Icon(Icons.phone),
                                hintText: Utils.translate('Ex. 123-456-7890'),
                                labelText: Utils.translate('Contact')
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value){
                              if(value.isEmpty || value.length != 12 || !value.contains('-')){
                                return Utils.translate('Please enter in correct format: xxx-xxx-xxxx');
                              }
                              return null;
                            },
                            onSaved: (val) => setState(() {
                              UserInfo.phoneNumber = val;
                              _directorInfo['Contacts'] = val;
                            })
                        ),
                        Text(Utils.translate("Desired unit of temperature")),
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
                              _user.directorSave(_directorInfo);
                              Navigator.pushReplacement(context, MaterialPageRoute(
                                  builder: (context) => Director(managers: UserInfo().fireStore.collection("/Organizations/${_directorInfo['Organization']}/Managers"),)));
                            }
                          },
                          child: Text(Utils.translate('Save')),
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