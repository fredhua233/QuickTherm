import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

// FIXME: Enacting plan 2: using Arduino and HM-10 as a pass through until arrival of UART converter

class MySubPage extends StatefulWidget{
  BluetoothDevice connectDevice;
  List<BluetoothService> services;

  MySubPage(this.connectDevice, this.services);

  @override
  State<StatefulWidget> createState() {
    return MySubPageState(connectDevice, services);
  }
}

class MySubPageState extends State<MySubPage>{

  BluetoothDevice connectDevice;
  List<BluetoothService> services;
  String msg = 'Go back!';
  MySubPageState(this.connectDevice, this.services);

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
        child: Text(msg),
      ),
      floatingActionButton:
        FloatingActionButton.extended(
          onPressed: () async {
            //FIXME: change eventually
            BluetoothCharacteristic characteristic = _getCharacteristic();
            await characteristic.write(utf8.encode("AT"), withoutResponse: true);
            List<int> value = await characteristic.read();
            print(value);
            setState(() {
              msg = value.toString();
            });
          },
          label: Text("Take Temperature"),
        ),
    );
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
}
