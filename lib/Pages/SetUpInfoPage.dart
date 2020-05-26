import 'package:flutter/material.dart';
import '../Utils/UserInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class setUpInfoPage extends StatefulWidget {
  @override
  _setUpInfoPageState createState() => _setUpInfoPageState();
}

class _setUpInfoPageState extends State<setUpInfoPage> {
  final _formKey = new GlobalKey<FormState>();
  final _user = UserInfo();
  String _groupValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Fill out your information'),
        ),
        body: SafeArea(
            top: false,
            bottom: false,
            child: Form(
                key: _formKey,
                autovalidate: true,
              child: new ListView(
                padding: EdgeInsets.all(20),
                children: <Widget> [
                  TextFormField(
                    decoration: InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Enter your name (Ex. John Doe)',
                        labelText: 'Name'
                    ),
                    validator: (value) {
                      if (value.isEmpty){
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    onSaved: (val) => setState(() => _user.Name = val),
                  ),
                  RadioListTile(
                    title: const Text('Male'),
                    value: 'Male',
                    groupValue: _groupValue,
                    onChanged: (value) => {
                      setState(() {
                        _groupValue = value;
                        _user.sex = value;
                      })
                    },
                  ),
                  RadioListTile(
                    title: const Text('Female'),
                    value: 'Female',
                    groupValue: _groupValue,
                    onChanged: (value) => {
                    setState(() {
                    _groupValue = value;
                    _user.sex = value;
                    })
                    },
                  )
                ],
              ),
            ),
        )
    );
  }
}