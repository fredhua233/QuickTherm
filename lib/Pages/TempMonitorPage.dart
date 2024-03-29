import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quicktherm/Pages/HelpPage.dart';
import 'package:quicktherm/Utils/UserInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/Utils.dart';
import 'ConnectingDevicesPage.dart';
import 'HistoryPage.dart';

//Critical voltage 3V, threshold 3.3V
//Steinhart constants A: 0.2501292874e-3, B: 3.847945539e-4, c: -5.719579276e-7
// T for discrete, C for constant monitor, S for stop constant monitoring

// TODO:  find bugs,
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
  UserInfo _user = new UserInfo.defined();
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
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _initialize();
  }

  //initalizes all variable displaying data of the last measurement
  _initialize() async {
    // Sets up fire base
    _pref = await _utils.pref;
    String path = _pref.getString("path");
    _log = _user.fireStore.document(path);
    DocumentSnapshot doc = await _log.get();
    if (doc != null) {
      _data = doc.data;
    } else {
      _utils.errDialog("Unable to get data", "Incorrect path", context);
    }

    //Sets up shared persistence

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
    hmsg = _data.containsKey("Health Message") ? _data["Health Message"] : "";
    ptag = _data.containsKey("Primary Tag") ? _data["Primary Tag"] : "";
    stag = _data.containsKey("Secondary Tag") ? _data["Secondary Tag"] : "";
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
      _utils.errDialog(
          "Service not found",
          "Needed service not found, disconnect and "
              "attempt again, or connect to another device.",
          context);
    }
    if (char != null) {
      return char;
    } else {
      _utils.errDialog(
          "Suitable characteristic not found",
          "disconnect and "
              "attempt again, or connect to another device.",
          context);
      return null;
    }
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
                heroTag: "discreet measuring",
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
                  _checkingForHealth(Temp, 1, 1);
                  if (Vcc < 3300) {
                    _utils.errDialog(
                        "Low Battery",
                        "Low battery, please charge your armband. "
                                "Current Battery level: " +
                            ((Vcc / 3700) * 100).toString() +
                            "%",
                        context);
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
                    heroTag: "continuous measuring start",
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
//                      Map<String, dynamic> rec = new Map<String, dynamic>();
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
                            DateTime now = new DateTime.now();
                            _pref.setDouble("LastTemp", Temp);
                            _pref.setString("LastMeasTime", now.toString());
                            if (Temp > 37.5 || Temp < 35) {
                              _pref.setString("LastIll", now.toString());
                            }
                            setState(() {
                              _time = _pref
                                  .getString("LastMeasTime")
                                  .substring(0, 19);
                            });
//                            rec.addAll({now.toString(): Temp});
                            _saveData(Temp);
                            _checkingForHealth(Temp, 0, 0);
                            if (Vcc < 3300) {
                              _utils.errDialog(
                                  "Low Battery",
                                  "Low battery, please charge your armband.",
                                  context);
                            }
                          }
                          if (reading == "Terminate") {
//                            _pushDataMap(rec);
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
                heroTag: "continuous measuring stop",
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
  void _checkingForHealth(double temp, int m, int p) {
    bool set = false;
    if (temp < 15 || temp > 45) {
      _utils.errDialog(
          "Try Again!",
          "Bad measurement, please close this dialog, adjust placement of armband and try to measure your temperature again.",
          context);
    } else {
      if (temp < 35) {
        if (m > 0) {
          _utils.errDialog(
              "Hypothermia!", "You potentially have hypothermia!", context);
        }
        setState(() {
          _primaryTag = Colors.black;
          _secondaryTag = Colors.blue;
          _healthMsg = "Ill, potential hypothermia ";
        });
        set = true;
      } else if (temp > 37.5) {
        if (m > 0) {
          _utils.errDialog("Fever!", "You potentially have fever!", context);
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
      if (p > 0) {
        _saveData(temp);
      }
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
      _pref.setString("LastIll", now.toString());
    }
    setState(() {
      _time = _pref.getString("LastMeasTime").substring(0, 19);
    });
    _pushData(temp, now).then((success) {
      if (!success) {
        _utils.errDialog("Pushing data to cloud failed!",
            "Please check your wifi connection and try again.", context);
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
    Map<String, dynamic> temps = _data["Temperature"];
    List<String> date = temps.keys.toList();
    date.sort((a, b) => a.compareTo(b));
    if (_pref.containsKey("LastTemp")) {
      double temp = _pref.getDouble("LastTemp");
      _deleteDataDialog(temp);
      if (!save) {
        try {
          temps.remove(_pref.getString("LastMeasTime"));
          date.removeLast();
        } catch (e) {
          _utils.errDialog(
              "Unable to delete", "Last Data already deleted", context);
        }
      }
    }
    _log.updateData({"Temperature": temps,
                     "Last Measured" : date.last});
  }

  /*
  Handles pushing data to cloud
   */
  Future<bool> _pushData(double temp, DateTime now) async {
    var ltime = _pref.getString("LastMeasTime");
    Map<String, dynamic> temps = _data["Temperature"];
    temps.addAll({now.toString(): temp});
    await _log.updateData({
      "Temperature": temps,
      "Primary Tag": _primaryTag.toString(),
      "Secondary Tag": _secondaryTag.toString(),
      "Health Message": _healthMsg,
      "Last Measured" : ltime
    });
    _updateUnitStatus();
    return true;
  }

//  _pushDataMap(Map<String, dynamic> tempMap) async {
//    var ltime = _pref.getString("LastMeasTime");
//    if (!_data.containsKey("Primary Tag") &&
//        !_data.containsKey("Secondary Tag") &&
//        !_data.containsKey("Health Msg")) {
//      _data.addAll({
//        "Primary Tag": _primaryTag.toString(),
//        "Secondary Tag": _secondaryTag.toString(),
//        "Health Msg": _healthMsg,
//        "Last Measured Time" : ltime
//      });
//    }
//    Map<String, dynamic> temps = _data["Temperature"];
//    temps.addAll(tempMap);
//    await _log.updateData({
//      "Temperature": temps,
//      "Primary Tag": _primaryTag.toString(),
//      "Secondary Tag": _secondaryTag.toString(),
//      "Health Msg": _healthMsg,
//      "Last Measured Time" : ltime
//    });
//    _updateUnitStatus();
//  }

  //Updates unit status base on the health status of people living in the same unit as the individual
  _updateUnitStatus() async {
    await _user.fireStore.runTransaction((transaction) async {
      String unitStatus = "";
      bool potential = false;
      bool ill = false;
      bool healthy = false;
      QuerySnapshot individuals = await _user.mates.getDocuments();
      for (var doc in individuals.documents) {
        if (doc.data["Primary Tag"] == Colors.black.toString()) {
          ill = true;
        } else if (doc.data["Primary Tag"] == Colors.black45.toString()) {
          potential = true;
        } else if (doc.data["Primary Tag"] == Colors.white.toString()) {
          healthy = true;
        }
      }
      if (healthy && !potential && !ill) {
        unitStatus = "healthy";
      } else if (ill) {
        unitStatus = "ill";
      } else if (potential && !ill) {
        unitStatus = "potentially ill";
      } else {
        unitStatus = "unknown";
      }
      await transaction.update(_user.unit, {"Unit Status" : unitStatus});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
//          FIXME: Change line below
          leading: _utils.getMenu(context, "resident", "Temp Monitor Page"),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Hero(
                  tag: "history",
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HistoryPage()));
                    },
                    child: Icon(
                      Icons.timeline,
                    ),
                  ),
                )),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Hero(
                  tag: "Help",
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HelpPage()));
                    },
                    child: Icon(
                      Icons.help_outline,
                    ),
                  ),
                )),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Hero(
                    tag: "options",
                    child: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case "Change Mode":
                            if (_monitorState == _State.constant) {
                              BluetoothCharacteristic characteristic =
                                  _getCharacteristic();
                              await characteristic.setNotifyValue(true);
                              await characteristic.write(utf8.encode("S"));
                              setState(() {
                                _constantMode = _Therm.stopped;
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
                            Device = null;
                            Services = null;
                            Connected = false;
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => ConnectingDevicesPage(
                                        title: "Available Devices",
                                        storage: NameStorage(),
                                        autoConnect: false)),
                                (Route<dynamic> route) => false);
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
                      ],
                    ))),
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

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
