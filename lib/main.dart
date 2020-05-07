import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutterapp/MySubPage.dart';

void main() => runApp(MyApp());

/* Problems:
1. How to add the spread-collection to console？ ----------- switch to master branch(from beta) and upgrade
2. The app does not refresh(devices still remains on the app even when turned off)
*/

//TODO:
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Thermometer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: "Available Devices"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{

  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar:AppBar(
      title: Text(widget.title),
    ),
    body: _buildListViewOfDevices(),
  );

  void _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }
  // _removeDeviceTolist(final BluetoothDevice device) {}  --------------------- TODO: not urgent, use this to auto update available devices to connect to

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
    .asStream()
    .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results){
      for(ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }
  ListView _buildListViewOfDevices(){
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        Container(
          height: 50,
          child :Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),

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
                  await device.connect();
                } catch (e) {
                  if (e.code != 'already_connected') {
                    throw e;
                  }
                } finally {
                  _services = await device.discoverServices();
                }
                setState(() {
                  _connectedDevice = device;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MySubPage(_connectedDevice)));
                });
                },
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }
}

















