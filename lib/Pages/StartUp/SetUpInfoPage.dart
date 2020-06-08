import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Utils/UserInfo.dart';
import '../ConnectingDevicesPage.dart';
import 'ChooseIdentityPage.dart';
import 'package:quicktherm/Utils/Utils.dart'; //
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

///FIXME: Change the format of some fields
class setUpInfoPage extends StatefulWidget {
  @override
  _setUpInfoPageState createState() => _setUpInfoPageState();
}

class _setUpInfoPageState extends State<setUpInfoPage> {
  final _formKey = new GlobalKey<FormState>();
  UserInfo _user = new UserInfo();
  String _groupValue;
  Illness _condition;
  bool _preExist = false;
  bool _selectedAM = false;
  bool _selectedPM = false;
  bool _selectedNOON = false;
//  bool _sameAddress = false;
  TimeOfDay _remindAM, _remindNOON, _remindPM;
  TimeOfDay _time = TimeOfDay.now();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // If you have skipped STEP 3 then change app_icon to @mipmap/ic_launcher
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (payload) { return onSelectNotification(payload);} );
  }

  Future<void> _showDailyAtTime() async {
    var timeMorning = Time(_remindAM.hour, _remindAM.minute, 0);
    var timeNoon = Time(_remindNOON.hour, _remindNOON.minute, 0);
    var timeAfternoon = Time(_remindPM.hour, _remindPM.minute, 0);
    var androidPlatformChannelSpecificsM = AndroidNotificationDetails(
        '0',
        'Morning',
        'Morning remind time');
    var iOSPlatformChannelSpecificsM = IOSNotificationDetails();
    var platformChannelSpecificsM = NotificationDetails(
        androidPlatformChannelSpecificsM, iOSPlatformChannelSpecificsM);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'Time to measure your temperature!',
        'Be sure to open Quick Temp and update your temperature!',
        timeMorning,
        platformChannelSpecificsM);
    var androidPlatformChannelSpecificsN = AndroidNotificationDetails(
        '1',
        'Noon',
        'Noon remind time');
    var iOSPlatformChannelSpecificsN = IOSNotificationDetails();
    var platformChannelSpecificsN = NotificationDetails(
        androidPlatformChannelSpecificsN, iOSPlatformChannelSpecificsN);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        1,
        'Time to measure your temperature!',
        'Be sure to open Quick Temp and update your temperature!',
        timeNoon,
        platformChannelSpecificsN);
    var androidPlatformChannelSpecificsA = AndroidNotificationDetails(
        '2',
        'Afternoon',
        'Afternoon remind time');
    var iOSPlatformChannelSpecificsA = IOSNotificationDetails();
    var platformChannelSpecificsA = NotificationDetails(
        androidPlatformChannelSpecificsA, iOSPlatformChannelSpecificsA);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        2,
        'Time to measure your temperature!',
        'Be sure to open Quick Temp and update your temperature!',
        timeAfternoon,
        platformChannelSpecificsA);
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  Future<void> selectTime(BuildContext context, int i) async {
    final _picked = await showTimePicker(
        context: context,
        initialTime: _time
    );
    if (_picked != null && _picked != _time) {
      if (i == 1) {
        setState(() {
          _remindAM = _picked;
          _selectedAM = true;
        });
      } else if (i == 2) {
        setState(() {
          _remindNOON = _picked;
          _selectedNOON = true;
        });
      } else {
        setState(() {
          _remindPM = _picked;
          _selectedPM = true;
        });
      }
    }
  }
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
                          onSaved: (val) => setState(() => UserInfo.name = val)
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
                          onSaved: (val) => setState(() => UserInfo.phoneNumber = val)
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              icon: Icon(Icons.calendar_today),
                              hintText: 'Ex. YYYY-MM-DD',
                              labelText: 'Date of Birth'
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (value){
                            if(value.isEmpty || !value.contains('-')){
                              return 'Please enter in correct format: YYYY-MM-DD';
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() {
                            String temp = val.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
                            String tempYr = temp.substring(0, 4);
                            String tempMo = temp.substring(5, 6) == '0' ? temp.substring(6, 7) : temp.substring(5, 7);
                            String tempDa = temp.substring(8, 9) == '0' ? temp.substring(9, 10) : temp.substring(8, 10);
                            UserInfo.Bday = DateTime(int.parse(tempYr), int.parse(tempMo), int.parse(tempDa));
                            UserInfo.age =  (DateTime.now().difference(UserInfo.Bday).inDays/365).floor();
                          })
                      ),
                      RadioListTile(
                          title: const Text('Male'),
                          value: 'Male',
                          groupValue: _groupValue,
                          onChanged: (value) => {
                            setState(() {
                              _groupValue = value;
                              UserInfo.sex = value;
                            })
                          }
                      ),
                      RadioListTile(
                          title: const Text('Female'),
                          value: 'Female',
                          groupValue: _groupValue,
                          onChanged: (value) => {
                            setState(() {
                              _groupValue = value;
                              UserInfo.sex = value;
                            })
                          }
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Ex. CCDC',
                              labelText: 'Your Organization'
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return 'Please enter the organization that you belong to';
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => UserInfo.organization = val)
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              icon: Icon(Icons.home),
                              hintText: 'Ex. 1 Main st.',
                              labelText: 'Your address' + (UserInfo.organization != null ? 'in ${UserInfo.organization}:' : ' ')
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return 'Please enter your address in your organization';
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
                                inputFormatters: [
                                  WhitelistingTextInputFormatter.digitsOnly
                                ],
                                validator: (value){
                                  if(value.isEmpty || value.length != 5){
                                    return 'Please enter your zip code';
                                  }
                                  return null;
                                },
                                onSaved: (val) => setState(() => UserInfo.address += ' ' + val)
                            ),
                          )
                        ],
                      ),
//                      SizedBox(),
//                      Text('Your info in Organization'),
//                      SizedBox(),
//                      TextFormField(
//                          decoration: InputDecoration(
//                              hintText: 'Ex. 100',
//                              labelText: "Building info"
//                          ),
//                          validator: (value){
//                            if(value.isEmpty){
//                              return "Please enter your Building info";
//                            }
//                            return null;
//                          },
//                          onSaved: (val) => setState(() => UserInfo.roomNumber = val)
//                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Ex. 100',
                              labelText: "Room Number"
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          validator: (value){
                            if(value.isEmpty){
                              return "Please enter your room number";
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => UserInfo.roomNumber = val)
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Ex. Jane Doe',
                              labelText: "Manager's Name"
                          ),
                          validator: (value){
                            if(value.isEmpty || !value.contains(' ')){
                              return "Please enter your Building manager's name";
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => UserInfo.managerName = val)
                      ),
                      CheckboxListTile(
                          title: const Text('I have pre-existing health condition'),
                          value: _preExist,
                          onChanged: (bool value) {
                            setState(() {
                              _preExist = value;
                              UserInfo.priorHealth = value;
                            });
                          }
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Pre-existing health conditions',
                          hintText:'Please briefly describe your conditions',
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        enabled: _preExist,
                        onChanged: (val) => setState(() {
                          UserInfo.healthHistory = val;
                        }) ,
                      ),
                      ///FIXME: show time picked on screen for remind times
                      Row(
                          children: [
                            Text('Morning Remind time'),
                            IconButton(
                              icon: Icon(Icons.alarm),
                              onPressed: () {
                                selectTime(context, 1);
                              }
                            ),
                             _selectedAM ? Text('${_remindAM.toString()}'.substring(10, 15), style: TextStyle(fontSize: 20)) : SizedBox()
                          ]
                      ),
                      Row(
                          children: [
                            Text('Noon Remind time'),
                            IconButton(
                              icon: Icon(Icons.alarm),
                              onPressed: () => selectTime(context, 2),
                            ),
                            _selectedNOON ? Text('${_remindNOON.toString()}'.substring(10, 15), style: TextStyle(fontSize: 20)) : SizedBox()
                          ]
                      ),
                      Row(
                          children: [
                            Text('Evening Remind time'),
                            IconButton(
                              icon: Icon(Icons.alarm),
                              onPressed: () => selectTime(context, 3),
                            ),
                            _selectedPM ? Text('${_remindPM.toString()}'.substring(10, 15), style: TextStyle(fontSize: 20)) : SizedBox()
                          ]
                      ),
                      Row(
                        children: [
                          Text('Current health condition: '),
                          DropdownButton<Illness>(
                            items: [
                              DropdownMenuItem<Illness>(
                                child: Text('Healthy'),
                                value: Illness.healthy,
                              ),
                              DropdownMenuItem<Illness>(
                                child: Text('Potential'),
                                value: Illness.potential,
                              ),
                              DropdownMenuItem<Illness>(
                                child: Text('Severe'),
                                value: Illness.severe,
                              ),
                            ],
                            onChanged: (Illness value) {
                              setState(() {
                                _condition = value;
                                UserInfo.primaryTag = Colors.white.toString(); // initialize firestore
                                UserInfo.secondaryTag = Colors.green.toString(); // initialize firestore
                                UserInfo.healthMsg = 'N/A'; // initialize firestore
                                UserInfo.lastMeasured = 'N/A';
                              });
                            },
                            hint: Text('condition'),
                            value: _condition,
                          ),
                        ],
                      ),
                      RaisedButton(
                        onPressed: () async {
                          final form = _formKey.currentState;
                          if (form.validate()) {
                            if(!_preExist){
                              setState(() {
                                UserInfo.priorHealth = false;
                              });
                              form.save();
                              await _user.save();
                              await _showDailyAtTime();
                              SharedPreferences _pref = await SharedPreferences.getInstance();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => ConnectingDevicesPage(
                                      title: "Available Devices",
                                      storage: NameStorage(),
                                      autoConnect: true)));
                            }
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