import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Utils/UserInfo.dart';
import '../ConnectingDevicesPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

///FIXME: Change the format of some fields
class setUpInfoPage extends StatefulWidget {
  @override
  _setUpInfoPageState createState() => _setUpInfoPageState();
}

class _setUpInfoPageState extends State<setUpInfoPage> {
  final _formKey = new GlobalKey<FormState>();
  final _user = UserInfo();
  String _groupValue;
  Illness _condition;
  bool _preExist = false;
  TimeOfDay _remindAM, _remindNOON, _remindPM, _picked;


  Future<void> selectTime(BuildContext context, TimeOfDay _timeOfDay) async {
    _timeOfDay = TimeOfDay.now();
    _picked = await showTimePicker(
        context: context,
        initialTime: _timeOfDay
    );
    setState(() {
      _timeOfDay = _picked;
    });
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
                          onSaved: (val) => setState(() => _user.name = val)
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              icon: Icon(Icons.phone),
                              hintText: 'Ex. 123-456-7890',
                              labelText: 'Phone Number'
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value){
                            if(value.isEmpty || value.length != 12 || !value.contains('-')){
                              return 'Please enter in correct format: xxx-xxx-xxxx';
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => _user.phoneNumber = val)
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              icon: Icon(Icons.calendar_today),
                              hintText: 'Ex. MM/DD/YYYY',
                              labelText: 'Date of Birth'
                          ),
                          validator: (value){
                            if(value.isEmpty || !value.contains('/')){
                              return 'Please enter in correct format: MM/DD/YYYY';
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() {
                            _user.DOB = val;
                          })
                      ),
                      RadioListTile(
                          title: const Text('Male'),
                          value: 'Male',
                          groupValue: _groupValue,
                          onChanged: (value) => {
                            setState(() {
                              _groupValue = value;
                              _user.sex = value;
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
                              _user.sex = value;
                            })
                          }
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              icon: Icon(Icons.home),
                              hintText: 'Ex. 1 Main st.',
                              labelText: 'Street Address'
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return 'Please enter your street address';
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => _user.address = val)
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
                          onSaved: (val) => setState(() => _user.address += ', ' + val)
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
                                onSaved: (val) => setState(() => _user.address += ', ' + val)
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
                                onSaved: (val) => setState(() => _user.address += ' ' + val)
                            ),
                          )
                        ],
                      ),
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
                          onSaved: (val) => setState(() => _user.roomNumber = val)
                      ),
                      TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Ex. CCDC',
                              labelText: 'Organization of your SRO'
                          ),
                          validator: (value){
                            if(value.isEmpty){
                              return 'Please enter the organization of your SRO';
                            }
                            return null;
                          },
                          onSaved: (val) => setState(() => _user.organization = val)
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
                          onSaved: (val) => setState(() => _user.managerName = val)
                      ),
                      CheckboxListTile(
                          title: const Text('I have pre-existing health condition'),
                          value: _preExist,
                          onChanged: (bool value) {
                            setState(() {
                              _preExist = value;
                              _user.priorHealth = value;
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
                        validator: (value) {
                          if(value.isEmpty){
                            return 'Please briefly describe your conditions';
                          }
                          return null;
                        },
                        onChanged: (val) => setState(() {
                          _user.healthHistory = val;
                        }) ,
                      ),
                      ///FIXME: show time picked on screen for remind times
                      Row(
                          children: [
                            Text('Morning Remind time'),
                            IconButton(
                              icon: Icon(Icons.alarm),
                              onPressed: () => selectTime(context, _remindAM),
                            )
                          ]
                      ),
                      Row(
                          children: [
                            Text('Noon Remind time'),
                            IconButton(
                              icon: Icon(Icons.alarm),
                              onPressed: () => selectTime(context, _remindNOON),
                            )
                          ]
                      ),
                      Row(
                          children: [
                            Text('Evening Remind time'),
                            IconButton(
                              icon: Icon(Icons.alarm),
                              onPressed: () => selectTime(context, _remindPM),
                            )
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
                                _condition= value;
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
                            form.save();
                            _user.save();
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => ConnectingDevicesPage(
                                    title: "Available Devices",
                                    storage: NameStorage(),
                                    autoConnect: true)));
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