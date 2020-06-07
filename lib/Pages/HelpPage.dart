import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Units"),
            bottom: TabBar(
              tabs: [
                Tab(text: "About"),
                Tab(text: "Ask the Developers"),
              ],
            ),
          ),
          body: TabBarView(
              children: [
                _about(),
                _askDeveloper()
              ]
          ),
        )
    );
  }

  Widget _about() {

  }

  Widget _askDeveloper() {

  }
}