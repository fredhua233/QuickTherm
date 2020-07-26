import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quicktherm/Pages/HelpPage.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import 'package:quicktherm/Pages/Manager/UnitsGrid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/UserInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart';

class Director extends StatefulWidget {
  Director(
      {Key key, @required this.managers})
      : super(key: key);
  final CollectionReference managers;

  @override
  State<StatefulWidget> createState() => DirectorState();
}

class DirectorState extends State<Director> {
  _State _state = _State.all;
  TextEditingController _search = new TextEditingController();
  String _name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Director"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
                  child: IconButton(
                    icon: Icon(Icons.search),
                    tooltip: "Search For Specific Manager",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Search specific manager"),
                            content: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: _search,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Type in manager name',
                                  ),
                                )
                            ),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              FlatButton(
                                child: new Text("View"),
                                onPressed: () {
                                  String name = _search.text;
                                  setState(() {
                                    _state = _State.selfDefined;
                                    _name = name;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
              ),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
                  child: IconButton(
                      icon: Icon(Icons.remove_red_eye),
                      tooltip: "View All",
                      onPressed: () {
                        setState(() {
                          _state= _State.all;
                        });
                      }
                  )
          ),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: IconButton(
                  icon: Icon(MdiIcons.thermometer),
                  tooltip: "Change Unit",
                  onPressed: () {
                    SharedPreferences.getInstance().then((pref) {
                      setState(() {
                        if (UNITPREF == "C") {
                          UNITPREF = "F";
                        } else {
                          UNITPREF = "C";
                        }
                        pref.setString("Temp Unit", UNITPREF);
                      });
                    });
                  }
              )
          ),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Hero(
                tag: "Help",
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HelpPage()));
                  },
                  child: Icon(
                    Icons.help_outline,
                  ),
                ),
              )),
        ]
      ),
      body: _dirView(context),
    );
  }

  Widget _dirView(BuildContext context) {
    Stream<QuerySnapshot> filtered = _state == _State.selfDefined ? widget.managers.where("Name", isEqualTo: _name).snapshots() : widget.managers.snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: filtered,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingPage();
        if (snapshot.data.documents.length == 0) {
          return Center(
            child: Container(
                child: Column(
                  children: [
                    Icon(Icons.sentiment_dissatisfied, size: 100, color: Colors.black26),
                    Text("No such manager found, sorry!", style: TextStyle(fontSize: 20),)
                  ],
                )
            ),
          );
        }
        return GridView.builder(
          itemCount: snapshot.data.documents.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
            return _buildDirCell(context, snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  //Create the view of director cell
  Widget _buildDirCell(BuildContext context, DocumentSnapshot data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UnitsGrid(units: data.reference.collection("Units"))));
      },
      child: Card(
        color: Colors.white,
        child: Column(
              children: [
                Center(
                    child: Text(data["Name"], style: TextStyle(fontSize: 20))
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text("# of Residents", style: TextStyle(fontSize: 18)),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(data["Num of Res"].toString(), style: TextStyle(fontSize: 16)),
                    )
                ),
              ],
            ),
          )
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}

enum _State {
  all, selfDefined
}