import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class MySubPage extends StatefulWidget{

  BluetoothDevice connectDevice;

  MySubPage(this.connectDevice);

  @override
  State<StatefulWidget> createState() {
    return MySubPageState(connectDevice);
  }
}

class MySubPageState extends State<MySubPage>{

  BluetoothDevice connectDevice;

  MySubPageState(this.connectDevice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(connectDevice.name == '' ? '(unknown device)' : connectDevice.name),

      ),
      body: Center(
        child: Text('Go back!'),
      ),
    );
  }

}
