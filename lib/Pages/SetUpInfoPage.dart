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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Fill out your information'),
        ),
        body: Container(
            padding: EdgeInsets.all(24),
            child: Builder(
              builder: (context) => Form(
                key: _formKey,
                autovalidate: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    new ListView(
                      padding: EdgeInsets.all(20),
                      children: <Widget> [
                        TextFormField(
                          decoration: InputDecoration(
                              icon: Icon(Icons.calendar_today),
                              hintText: 'Enter your first and last name (Ex. John Doe)',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [
                            RadioListTile(
                              title: const Text('Male'),
                              value: 0,
                              onChanged: (value) => {
                                setState(() {
                                  _user.sex = value;
                                })
                              },
                            ),
                            RadioListTile(
                              title: const Text('Female'),
                              value: 1,
                              onChanged: (value) => {
                                setState(() {
                                  _user.sex = value;
                                })
                              },
                            )
                          ],
                        )

                      ],
                    )
                  ],
                ),
              ),
            )
        )
    );
  }
}