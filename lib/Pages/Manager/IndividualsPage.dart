import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';

class IndividualPage extends StatefulWidget {
  DocumentReference IndividualDoc;
  DocumentReference UnitDoc;

  IndividualPage(this.IndividualDoc, this.UnitDoc);

  @override
  State<StatefulWidget> createState() {
    return IndividualPageState(IndividualDoc, UnitDoc);
  }
}

class IndividualPageState extends State<IndividualPage>{
  DocumentReference IndividualDoc;
  DocumentReference UnitDoc;

  IndividualPageState(this.IndividualDoc, this.UnitDoc);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Individual Page'),
      ),
    );
  }
}