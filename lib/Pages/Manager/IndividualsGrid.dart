import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quicktherm/Pages/Manager/IndividualPage.dart';

class IndividualsGrid extends StatefulWidget {
  IndividualsGrid(
      {Key key, @required this.individuals, this.unitName})
      : super(key: key);

  final CollectionReference individuals;
  final String unitName;

  @override
  State<StatefulWidget> createState() => IndividualsGridState();
}

class IndividualsGridState extends State<IndividualsGrid> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Individuals"),
      ),
      body: _indView(context),
    );
  }

  // Below is the functions for displaying unit view


  //Creating the grid view
  Widget _indView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.individuals.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return GridView.builder(
          itemCount: snapshot.data.documents.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
            return _buildIndCell(context, snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  //Create the view of individual cell
  Widget _buildIndCell(BuildContext context, DocumentSnapshot data) {
    Map<String, dynamic> info = data.data;
    Map<String, dynamic> temps = info["Temperature"];
    List<String> date = temps.keys.toList();
    date.sort((a, b) => a.compareTo(b));
    String lastTemp = temps[date.last].toString();
    Icon trend = Icon(Icons.sentiment_satisfied, color:  Colors.green);
    if (lastTemp.length > 5) {
      lastTemp = lastTemp.substring(0, 5) + String.fromCharCode(0x00B0) +
          "C";
    } else {
      lastTemp = lastTemp + String.fromCharCode(0x00B0) +
          "C";
    }
    String name = info["Name"];
    String age = info.containsKey("Date of Birth") ? (DateTime.now().difference(DateTime.parse(info["Date of Birth"])).inDays/365).floor().toString() : "";
    Color ptag = _getPColor(info["Primary Tag"]);
    Color stag = _getSColor(info["Secondary Tag"]);
    String unitPath = "/Organization/" + info["Organization"] + "/Managers/" + info["Manager Name"] + "/Units/" + widget.unitName;
    if (ptag == Colors.black) {
      if (stag == Colors.red && temps[date.last] > temps[date[date.length - 2]]) {
        trend = Icon(Icons.sentiment_dissatisfied, color: Colors.red);
      }
      if (stag == Colors.blue && temps[date.last] < temps[date[date.length - 2]]) {
        trend = Icon(Icons.sentiment_dissatisfied, color: Colors.red);
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
                          child: Text(widget.unitName),
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
}
