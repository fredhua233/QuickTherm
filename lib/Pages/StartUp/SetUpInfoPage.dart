import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../Utils/UserInfo.dart';
import '../../main.dart';
import '../ConnectingDevicesPage.dart';
import 'ChooseIdentityPage.dart';
import 'package:quicktherm/Utils/Utils.dart'; //
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//FIXME: Change the format of some fields Set up the desired unit of temperature
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
  bool changed = false;
  bool _selectedAM = false;
  bool _selectedPM = false;
  bool _selectedNOON = false;
//  Map<String, dynamic> info;
  TimeOfDay _remindAM, _remindNOON, _remindPM;
  TimeOfDay _time = TimeOfDay.now();
  List<bool> isSelected = [true, false];
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
        Utils.translate('Time to measure your temperature!'),
        Utils.translate('Be sure to open Quick Temp and update your temperature!'),
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
        Utils.translate('Time to measure your temperature!'),
        Utils.translate('Be sure to open Quick Temp and update your temperature!'),
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
        Utils.translate('Time to measure your temperature!'),
        Utils.translate('Be sure to open Quick Temp and update your temperature!'),
        timeAfternoon,
        platformChannelSpecificsA);
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Reminder"),
          content: Text("Reminder: " + payload),
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
                              hintText: Utils.translate('Ex. John Doe'),
                              labelText: Utils.translate('Name')
                          ),
                          validator: (value) {
                            if (value.isEmpty || !value.contains(' ')){
                              return Utils.translate("Please enter in correct format: 'first last'");
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => UserInfo.name = val)
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
                          onSaved: (val) => setState(() => UserInfo.phoneNumber = val)
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              icon: Icon(Icons.calendar_today),
                              hintText: Utils.translate('Ex. YYYY-MM-DD'),
                              labelText: Utils.translate('Date of Birth')
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value){
                            if(value.isEmpty || !value.contains('-')){
                              return Utils.translate('Please enter in correct format: YYYY-MM-DD');
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
                          title: Text(Utils.translate('Male')),
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
                          title: Text(Utils.translate('Female')),
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
                              hintText: Utils.translate('Ex. CCDC'),
                              labelText: Utils.translate('Your Organization')
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return Utils.translate('Please enter the organization that you belong to');
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() {
                            UserInfo.organization = val;
                            changed = true;
                          })
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              icon: Icon(Icons.home),
                              hintText: Utils.translate('Ex. 1 Main st.'),
                              labelText: changed ? Utils.translate('Your address in') + UserInfo.organization + Utils.translate(':') : Utils.translate('Your address')
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return Utils.translate('Please enter your address in your organization');
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => UserInfo.address = val)
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              hintText: Utils.translate('Ex. San Francisco'),
                              labelText: Utils.translate('City')
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return Utils.translate('Please enter your city');
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
                                    hintText: Utils.translate('Ex. CA'),
                                    labelText: Utils.translate('State')
                                ),
                                validator: (value){
                                  if(value.isEmpty || value.length > 2){
                                    return Utils.translate('Please enter your state');
                                  }
                                  return null;
                                },
                                onSaved: (val) => setState(() => UserInfo.address += ', ' + val)
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: Utils.translate('Ex. 94105'),
                                    labelText: Utils.translate('Zip code')
                                ),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter.digitsOnly
                                ],
                                validator: (value){
                                  if(value.isEmpty || value.length != 5){
                                    return Utils.translate('Please enter your zip code');
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
                              hintText: Utils.translate('Ex. 100'),
                              labelText: Utils.translate("Room Number")
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return Utils.translate("Please enter your room number");
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => UserInfo.unitName = 'Unit ' + val)
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              hintText: Utils.translate('Ex. Jane Doe'),
                              labelText: Utils.translate("Manager's Name")
                          ),
                          validator: (value){
                            if(value.isEmpty){
//                              || !value.contains(' ')
                              return Utils.translate("Please enter your Building manager's name");
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => UserInfo.managerName = val)
                      ),
                      CheckboxListTile(
                          title: Text(Utils.translate('I have pre-existing health condition')),
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
                          labelText: Utils.translate('Pre-existing health conditions'),
                          hintText:Utils.translate('Please briefly describe your conditions'),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        enabled: _preExist,
                        onChanged: (val) => setState(() {
                          UserInfo.healthHistory = val;
                        }) ,
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
                      Row(
                          children: [
                            Text(Utils.translate('Morning Remind time')),
                            IconButton(
                              icon: Icon(Icons.alarm),
                              onPressed: () {
                                selectTime(context, 1);
                              }
                            ),
                            Spacer(),
                            _selectedAM ? Text('${_remindAM.toString()}'.substring(10, 15), style: TextStyle(fontSize: 20)) : SizedBox()
                          ]
                      ),
                      Row(
                          children: [
                            Text(Utils.translate('Noon Remind time')),
                            IconButton(
                              icon: Icon(Icons.alarm),
                              onPressed: () => selectTime(context, 2),
                            ),
                            Spacer(),
                            _selectedNOON ? Text('${_remindNOON.toString()}'.substring(10, 15), style: TextStyle(fontSize: 20)) : SizedBox()
                          ]
                      ),
                      Row(
                          children: [
                            Text(Utils.translate('Evening Remind time')),
                            IconButton(
                              icon: Icon(Icons.alarm),
                              onPressed: () => selectTime(context, 3),
                            ),
                            Spacer(),
                            _selectedPM ? Text('${_remindPM.toString()}'.substring(10, 15), style: TextStyle(fontSize: 20)) : SizedBox()
                          ]
                      ),
                      Row(
                        children: [
                          Text(Utils.translate('Current health condition: ')),
                          DropdownButton<Illness>(
                            items: [
                              DropdownMenuItem<Illness>(
                                child: Text(Utils.translate('Healthy')),
                                value: Illness.healthy,
                              ),
                              DropdownMenuItem<Illness>(
                                child: Text(Utils.translate('Potential')),
                                value: Illness.potential,
                              ),
                              DropdownMenuItem<Illness>(
                                child: Text(Utils.translate('Severe')),
                                value: Illness.severe,
                              ),
                            ],
                            onChanged: (Illness value) {
                              setState(() {
                                _condition = value;
                                UserInfo.primaryTag = value == Illness.severe ? Colors.black.toString() : value == Illness.potential ? Colors.black45.toString() : Colors.white.toString(); // initialize firestore
                                UserInfo.secondaryTag = Colors.green.toString(); // initialize firestore
                                UserInfo.healthMsg = Utils.translate('N/A'); // initialize firestore
                                UserInfo.lastMeasured = Utils.translate('N/A');
                              });
                            },
                            hint: Text(Utils.translate('condition')),
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
                            }
                            form.save();
                            _user.individualSave();
                            _showDailyAtTime();
//                            SharedPreferences _pref = await SharedPreferences.getInstance();
                            Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context) => ConnectingDevicesPage(
                                    title: Utils.translate("Available Devices"),
                                    storage: NameStorage(),
                                    autoConnect: true)));
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