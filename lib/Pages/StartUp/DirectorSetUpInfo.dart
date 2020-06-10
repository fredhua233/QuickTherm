import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import '../../Utils/UserInfo.dart';
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
                                hintText: 'Ex. CCDC',
                                labelText: 'Organization Name'
                            ),
                            validator: (value) {
                              if (value.isEmpty){
                                return "Please enter your Organization name";
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
                            onSaved: (val) => setState(() {
                              UserInfo.phoneNumber = val;
                              _directorInfo['Contacts'] = val;
                            })
                        ),
                        ///FIXME: show time picked on screen for remind times
                        RaisedButton(
                          onPressed: () async {
                            final form = _formKey.currentState;
                            if (form.validate()) {
                              form.save();
                              _user.directorSave(_directorInfo);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => LoadingPage()));
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