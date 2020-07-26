import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:quicktherm/Pages/HelpPage.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import 'package:quicktherm/Pages/Manager/IndividualPage.dart';
import 'package:quicktherm/Pages/Manager/IndividualsGrid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quicktherm/Utils/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class UnitsGrid extends StatefulWidget {
  UnitsGrid(
      {Key key, @required this.units})
      : super(key: key);

  final CollectionReference units;

  @override
  State<StatefulWidget> createState() => UnitsGridState();
}

class UnitsGridState extends State<UnitsGrid> {
  CollectionReference _units;
  _ModeUnits _mode = _ModeUnits.all;
  String _name = "";
  TextEditingController _search = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  //Sets up firebase
  void _init() {
    _units = widget.units;
    print(_units.path);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Units"),
          actions: <Widget>[
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
                    tag: "Remind",
                    child: IconButton(
                      icon: Icon(Icons.notifications),
                      tooltip: "See who needs to be reminded",
                      onPressed: () {
                        setState(() {
                          _mode = _ModeUnits.remind;
                        });
                      }
                      ))),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Hero(
                  tag: "Search",
                  child: IconButton(
                    icon: Icon(Icons.search),
                    tooltip: "Search For Specific Unit/Individual",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Search specific unit/individual"),
                            content: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: _search,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Type in Unit/Individual name',
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
                                    _mode = _ModeUnits.selfDefined;
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
                )),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case "All":
                            setState(() {
                              _mode = _ModeUnits.all;
                            });
                            break;
                          case "Healthy":
                            setState(() {
                              _mode = _ModeUnits.healthy;
                            });
                            break;
                          case "Ill":
                            setState(() {
                              _mode = _ModeUnits.ill;
                            });
                            break;
                          case "Potential":
                            setState(() {
                              _mode = _ModeUnits.potential;
                            });
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                            value: "All",
                            child: Text(
                              "Show all",
                            )),
                        PopupMenuItem(
                            value: "Healthy",
                            child: Text(
                              "Show all healthy",
                            )),
                        PopupMenuItem(
                            value: "Ill",
                            child: Text(
                                "Show all ill"
                            )),
                        PopupMenuItem(
                            value: "Potential",
                            child: Text(
                                "Show all potential"
                            )),
                      ],
                      icon: Icon(Icons.remove_red_eye),
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
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Units"),
              Tab(text: "Individuals"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              child: _viewController(context, _mode, name: _name),
              onRefresh: refresh,
            ),
            RefreshIndicator(
              child: _viewControllerInd(context, _mode, name: _name),
              onRefresh: refresh,
            )
          ]
        ),
      )
    );
  }

  Future<String> refresh() async {
    setState(() {
      _mode = _mode;
    });
    return 'finished';
  }
  // Below is the functions for displaying unit view

  //Controlling view base on _mode
  Widget _viewController(BuildContext context, _ModeUnits m, {String name}) {
    if (m != _ModeUnits.selfDefined) {
      return _UnitsView(context, m);
    } else {
      return _UnitsView(context, m, name: name);
    }
  }

  //Creating the grid view
  Widget _UnitsView(BuildContext context, _ModeUnits m, {String name}) {
    Stream<QuerySnapshot> str;
    if (m == _ModeUnits.selfDefined) {
      str = _units.where("Name", isEqualTo: name).snapshots();
    } else {
      str = m == _ModeUnits.all? _units.snapshots() :
            m == _ModeUnits.healthy ? _units.where("Unit Status", isEqualTo: "healthy").snapshots() :
            m == _ModeUnits.ill ? _units.where("Unit Status", isEqualTo: "ill").snapshots() :
            m == _ModeUnits.potential ? _units.where("Unit Status", isEqualTo: "potentially ill").snapshots() :
            _units.snapshots();
    }
    return StreamBuilder<QuerySnapshot>(
      stream: str,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingPage();
        snapshot.data.documents.sort((a,b) => a["Name"].compareTo(b["Name"]));
        return _buildUnitsGrid(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildUnitsGrid(BuildContext context, List<DocumentSnapshot> snapshot) {
    if (snapshot.length == 0) {
      return Center(
        child: Container(
          child: Column(
            children: [
              Icon(Icons.sentiment_dissatisfied, size: 100, color: Colors.black26),
              Text("No such unit found, sorry!", style: TextStyle(fontSize: 22),)
            ],
          )
        ),
      );
    }
    return GridView.builder(
      itemCount: snapshot.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return _buildUnitCell(context, snapshot[index]);
      },
    );
  }

  //Create the view of individual cell
  Widget _buildUnitCell(BuildContext context, DocumentSnapshot data) {
    return Card(
        color: _getColor(data["Unit Status"]),
        child: ListTile(
          title: Text(data["Name"], style: TextStyle(color: _getColor(data["Unit Status"]) == Colors.black ? Colors.white : Colors.black),),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualsGrid(individuals: data.reference.collection("Individuals"), unitName: data["Name"])));
          }
        )
    );
  }

  // Gets color of the cells base on their status
  Color _getColor(String c) {
    if (c == "ill")
      return Colors.black;
    if (c == "potentially ill")
      return Colors.black45;
    if (c == "healthy")
      return Colors.white;
  }

  Widget _viewControllerInd(BuildContext context, _ModeUnits m, {String name}) {
    Stream<QuerySnapshot> units = m == _ModeUnits.all?  _units.snapshots() :
    m == _ModeUnits.healthy ? _units.where("Unit Status", isEqualTo: "healthy").snapshots():
    m == _ModeUnits.ill ? _units.where("Unit Status", isEqualTo: "ill").snapshots() :
    m == _ModeUnits.potential ? _units.where("Unit Status", isEqualTo: "potentially ill").snapshots() :
    _units.snapshots();
      return StreamBuilder<QuerySnapshot> (
        stream: units,
        builder: (context, unit) {
          if (!unit.hasData) return LoadingPage();
          return FutureBuilder(
            future: _individualView(context, m, unit.data, name: _name),
            builder: (context, snap) {
              if (snap.hasData) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return LoadingPage();
                }
                return snap.data;
              }
              return LoadingPage();
            },
          );
        },
      );

  }

  //Below is the code for showing this grid view of individuals
  Future<Widget> _individualView(BuildContext context, _ModeUnits m, QuerySnapshot units, {String name}) async {
    List<DocumentSnapshot> ppl = [];
    for (var unit in units.documents) {
      QuerySnapshot inds;
      switch (m) {
        case _ModeUnits.all :
          inds = await unit.reference.collection("Individuals").getDocuments();
          break;
        case _ModeUnits.healthy:
          inds = await unit.reference.collection("Individuals").where("Primary Tag", isEqualTo: Colors.white.toString()).getDocuments();
          break;
        case _ModeUnits.ill:
          inds = await unit.reference.collection("Individuals").where("Primary Tag", isEqualTo: Colors.black.toString()).getDocuments();
          break;
        case _ModeUnits.potential:
          inds = await unit.reference.collection("Individuals").where("Primary Tag", isEqualTo: Colors.black45.toString()).getDocuments();
          break;
        case _ModeUnits.remind:
          DateTime limit = DateTime.now().subtract(Duration(hours: 12));
          inds = await unit.reference.collection("Individuals").where("Last Measured", isLessThan: limit.toString()).getDocuments();
          break;
        case _ModeUnits.selfDefined:
          inds = await unit.reference.collection("Individuals").where("Name", isEqualTo: name).getDocuments();
          break;
      }
      ppl.addAll(inds.documents);
    }
    if (ppl.length == 0) {
      return Center(
        child: Container(
            child: Column(
              children: [
                Icon(Icons.sentiment_dissatisfied, size: 100, color: Colors.black26),
                Text("No such person found, sorry!", style: TextStyle(fontSize: 20),)
              ],
            )
        ),
      );
    }
    return GridView.builder(
        itemCount: ppl.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2),
        itemBuilder: (context, index) {
          print(ppl[index].runtimeType);
          return _buildIndCell(context, ppl[index]);
        }
    );
  }

  Widget _buildIndCell(BuildContext context, DocumentSnapshot data) {
    Map<String, dynamic> info = data.data;
    Map<String, dynamic> temps = info["Temperature"];
    List<String> date = temps.keys.toList();
    date.sort((a, b) => a.compareTo(b));
    String lastTemp = temps == null || date.length == 0? 'N/A' : Utils().compTemp(temps[date.last]);
    Icon trend = Icon(Icons.sentiment_satisfied, color:  Colors.green);
//    if (lastTemp.length > 5) {
//      lastTemp = lastTemp.substring(0, 5) + String.fromCharCode(0x00B0) +
//          "C";
//    } else {
//      lastTemp = lastTemp + String.fromCharCode(0x00B0) +
//          "C";
//    }
    String name = info["Name"];
    String age = info.containsKey("Date of Birth") ? (DateTime.now().difference(DateTime.parse(info["Date of Birth"])).inDays/365).floor().toString() : "";
    String unitName = info["Unit Name"];
    String unitPath = "/Organization/" + info["Organization"] + "/Managers/" + info["Manager Name"] + "/Units/" + unitName;
    Color ptag = _getPColor(info["Primary Tag"]);
    Color stag = _getSColor(info["Secondary Tag"]);
    // Get trend
    if (temps != null && date.length > 2) {
      if (ptag == Colors.black) {
        if (stag == Colors.red &&
            temps[date.last] > temps[date[date.length - 2]]) {
          trend = Icon(Icons.sentiment_dissatisfied, color: Colors.red);
        }
        if (stag == Colors.blue &&
            temps[date.last] < temps[date[date.length - 2]]) {
          trend = Icon(Icons.sentiment_dissatisfied, color: Colors.red);
        }
      }
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualPage(data.reference, Firestore.instance.document(unitPath))));
      },
      child: Card(
          child: Container(
            child: Column(
              children: [
                Center(
                    child: Text(name, style: TextStyle(fontSize: 20))
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(lastTemp, style: TextStyle(fontSize: 30, color: stag)),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(unitName),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(age),
                          )
                        ]
                    )
                ),
                Stack(
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color: ptag,
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(5)))
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: trend,
                      )
                    ]
                )
              ],
            ),
          )
      ),
    );
  }

  // Gets color of the cells base on their status
  Color _getPColor(String c) {
    if (c == Colors.black.toString())
      return Colors.black;
    if (c == Colors.black45.toString())
      return Colors.black45;
    if (c == Colors.white.toString())
      return Colors.white;
  }

  Color _getSColor(String c) {
    if (c == Colors.red.toString())
      return Colors.red;
    if (c == Colors.green.toString())
      return Colors.green;
    if (c == Colors.blue.toString())
      return Colors.blue;
  }


  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}

enum _ModeUnits {
  ill, potential, healthy, all, selfDefined, remind
}