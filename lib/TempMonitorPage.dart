import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

//Critical voltage 3V, threshold 3.3V
//Steinhart constants A: 0.2501292874e-3, B: 3.847945539e-4, c: -5.719579276e-7
// T for discrete, C for constant monitor, S for stop constant monitoring
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
  String msg = 'Your Temperature';
  TempMonitorPageState(this.connectDevice, this.services);

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
        child: Text(msg,
          style: new TextStyle(
            fontSize: 40.0,
            color: Colors.black,
          ),),
      ),
      floatingActionButton:
        FloatingActionButton.extended(
          onPressed: () async {
            String TempString = "";
            double Temp = 0;
            int Vcc = 0;
            BluetoothCharacteristic characteristic = _getCharacteristic();
            await characteristic.setNotifyValue(true);
            await characteristic.write(utf8.encode("T"));
            characteristic.value.listen((value) {
              String reading = utf8.decode(value);
              int semi = reading.indexOf(';');
              TempString = reading.substring(2, semi);
              Temp = double.parse(TempString);
              Vcc = int.parse(reading.substring(semi + 5));
              print(Vcc);
              setState(() {
                msg = TempString + String.fromCharCode(0x00B0) + "C";
              });
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
