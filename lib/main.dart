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

//TODO: Auto connect to previous device, Persistence, Set up firebase for data
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
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>{

  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  String _deviceName;
  String _addedName;
  bool _connected = false;


  @override
  Widget build(BuildContext context) {
    if (!_connected) {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: _buildListViewOfDevices(),

          floatingActionButton: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.bottomLeft,
                  child: _connectPrevButton()
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: _reloadButton()
              ),
            ],
          )
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MySubPage(_connectedDevice, _services))),
            ),
          ),
          body: _buildListViewOfDevices(),
      );
    }
  }

  ///notify user to turn on bluetooth, detects bluetooth device
  @override
  void initState() {
    super.initState();
    if(_BTstatus() != true){
      WidgetsBinding.instance.addPostFrameCallback((_) => BTdialog());
      print("pass");
    } else {
      detectDevices();
    }
  }

  //Future<bool> _BTstatus() async {
    //var _BluetoothStatus =  await widget.flutterBlue.isOn;
    //return _BluetoothStatus;
  //}
/*  bool _BTstatus() {
    sc.addStream(BTstatusStream());
    sc.stream.listen((event) {
      print(event);
      return event;
    });
  }
  Stream<bool> BTstatusStream() async* {
    var _myStatus = await widget.flutterBlue.isOn;
    yield* Stream.periodic(Duration(seconds: 1), (_){
      return _myStatus;
    });
  }*/
  _BTstatus() async {
    var _myStatus = await widget.flutterBlue.isOn;
    setState(() async {
      _myStatus = await widget.flutterBlue.isOn;
    });
    return _myStatus;
  }
  ///dialog alerting user to turn on bluetooth settings
  void BTdialog() async {
    var _myStatus = await widget.flutterBlue.isOn;
    if(!_myStatus){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => new AlertDialog(
          title: new Text("Oops, something went wrong..."),
          content: new Text("Please turn on bluetooth to continue."),
          actions: [
            FlatButton(
                child: new Text("I have turned it on"),
                onPressed: () async {
                  var _newBTStatus = await widget.flutterBlue.isOn;
                  if(_newBTStatus){
                    Navigator.of(context).pop();
                  }
                  setState(() async {
                    _newBTStatus = await widget.flutterBlue.isOn;
                  });
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
    );}
    detectDevices();
    setState(() async {
      _myStatus = await widget.flutterBlue.isOn;
    });
  }


  void detectDevices(){
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
      child: Text('Refresh', style: TextStyle(color:Colors.white)),
      onPressed: () {
        List<BluetoothDevice> connected = new List<BluetoothDevice>();
        widget.flutterBlue.connectedDevices
            .asStream()
            .listen((List<BluetoothDevice> devices) {
            connected.addAll(devices);
            for (BluetoothDevice device in devices) {
              _addDeviceTolist(device);
            }
        });

        widget.devicesList.removeWhere((element) => !connected.contains(element));
        scan(3);
    }
    );
  }

  /// Button to connect with previous connected device
  Widget _connectPrevButton() {
    return FlatButton(
        color: Colors.yellow,
        child: Text('Connect Previous Device', style: TextStyle(color:Colors.white)),
        onPressed: () {
          _connectPrev();
        }
    );
  }

  void _connectPrev() async {
    if (_deviceName == '') {
      _connectPrevDialog("Problems connecting to previous device" , "No previous device ever connected!");
    }
    BluetoothDevice desired;
    for (BluetoothDevice b in widget.devicesList) {
      if (b.name == _deviceName) {
        desired = b;
        break;
      }
    }
    if (desired == null) {
      _connectPrevDialog("Problems connecting to previous device" ,"Previous device: " + _deviceName + " not found! Refresh and try again.");
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
      _connectedDevice = desired;
      Navigator.push(context, MaterialPageRoute(builder: (context) => MySubPage(_connectedDevice, _services)));
    });
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
    print("scanning");
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
                    color: _connectedDevice == null? Colors.blue : Colors.red,
                    child: _connectedDevice == null? Text('Connect', style: TextStyle(color:Colors.white)) :
                    Text('Disconnect', style: TextStyle(color:Colors.white)),
                    onPressed: () async {
                      if (_connectedDevice == null) {
                        widget.flutterBlue.stopScan();
                        try {
                          print("blue");
                          await device.connect();
                        } catch (e) {
                          if (e.code != 'already_connected') {
                            throw e;
                          }
                        } finally {
                          _services = await device.discoverServices();
                        }
                        setState(() {
                          _connected = true;
                          _connectedDevice = device;
                          _addName(_connectedDevice.name);
                          print("new page");
                          Navigator.push(context, MaterialPageRoute(builder: (
                              context) => MySubPage(_connectedDevice, _services)));
                          // Write bytes In MIT App Inventor
                        });
                      } else {
                        _connectedDevice.disconnect();
                        _connected = false;
                        setState(() {
                          _connectedDevice = null;
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


















