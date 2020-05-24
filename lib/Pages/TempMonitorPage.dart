import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'package:flutterapp/Pages/ConnectingDevicesPage.dart';
import 'package:flutterapp/Pages/main.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Critical voltage 3V, threshold 3.3V
//Steinhart constants A: 0.2501292874e-3, B: 3.847945539e-4, c: -5.719579276e-7
// T for discrete, C for constant monitor, S for stop constant monitoring

// TODO: Set up firebase, health color code, fix navigator
/**
 * The current state of measurement, constant or discreet
 */
enum _State {
  constant,
  discreet
}

enum _Therm {
  started,
  stopped
}

class TempMonitorPage extends StatefulWidget{
  BluetoothDevice connectDevice;
  List<BluetoothService> services;
  TempMonitorPage(this.connectDevice, this.services);

  @override
  State<StatefulWidget> createState() {
    return TempMonitorPageState(connectDevice, services);
  }
}

class TempMonitorPageState extends State<TempMonitorPage>{

  BluetoothDevice connectDevice;
  List<BluetoothService> services;
  TempMonitorPageState(this.connectDevice, this.services);
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _monitorState = _State.discreet;
  var _constantMode = _Therm.stopped;
  bool save = true;

  String msg = "";
  String heading = "Your Temperature";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: menu.getMenu(context),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.timeline,
                ),
              )
          ),
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
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
                        ConnectingDevicesPage(title: "Available Devices", storage: NameStorage(), autoConnect: false)));
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "Change Mode",
                  child: Text(
                    "Change Mode of Monitoring",
                  )
                ),
                PopupMenuItem(
                  value: "Disconnect",
                  child: Text(
                    "Disconnect from Current Device",
                  )
                ),
                PopupMenuItem(
                  value: "Delete",
                  child: Text(
                    "Delete Last Taking"
                  )
                )
              ]
            ),
          ),
        ],
        title: Text("Thermometer"),
      ),
      body: Stack(
        children: <Widget>[
          Align(
            alignment: FractionalOffset(0.5, 0.1),
            child: Text(heading,
                style: new TextStyle(
                  fontSize: 25,
                  color: Colors.black
                )
            )
          ),
          Align(
              alignment: FractionalOffset(0.5, 0.25),
              child: Text(msg,
                  style: new TextStyle(
                      fontSize: 40,
                      color: Colors.black
                  )
              )
          ),
        ]
      ),
      floatingActionButton: _button(_monitorState),
      backgroundColor: _monitorState == _State.constant && _constantMode == _Therm.started ? Colors.lightGreen[200] :
      _monitorState == _State.constant && _constantMode == _Therm.stopped ? Colors.red[200] : Colors.white
    );
  }

  /**
   * Show default heading
   */
  _showMsg(){
    _prefs.then((pref) {
      String text = '';
      text = pref.containsKey("LastTemp") ? pref.getDouble("LastTemp").toString()
          + String.fromCharCode(0x00B0) + "C" : "Take Temperature";
      setState(() {
        msg = text;
      });
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
      _errDialog("Service not found", "Needed service not found, disconnect and "
          "attempt again, or connect to another device.");
    }
    if (char != null) {
      return char;
    } else {
      _errDialog("Suitable characteristic not found", "disconnect and "
          "attempt again, or connect to another device.");
      return null;
    }

  }

  /**
   * Template for error dialogs.
   */
  void _errDialog(String title, String msg ) {
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
      return Stack (
        children: <Widget>[
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
                  _checkingForHealth(Temp);
                  if (Vcc < 3300) {
                    _errDialog("Low Battery", "Low battery, please charge your armband. "
                        "Current Battery level: " + ((Vcc / 3700) * 100).toString() + "%");
                  }
                },
                label: Text("Measure"),
                icon: new Icon(MdiIcons.thermometer)
            )
          )
        ]
      );
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
                    BluetoothCharacteristic characteristic = _getCharacteristic();
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
                            msg =
                                TempString + String.fromCharCode(0x00B0) + "C";
                          });
                          _saveData(Temp);
                          if (Vcc < 3300) {
                            _errDialog("Low Battery",
                                "Low battery, please charge your armband. "
                                    "Current Battery level: " +
                                    ((Vcc / 3700) * 100).toString() + "%");
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
                )

              )

          ),
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
              )
          ),
        ],
      );
    }
  }

  /**
   * Handles giving health status warnings
   */
  void _checkingForHealth(double temp) {
    if (temp < 20 || temp > 45) {
      _errDialog("Try Again!", "Bad measurement, please close this dialog, adjust placement of armband and try to measure your temperature again.");
    } else {
      if (temp < 35) {
        _errDialog("Hypothermia!", "You potentially have hypothermia!");
      } else if (temp > 37.5) {
        _errDialog("Fever!", "You potentially have fever!");
      }
      _saveData(temp);
    }
  }

  /**
   * Handles Saving data
   */
  void _saveData(double temp) async {
    SharedPreferences pref = await _prefs;
//    Future.delayed(Duration(seconds: 1)).then((value) {
//      if (c == 1) {
//        _saveDataDialog(temp);
//      }
//      if (save) {
    pref.setDouble("LastTemp", temp);
    pref.setString("LastMeasTime", new DateTime.now().toString());
    _pushData(temp).then((success) {
      if (!success) {
        _errDialog("Pushing data to cloud failed!", "Please check your wifi connection and try again.");
      }
    });
//      }
//    });
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
          title: new Text("Your Temperature: " + temp.toString() + String.fromCharCode(0x00B0) + "C"),
          content: new Text("Delete this measurement in cloud? If you think there is an error in this measurement, please press Yes and measure again."),
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
    _prefs.then((pref) {
      if (pref.containsKey("LastTemp")) {
        double temp = pref.getDouble("LastTemp");
        _deleteDataDialog(temp);
        if (!save) {
          pref.remove("LastTemp");
        }
      }
    });
  }
  /*
  Handles pushing data to cloud
   */
  Future<bool> _pushData(double temp) async {
    return true;
  }
}