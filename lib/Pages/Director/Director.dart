import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicktherm/Pages/Manager/UnitsGrid.dart';
import '../../Utils/UserInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Director extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => DirectorState();
}

class DirectorState extends State<Director> {
  final  _user = new UserInfo();
  var _managers;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
//      Change below
//    _units = _user.fireStore.collection("/Organizations/" + _user.address + "/Buildings/" + _user.address + "/Units");
    _managers = _user.fireStore.collection("/Organizations/Testing/Buildings/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Managers"),
      ),
      body: _dirView(context),
    );
  }

  Widget _dirView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _managers.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
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
    return Card(
        color: Colors.white,
        child: Container(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UnitsGrid(units: data.reference.collection("Units"))));
            },
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

        )
    );
  }
}