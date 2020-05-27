import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quicktherm/Utils/UserInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/Utils.dart';
import 'ConnectingDevicesPage.dart';

//Critical voltage 3V, threshold 3.3V
//Steinhart constants A: 0.2501292874e-3, B: 3.847945539e-4, c: -5.719579276e-7
// T for discrete, C for constant monitor, S for stop constant monitoring

// TODO: Push data to firebase, fix navigator, find bugs
// FIXME: Maybe take temperature for a minute( or some time) and get its average
/**
 * The current state of measurement, constant or discreet
 */
enum _State { constant, discreet }

enum _Therm { started, stopped }

class TempMonitorPage extends StatefulWidget {
  BluetoothDevice connectDevice;
  List<BluetoothService> services;

  TempMonitorPage(this.connectDevice, this.services);

  @override
  State<StatefulWidget> createState() {
    return TempMonitorPageState(connectDevice, services);
  }
}

class TempMonitorPageState extends State<TempMonitorPage> {
  BluetoothDevice connectDevice;
  List<BluetoothService> services;

  TempMonitorPageState(this.connectDevice, this.services);

  SharedPreferences _pref;
  Utils _utils = new Utils();
  UserInfo _user = new UserInfo();
  var _monitorState = _State.discreet;
  var _constantMode = _Therm.stopped;
  bool save = true;

  String msg = "";
  String heading = "Your Temperature";
  String _time = "";
  String _healthMsg = "";

  Color _primaryTag = Colors.white;
  Color _secondaryTag = Colors.white;

  DocumentReference _log;
  Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() async {
    _pref = await _utils.pref;
    String text, time, hmsg, ptag, stag = "";
    if (_pref.containsKey("LastTemp")) {
      text = _pref.containsKey("LastTemp")
          ? _pref.getDouble("LastTemp").toString() +
              String.fromCharCode(0x00B0) +
              "C"
          : "Take Temperature";
    }
    if (_pref.containsKey("LastMeasTime")) {
      time = _pref.containsKey("LastMeasTime")
          ? _pref.getString("LastMeasTime").substring(0, 19)
          : "";
    }
    if (_pref.containsKey("HealthMsg")) {
      hmsg = _pref.getString("HealthMsg") ?? "";
    }
    ptag = _pref.getString("1stTag") ?? "";
    stag = _pref.getString("2ndTag") ?? "";
    setState(() {
      msg = text;
      _time = time;
      _healthMsg = hmsg;
      if (ptag == Colors.black.toString()) {
        _primaryTag = Colors.black;
      } else if (ptag == Colors.black45.toString()) {
        _primaryTag = Colors.black45;
      } else if (ptag == Colors.white.toString()) {
        _primaryTag = Colors.white;
      }
      if (stag == Colors.red.toString()) {
        _secondaryTag = Colors.red;
      } else if (stag == Colors.green.toString()) {
        _secondaryTag = Colors.green;
      } else if (stag == Colors.blue.toString()) {
        _secondaryTag = Colors.blue;
      }
    });
    //FIXME: Change below
//    _log = _firestore.document("/Organizations/"+_user.organization+"/Buildings/"+_user.building+"/Units/"+_user.roomNumber+"/Individuals/"+_user.Name);
    _log = _user.log;
    DocumentSnapshot doc = await _log.get();
    _data = doc.data;
  }

  /**
   * Get a characteristic that I can read and write to
   */
  BluetoothCharacteristic _getCharacteristic() {
    BluetoothService service = null;
    BluetoothCharacteristic char = null;
    for (BluetoothService s in services) {
      if (s.uuid.toString().startsWith("0000ffe")) {
        service = s;
      }
    }
    if (service != null) {
      for (BluetoothCharacteristic c in service.characteristics) {
        CharacteristicProperties props = c.properties;
        if (props.read && (props.write || props.writeWithoutResponse)) {
          char = c;
        }
      }
    } else {
      _errDialog(
          "Service not found",
          "Needed service not found, disconnect and "
              "attempt again, or connect to another device.");
    }
    if (char != null) {
      return char;
    } else {
      _errDialog(
          "Suitable characteristic not found",
          "disconnect and "
              "attempt again, or connect to another device.");
      return null;
    }
  }

  /**
   * Template for error dialogs.
   */
  void _errDialog(String title, String msg) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*
  Handles the logic in for different mode of monitoring
   */
  Widget _button(_State s) {
    if (s == _State.discreet) {
      return Stack(children: <Widget>[
        Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
                onPressed: () async {
                  String TempString = "";
                  setState(() {
                    heading = "Your Temperature";
                  });
                  BluetoothCharacteristic characteristic = _getCharacteristic();
                  await characteristic.setNotifyValue(true);
                  await characteristic.write(utf8.encode("T"));
                  double Temp = 0;
                  int Vcc = 0;
                  await for (var value in characteristic.value) {
                    if (value.length != 0 && value != null) {
                      String reading = utf8.decode(value);
                      int semi = reading.indexOf(';');
                      TempString = reading.substring(2, semi);
                      Temp = double.parse(TempString);
                      Vcc = int.parse(reading.substring(semi + 5));
                      setState(() {
                        msg = TempString + String.fromCharCode(0x00B0) + "C";
                      });
                      break;
                    }
                  }
                  await characteristic.write(utf8.encode("S"));
                  _checkingForHealth(Temp, 1);
                  if (Vcc < 3300) {
                    _errDialog(
                        "Low Battery",
                        "Low battery, please charge your armband. "
                                "Current Battery level: " +
                            ((Vcc / 3700) * 100).toString() +
                            "%");
                  }
                },
                label: Text("Measure"),
                icon: new Icon(MdiIcons.thermometer)))
      ]);
    } else {
      return Stack(
        children: <Widget>[
          Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      String TempString = "";
                      setState(() {
                        heading = "Started";
                        _constantMode = _Therm.started;
                      });
                      BluetoothCharacteristic characteristic =
                          _getCharacteristic();
                      await characteristic.setNotifyValue(true);
                      await characteristic.write(utf8.encode("C"));
                      StreamSubscription sub;
                      sub = characteristic.value.listen((value) {
                        if (value.length > 0 && value != null) {
                          String reading = utf8.decode(value);
                          if (value.length > 10) {
                            double Temp = 0;
                            int Vcc = 0;
                            int semi = reading.indexOf(';');
                            TempString = reading.substring(2, semi);
                            Temp = double.parse(TempString);
                            Vcc = int.parse(reading.substring(semi + 5));
                            setState(() {
                              msg = TempString +
                                  String.fromCharCode(0x00B0) +
                                  "C";
                            });
                            _checkingForHealth(Temp, 0);
                            if (Vcc < 3300) {
                              _errDialog(
                                  "Low Battery",
                                  "Low battery, please charge your armband. "
                                          "Current Battery level: " +
                                      ((Vcc / 3700) * 100).toString() +
                                      "%");
                            }
                          }
                          if (reading == "Terminate") {
                            sub.cancel();
                          }
                        }
                      });
                    },
                    label: Text("Start"),
                    backgroundColor: Colors.green,
                  ))),
          Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  BluetoothCharacteristic characteristic = _getCharacteristic();
                  await characteristic.setNotifyValue(true);
                  await characteristic.write(utf8.encode("S"));
                  Future.delayed(Duration(seconds: 1)).then((value) {
                    setState(() {
                      heading = "Stopped";
                      _constantMode = _Therm.stopped;
                    });
                  });
                },
                label: Text("Stop"),
                backgroundColor: Colors.red,
              )),
        ],
      );
    }
  }

  /**
   * Handles giving health status warnings
   */
  void _checkingForHealth(double temp, int m) {
    bool set = false;
    if (temp < 20 || temp > 45) {
      _errDialog("Try Again!",
          "Bad measurement, please close this dialog, adjust placement of armband and try to measure your temperature again.");
    } else {
      if (temp < 35) {
        if (m > 0) {
          _errDialog("Hypothermia!", "You potentially have hypothermia!");
        }
        setState(() {
          _primaryTag = Colors.black;
          _secondaryTag = Colors.blue;
          _healthMsg = "Ill, potential hypothermia ";
        });
        set = true;
      } else if (temp > 37.5) {
        if (m > 0) {
          _errDialog("Fever!", "You potentially have fever!");
        }
        setState(() {
          _primaryTag = Colors.black;
          _secondaryTag = Colors.red;
          _healthMsg = "Ill, potential fever";
        });
        set = true;
      }
      if (!set) {
        setState(() {
          int elapsed = 3;
          DateTime today = new DateTime.now();
          if (_pref.containsKey("LastIll")) {
            elapsed = today
                .difference(DateTime.parse(_pref.getString("LastIll")))
                .inDays;
          }
          _primaryTag = elapsed >= 3 ? Colors.white : Colors.black45;
          _healthMsg = elapsed >= 3
              ? "Healthy, normal temperature"
              : "Potential illness/recovery, \n normal temperature";
          _secondaryTag = Colors.green;
        });
      }
      _pref.setString("HealthMsg", _healthMsg);
      _pref.setString("1stTag", _primaryTag.toString());
      _pref.setString("2ndTag", _secondaryTag.toString());
      print(_primaryTag.toString());
      _saveData(temp);
    }
  }

  /**
   * Handles Saving data
   */
  void _saveData(double temp) async {
    DateTime now = new DateTime.now();
    _pref.setDouble("LastTemp", temp);
    _pref.setString("LastMeasTime", now.toString());
    if (temp > 37.5 || temp < 35) {
      _pref.setString("LastIll", new DateTime.now().toString());
    }
    setState(() {
      _time = _pref.getString("LastMeasTime").substring(0, 19);
    });
    _pushData(temp, now).then((success) {
      if (!success) {
        _errDialog("Pushing data to cloud failed!",
            "Please check your wifi connection and try again.");
      }
    });
  }

  /**
   * Dialog for save data
   */
  _deleteDataDialog(double temp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Your Temperature: " +
              temp.toString() +
              String.fromCharCode(0x00B0) +
              "C"),
          content: new Text(
              "Delete this measurement in cloud? If you think there is an error in this measurement, please press Yes and measure again."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                setState(() {
                  save = false;
                });
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                setState(() {
                  save = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*
  Handles delete data
  */
  _deleteData() {
    if (_pref.containsKey("LastTemp")) {
      double temp = _pref.getDouble("LastTemp");
      _deleteDataDialog(temp);
      if (!save) {
        _pref.remove("LastTemp");
        _pref.remove("LastMeasTime");
      }
    }
  }

  /*
  Handles pushing data to cloud
   */
  Future<bool> _pushData(double temp, DateTime now) async {
    Map<String, dynamic> temps = _data["Temperature"];
    temps.addAll({now.toString(): temp.toString()});
    _log.updateData({"Temperature": temps});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
//          FIXME: Change line below
          leading: _utils.getMenu(context, "resident"),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.timeline,
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case "Change Mode":
                        if (_monitorState == _State.constant) {
                          setState(() {
                            _monitorState = _State.discreet;
                            heading = "Your Temperature";
                          });
                        } else {
                          setState(() {
                            _monitorState = _State.constant;
                            heading = "";
                          });
                        }
                        break;
                      case "Disconnect":
                        connectDevice.disconnect();
                        print("pressed disconnect");
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConnectingDevicesPage(
                                    title: "Available Devices",
                                    storage: NameStorage(),
                                    autoConnect: false)));
                        break;
                      case "Delete":
                        _deleteData();
                    }
                  },
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            value: "Change Mode",
                            child: Text(
                              "Change Mode of Monitoring",
                            )),
                        PopupMenuItem(
                            value: "Disconnect",
                            child: Text(
                              "Disconnect from Current Device",
                            )),
                        PopupMenuItem(
                            value: "Delete", child: Text("Delete Last Taking"))
                      ]),
            ),
          ],
          title: Text("Thermometer"),
        ),
        body: Stack(children: <Widget>[
          Align(
              alignment: FractionalOffset(0.5, 0.1),
              child: heading != null
                  ? Text(heading,
                      style: new TextStyle(fontSize: 25, color: Colors.black))
                  : new Text(" ",
                      style: new TextStyle(fontSize: 25, color: Colors.black))),
          Align(
              alignment: FractionalOffset(0.5, 0.25),
              child: msg != null
                  ? Text(msg,
                      style: new TextStyle(fontSize: 50, color: _secondaryTag))
                  : new Text(" ",
                      style: new TextStyle(fontSize: 40, color: Colors.black))),
          Align(
              alignment: FractionalOffset(0.15, 0.45),
              child: Text("Time taken: ",
                  style: new TextStyle(fontSize: 18, color: Colors.black))),
          Align(
              alignment: FractionalOffset(0.175, 0.5),
              child: _time != null
                  ? Text(_time,
                      style: new TextStyle(fontSize: 15, color: Colors.black))
                  : new Text(" ",
                      style: new TextStyle(fontSize: 15, color: Colors.black))),
          Align(
              alignment: FractionalOffset(0.175, 0.6),
              child: Text("Health Condition: ",
                  style: new TextStyle(fontSize: 18, color: Colors.black))),
          Align(
              alignment: FractionalOffset(0.15, 0.675),
              child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: _primaryTag,
                      border: Border.all(
                          color: Colors.black,
                          width: 2,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(10)))),
          Align(
              alignment: FractionalOffset(0.35, 0.675),
              child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: _secondaryTag,
                      border: Border.all(
                          color: Colors.black,
                          width: 2,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(10)))),
          Align(
              alignment: FractionalOffset(0.175, 0.75),
              child: _healthMsg != null
                  ? Text("-" + _healthMsg,
                      style: new TextStyle(fontSize: 15, color: Colors.black))
                  : new Text(" ",
                      style: new TextStyle(fontSize: 15, color: Colors.black))),
        ]),
        floatingActionButton: _button(_monitorState),
        backgroundColor:
            _monitorState == _State.constant && _constantMode == _Therm.started
                ? Colors.lightGreen[200]
                : _monitorState == _State.constant &&
                        _constantMode == _Therm.stopped
                    ? Colors.red[200]
                    : Colors.white);
  }
}
