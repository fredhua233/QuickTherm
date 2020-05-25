import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class setUpInfoPage extends StatefulWidget{
  @override
  _setUpInfoPageState createState() => _setUpInfoPageState();
}

class _setUpInfoPageState extends State<setUpInfoPage>{

  String _firstName;
  String _lastName;
  String _address;
  String _phoneNumber;
  String _managerName;
  String _sex;
  String _healthHistory;
  String _healthStatus; ///combine
  String _condition;
  String _DOB;
  String _age;





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fill out your information'),
      ),
      body: Container(
        margin: EdgeInsets.all(24),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

            ],
          ),
        ),
      )
    );
  }
}