import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicktherm/Pages/Manager/IndividualsGrid.dart';
import '../../Utils/UserInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnitsGrid extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UnitsGridState();
}

class UnitsGridState extends State<UnitsGrid> {
  UserInfo _user = new UserInfo.defined();
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
//      Change below
//    _units = _user.fireStore.collection("/Organizations/" + _user.address + "/Buildings/" + _user.address + "/Units");
    _units = _user.fireStore.collection("/Organizations/Testing/Buildings/Building1/Units");
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
                            title: new Text("Input Date"),
                            content: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: _search,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Type in Unit name',
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
                child: Hero(
                    tag: "views",
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
                              "Show all units",
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
            _viewController(context, _mode, name: _name),
            Icon(Icons.directions_transit),
          ]
        ),
      )
    );
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
            m == _ModeUnits.healthy ? _units.where("Unit Status", isEqualTo: "Healthy").snapshots() :
            m == _ModeUnits.ill ? _units.where("Unit Status", isEqualTo: "Ill").snapshots() :
            m == _ModeUnits.potential ? _units.where("Unit Status", isEqualTo: "Potential").snapshots() :
            _units.snapshots();
    }
    return StreamBuilder<QuerySnapshot>(
      stream: str,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        snapshot.data.documents.sort((a,b) => a["Name"].compareTo(b["Name"]));
        return _buildUnitsGrid(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildUnitsGrid(BuildContext context, List<DocumentSnapshot> snapshot) {
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
    if (c == "Ill")
      return Colors.black;
    if (c == "Potential")
      return Colors.black45;
    if (c == "Healthy")
      return Colors.white;
  }

  //Below is the code for showing this grid view of individuals
  Widget _individualView(BuildContext context) {

  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
}

enum _ModeUnits {
  ill, potential, healthy, all, selfDefined
}