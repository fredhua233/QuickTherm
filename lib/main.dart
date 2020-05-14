import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutterapp/MySubPage.dart';
import 'package:system_setting/system_setting.dart';

void main() => runApp(MyApp());

//TODO:
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Thermometer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: "Available Devices", storage: NameStorage() ),

    );
  }
}

/// Class to help store data for persistence across different APP launches
class NameStorage {
  NameStorage(){
    var myFile = new File("PrevDev");
    myFile.create();
  }

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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, @required this.storage}) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final NameStorage storage;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{

  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  String _deviceName;
  String _addedName;
  Future<bool> _BluetoothStatus;


  @override
  Widget build(BuildContext context) {
    while(_BTstatus() != true) {
      BTdialog();
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
      ),
      body: _buildListViewOfDevices(),

      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: _connectPrev()
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: _reloadButton()
          ),
        ],
      )
    );
  }
  ///status of bluetooth of your device
    Future<bool> _BTstatus() {
      _BluetoothStatus =  widget.flutterBlue.isOn;
      return _BluetoothStatus;
    }

  ///dialog alerting user to turn on bluetooth settings
    void BTdialog() {
      showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text("Oops, something went wrong..."),
          content: new Text("Please connect to bluetooth to continue."),
          actions: [
            FlatButton(
              child: new Text("Cancel"),
              onPressed: (){
                Navigator.of(context).pop();
              }
            ),
            FlatButton(
              child: new Text("Go to Settings"),
              onPressed: (){
                  SystemSetting.goto(SettingTarget.BLUETOOTH);
              },
            )
          ],
        )
      );
    }

  ///add a detected BT device to devicelist
    void _addDeviceTolist(final BluetoothDevice device) {
      if (!widget.devicesList.contains(device)) {
        setState(() {
          widget.devicesList.add(device);
        });
      }
    }

  ///detects bluetooth device
    @override
    void initState() {
      super.initState();
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

  /// Button for refreshing found device list, press once every 4 sec for newest found device
  /// @return Widget button
    Widget _reloadButton() {
      return FlatButton(
        color: Colors.green,
        child: Text('Refresh', style: TextStyle(color:Colors.white)),
        onPressed: () {
          List<BluetoothDevice> connected = new List<BluetoothDevice>();
          widget.flutterBlue.connectedDevices
              .asStream()
              .listen((List<BluetoothDevice> devices) {
              connected.addAll(devices);
          });
          widget.devicesList.removeWhere((element) => !connected.contains(element));
          scan(3);
      }
      );
    }

  /// Button to connect with previous connected device //TODO: Check if it works

    Widget _connectPrev() {
      return FlatButton(
          color: Colors.yellow,
          child: Text('Connect Previous Device', style: TextStyle(color:Colors.white)),
          onPressed: () async {
            if (_deviceName == '') {
              _connectPrevDialog("Problems connecting to previous device" , "No previous device ever connected!");
            }
            BluetoothDevice desired;
            print("mmmmmmmm");
            for (BluetoothDevice b in widget.devicesList) {
              if (b.name == _deviceName) {
                desired = b;
                break;
              }
            }
            if (desired == null) {
              _connectPrevDialog("Problems connecting to previous device" ,"Previous device: " + _deviceName + " not found!");
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
            }
            setState(() {
              print('setState');
              _connectedDevice = desired;
              Navigator.push(context, MaterialPageRoute(builder: (context) => MySubPage(_connectedDevice)));
            });
          }
      );
   }
  Future<File> _addName(String s) {
    setState(() {
      _addedName = s;
    });

    // Write the variable as a string to the file.
    return widget.storage.writeName(_addedName);
  }

  void _connectPrevDialog(String title, String msg ) {
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
  /// Scans for devices for a given amount of seconds, specified by SEC
  /// for continuous scan let SEC equal 0
  /// @param int sec
  void scan(int sec) {
      if (sec != 0) {
        widget.flutterBlue.startScan(timeout: Duration(seconds: sec));
        widget.flutterBlue.scanResults.listen((List<ScanResult> results){
          for(ScanResult result in results) {
            _addDeviceTolist(result.device);
          }
        });
        widget.flutterBlue.stopScan();
      } else {
        widget.flutterBlue.scanResults.listen((List<ScanResult> results){
          for(ScanResult result in results) {
            _addDeviceTolist(result.device);
          }
        });
        widget.flutterBlue.startScan();
      }

    }

  /// Updated： Only shows devices with name.

  ListView _buildListViewOfDevices(){
      List<Container> containers = new List<Container>();
      for (BluetoothDevice device in widget.devicesList) {
        //change here is to show all devices
        if (device.name != '') {
          containers.add(
            Container(
              height: 50,
              child :Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(device.name == ''?'Unknown device':device.name),
                        Text(device.id.toString()),
                      ],
                    ),
                  ),
                  FlatButton(
                    color: Colors.blue,
                    child: Text('Connect', style: TextStyle(color:Colors.white)),
                    onPressed: () async {
                      widget.flutterBlue.stopScan();
                      try {
                        print("blue");
                        await device.connect();
//                        print("blue");
                      } catch (e) {
                        if (e.code != 'already_connected') {
                          throw e;
                        }
                      } finally {
                        _services = await device.discoverServices();
                      }
                      setState(() {
                        _connectedDevice = device;
                        _addName(_connectedDevice.name);
                        print("new page");
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MySubPage(_connectedDevice)));
                        
                      });
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


















