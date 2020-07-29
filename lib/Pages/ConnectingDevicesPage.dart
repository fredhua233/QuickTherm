import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quicktherm/Utils/Utils.dart';
import 'package:system_setting/system_setting.dart';

import 'TempMonitorPage.dart';

//TODO: Auto connect to previous device, Persistence, Set up firebase for data, fix error
BluetoothDevice Device;
List<BluetoothService> Services;
bool Connected = false;

/// Class to help store data for persistence across different APP launches
class NameStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/PrevDev');
  }

  Future<String> readName() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      throw e;
    }
  }

  Future<File> writeName(String msg) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(msg);
  }
}

class ConnectingDevicesPage extends StatefulWidget {
  ConnectingDevicesPage(
      {Key key, this.title, @required this.storage, this.autoConnect})
      : super(key: key);

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final NameStorage storage;
  final bool autoConnect;

  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();

  @override
  ConnectingDevicesPageState createState() => ConnectingDevicesPageState();
}

class ConnectingDevicesPageState extends State<ConnectingDevicesPage> {
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  String _deviceName;
  String _addedName;

//  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Connected) {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: _buildListViewOfDevices(),
          floatingActionButton: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.bottomLeft, child: _connectPrevButton()),
              Align(alignment: Alignment.bottomRight, child: _reloadButton()),
            ],
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _buildListViewOfDevices(),
      );
    }
  }

  ///notify user to turn on bluetooth, detects bluetooth device
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => BTdialog());
  }

  ///dialog alerting user to turn on bluetooth settings
  void BTdialog() async {
    bool _myStatus = await widget.flutterBlue.isOn;
    if (!_myStatus) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => new AlertDialog(
            title: new Text(Utils.translate("Oops, something went wrong...")),
            content: new Text(Utils.translate("Please turn on bluetooth to continue.")),
            actions: [
              FlatButton(
                  child: new Text(Utils.translate("I have turned it on")),
                  onPressed: () async {
                    var _newBTStatus = await widget.flutterBlue.isOn;
                    if (_newBTStatus) {
                      Navigator.of(context).pop();
                    }
                  }),
              FlatButton(
                child: new Text(Utils.translate("Go to Settings")),
                onPressed: () {
                  SystemSetting.goto(SettingTarget.BLUETOOTH);
                },
              )
            ],
          ));
    }
    detectDevices();
  }

  void detectDevices() {
    try {
      widget.storage.readName().then((String name) {
        setState(() {
          _deviceName = name;
        });
      });
    } catch (e) {
      _deviceName = '';
    }
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    scan(3);
  }

  ///add a detected BT device to devicelist
  void _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  /// Button for refreshing found device list, press once every 4 sec for newest found device
  /// @return Widget button
  Widget _reloadButton() {
    return FlatButton(
        color: Colors.green,
        child: Text(Utils.translate('Refresh'), style: TextStyle(color: Colors.white)),
        onPressed: () async {
          List<BluetoothDevice> connected = new List<BluetoothDevice>();
          widget.flutterBlue.connectedDevices
              .asStream()
              .listen((List<BluetoothDevice> devices) {
            connected.addAll(devices);
            for (BluetoothDevice device in devices) {
              _addDeviceTolist(device);
            }
          });
          widget.devicesList
              .removeWhere((element) => !connected.contains(element));
          await scan(3);
        });
  }

  /// Button to connect with previous connected device
  Widget _connectPrevButton() {
    return FlatButton(
        color: Colors.yellow,
        child: Text(Utils.translate('Connect Previous Device'),
            style: TextStyle(color: Colors.white)),
        onPressed: () {
          _connectPrev();
        });
  }

  Future<Widget> autoConnect(String name) async {
    if (widget.autoConnect) {
      BluetoothDevice desired;
      for (BluetoothDevice b in widget.devicesList) {
        if (b.name == name) {
          desired = b;
          break;
        }
      }
      if (desired != null) {
        widget.flutterBlue.stopScan();
        try {
          await desired.connect();
        } catch (e) {
          if (e.code != 'already_connected') {
            throw e;
          }
        } finally {
          _services = await desired.discoverServices();
          Services = _services;
        }
        setState(() {
          _connectedDevice = desired;
          Device = _connectedDevice;
          Connected = true;
        });
        return TempMonitorPage(_connectedDevice, _services);
      } else {
        return null;
      }
    }
  }

  void _connectPrev() async {
    if (_deviceName == '') {
      _connectPrevDialog(Utils.translate("Problems connecting to previous device"),
          Utils.translate("No previous device ever connected!"));
    }
    BluetoothDevice desired;
    for (BluetoothDevice b in widget.devicesList) {
      if (b.name == _deviceName) {
        desired = b;
        break;
      }
    }
    if (desired == null) {
      _connectPrevDialog(
          Utils.translate("Problems connecting to previous device"),
          Utils.translate("Previous device: ") +
              _deviceName +
              Utils.translate(" not found! Refresh and try again."));
    }
    widget.flutterBlue.stopScan();
    try {
      await desired.connect();
    } catch (e) {
      if (e.code != 'already_connected') {
        throw e;
      }
    } finally {
      _services = await desired.discoverServices();
      Services = _services;
    }
    setState(() {
      _connectedDevice = desired;
      Device = _connectedDevice;
      Connected = true;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TempMonitorPage(_connectedDevice, _services)));
    });
  }

  Future<File> _addName(String s) {
    setState(() {
      _addedName = s;
    });

    // Write the variable as a string to the file.
    return widget.storage.writeName(_addedName);
  }

  void _connectPrevDialog(String title, String msg) {
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
              child: new Text(Utils.translate("Close")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Scans for devices for a given amount of seconds, specified by SEC
  /// for continuous scan let SEC equal 0
  /// @param int sec
  scan(int sec) async {
    if (sec != 0) {
      widget.flutterBlue.startScan(timeout: Duration(seconds: sec));
      widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          _addDeviceTolist(result.device);
          if (result.device.name == _deviceName && widget.autoConnect) {
            autoConnect(_deviceName).then((wid) {
              if (wid != null) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => wid));
              }
            });
          }
        }
      });
      widget.flutterBlue.stopScan();
      return true;
    } else {
      widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          _addDeviceTolist(result.device);
        }
      });
      widget.flutterBlue.startScan();
    }
  }

  /// Updated： Only shows devices with name.
  ListView _buildListViewOfDevices() {
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in widget.devicesList) {
      //change here is to show all devices
      if (device.name != '') {
        containers.add(
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(device.name == '' ? Utils.translate('Unknown device') : device.name),
                      Text(device.id.toString()),
                    ],
                  ),
                ),
                FlatButton(
                  color: !Connected ? Colors.blue : Colors.red,
                  child: !Connected
                      ? Text(Utils.translate('Connect'), style: TextStyle(color: Colors.white))
                      : Text(Utils.translate('Disconnect'),
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    if (_connectedDevice == null) {
                      widget.flutterBlue.stopScan();
                      try {
                        await device.connect();
                      } catch (e) {
                        if (e.code != 'already_connected') {
                          throw e;
                        }
                      } finally {
                        _services = await device.discoverServices();
                        Services = _services;
                      }
                      setState(() {
                        Connected = true;
                        _connectedDevice = device;
                        Device = _connectedDevice;
                        _addName(_connectedDevice.name);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TempMonitorPage(
                                    _connectedDevice, _services)));
                        // Write bytes In MIT App Inventor
                      });
                    } else {
                      _connectedDevice.disconnect();
                      Connected = false;
                      setState(() {
                        _connectedDevice = null;
                        _services = null;
                        Services = null;
                        Device = null;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }
}