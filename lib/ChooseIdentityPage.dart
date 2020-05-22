import 'package:flutter/material.dart';
import 'package:flutterapp/ConnectingDevicesPage.dart';

//TODO: set up persistence and auto login, set up profile page
class ChooseIdentity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose my identity'),
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('I am a:'),
            selectIdentity(),
            //continue button
          ],
        ),
    ),
    );
  }
}

class selectIdentity extends StatefulWidget{
  @override
  _selectIdentityState createState() => _selectIdentityState();
}

class _selectIdentityState extends State<selectIdentity>{
  String _identity;
  String temp;

  void getDropDownItem(){
    setState(() {
      temp = _identity;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: <Widget> [
        DropdownButton<String>(
          items: [
            DropdownMenuItem<String>(
              child: Text('SRO Resident'),
              value: 'resident',
            ),
            DropdownMenuItem<String>(
              child: Text('SRO Manager'),
              value: 'manager',
            ),
            DropdownMenuItem<String>(
              child: Text('Hospital'),
              value: 'hospital',
            ),
          ],
          onChanged: (String value){
            setState(() {
              _identity = value;
            });
          },
          hint: Text('identity'),
          value: _identity,
        ),
        RaisedButton(
          child: Text('Continue'),
          onPressed: () {
            getDropDownItem();
//            if(_identity != null){
//              switch(_identity){
//                case 'resident':
//                  Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectingDevicesPage(title: "Available Devices", storage: NameStorage())));
//                  break;
//                case 'manager':
//                  Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectingDevicesPage(title: "Available Devices", storage: NameStorage())));
//              case 'hospital':
//                go to checking building page
//              }
//            }
          },
        )
      ],)
    );
  }
}