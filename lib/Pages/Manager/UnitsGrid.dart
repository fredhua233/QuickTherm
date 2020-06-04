import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Utils/Utils.dart';
import '../../Utils/UserInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnitsGrid extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UnitsGridState();
}

class UnitsGridState extends State<UnitsGrid> {
  Utils _utils = new Utils();
  UserInfo _user = new UserInfo.defined();
  CollectionReference _units;

  @override
  void initState() {
    super.initState();
    _init();
  }

  //Sets up firebase
  void _init() {
//      Change below
//    _units = _user.fireStore.collection("/Organizations/" + _user.address + "/Buildings/" + _user.address + "/Units");
    _units = _user.fireStore.collection("/Organizations/" + UserInfo.address + "/Buildings/" + UserInfo.address + "/Units");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Units"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Units"),
              Tab(text: "Individuals"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Icon(Icons.directions_car),
            Icon(Icons.directions_transit),
          ]
        ),
      )
    );
  }

  Widget _UnitsView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _units.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return _buildUnitsGrid(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildUnitsGrid(BuildContext context, List<DocumentSnapshot> snapshot) {
//    return GridView.builder(
//      itemCount: data.length,
//      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//          crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3),
//      itemBuilder: (BuildContext context, int index) {
//        return new Card(
//          child: new GridTile(
//            footer: new Text(data[index]['name']),
//            child: new Text(data[index]
//            ['image']), //just for testing, will fill with image later
//          ),
//        );
//      },
//    );
  }

//  Widget _buildUnitCell(BuildContext context, DocumentSnapshot data) {
//    final record = Record.fromSnapshot(data);
//
//    return Padding(
//      key: ValueKey(record.name),
//      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//      child: Container(
//        decoration: BoxDecoration(
//          border: Border.all(color: Colors.grey),
//          borderRadius: BorderRadius.circular(5.0),
//        ),
//        child: ListTile(
//          title: Text(record.name),
//          trailing: Text(record.votes.toString()),
//          onTap: () => record.reference.updateData({'votes': FieldValue.increment(1)}),       ),
//      ),
//    );
//  }

  Widget _individualView(BuildContext context) {

  }
}

class Unit {
  final String name;
  final Color color;
  Unit({this.name, this.color});
}