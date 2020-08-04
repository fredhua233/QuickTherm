import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../Utils/Utils.dart';

class HelpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> {
  TextEditingController _msg = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(Utils.translate("Help")),
            bottom: TabBar(
              tabs: [
                Tab(text: Utils.translate("About/Help")),
                Tab(text: Utils.translate("Ask the Developers")),
              ],
            ),
          ),
          body: TabBarView(
              children: [
                _about(context),
                _askDeveloper()
              ]
          ),
        )
    );
  }

  Widget _about(BuildContext context) {
    return FutureBuilder(
      future: Utils().pref.then((pref) => pref.getString("id") ?? ""),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoadingPage();
        switch (snapshot.data) {
          case "resident":
            return _aboutForResident();
          case "manager":
            return _aboutForManager();
          case "director":
            return _aboutForDirector();
          default:
            return _aboutError();
        }
      },
    );
  }

  Widget _aboutForResident() {
    return ListView(
      padding: EdgeInsets.all(5),
      children: [
        Card(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.timeline, size: 40),
              ),
              Container(
                padding: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(Utils.translate("History icon"), style: TextStyle(color: Colors.black54),),
              )
            ],
          ),
        ),
        Card(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Icon(MdiIcons.thermometer, size: 40),
              ),
              Container(
                padding: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(Utils.translate("Thermometer icon"), style: TextStyle(color: Colors.black54),),
              )
            ],
          ),
        ),
        Card(
          child: Row(
            children: [
              Container(
                  padding: EdgeInsets.all(10),
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(3)))),
                      Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.black45,
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(3)))),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(3)))),
                    ],
                  )
              ),
              Container(
                padding: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(Utils.translate("Primary tag explanation"), style: TextStyle(color: Colors.black54),),
              )
            ],
          ),
        ),
        Card(
          child: Row(
            children: [
              Container(
                  padding: EdgeInsets.all(10),
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(3)))),
                      Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(3)))),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(3)))),
                    ],
                  )
              ),
              Container(
                padding: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(Utils.translate("Secondary tag explanation"), style: TextStyle(color: Colors.black54),),
              )
            ],
          ),
        ),
        Card(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.more_vert, size: 40),
              ),
              Container(
                padding: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width * 0.75,
                child: Text(Utils.translate("Options icon"), style: TextStyle(color: Colors.black54),),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _aboutForManager() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Text(Utils.translate("Units Tab"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            Card(
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.black45,
                            border: Border.all(
                                color: Colors.black,
                                width: 2,
                                style: BorderStyle.solid)),
                        child: Center(child: Text(Utils.translate("Unit 1"), style: TextStyle(fontSize: 10)))),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(Utils.translate("Units Tab description"), style: TextStyle(color: Colors.black54),),
                  )
                ],
              ),
            ),
            Text(Utils.translate("Individuals Tab"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            Card(
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                        width: 60,
                        height: 60,
                        child: Card(
                    child: Container(
                    child: Column(
                        children: [
                        Center(
                        child: Text("Bob", style: TextStyle(fontSize: 7))
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Center(
                        child: Text("36.34" + String.fromCharCode(0x00B0) +
                            "C", style: TextStyle(fontSize: 10, color: Colors.green)),
                      )
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text("Unit 1", style: TextStyle(fontSize: 5)),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Text("65", style: TextStyle(fontSize: 5)),
                            )
                          ]
                      )
                  ),
                  Stack(
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: Colors.black45,
                                    border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(1)))
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.sentiment_satisfied, size: 5,),
                        )
                      ]
                  )
                ],
              ),
            )
      )
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(Utils.translate("Individuals Tab description"), style: TextStyle(color: Colors.black54),),
                  )
                ],
              ),
            ),
            Text(Utils.translate("Icons"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            Card(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.search, size: 40),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(Utils.translate("Search icon description"), style: TextStyle(color: Colors.black54),),
                  )
                ],
              ),
            ),
            Card(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.notifications, size: 40),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(Utils.translate("Remind icon description"), style: TextStyle(color: Colors.black54)),
                  )
                ],
              ),
            ),
            Card(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.remove_red_eye, size: 40),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(Utils.translate("View icon(individual)"), style: TextStyle(color: Colors.black54)),
                  )
                ],
              ),
            ),
            Card(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(MdiIcons.thermometer, size: 40),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(Utils.translate("Change Unit Preference Button description"), style: TextStyle(color: Colors.black54),),
                  )
                ],
              ),
            ),
            Card(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.refresh, size: 40),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(Utils.translate("Refresh Icon"), style: TextStyle(color: Colors.black54)),
                  )
                ],
              ),
            ),
          ],
        ),
      )

    );
  }

  Widget _aboutForDirector() {
    return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Text(Utils.translate("Director View"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              Card(
                child: Row(
                  children: [
                    Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Center(
                              child: Text(Utils.translate("Mary"), style: TextStyle(fontSize: 10))
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Center(
                                child: Text(Utils.translate("# of Residents"), style: TextStyle(fontSize: 7)),
                              )
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Center(
                                child: Text("50", style: TextStyle(fontSize: 6)),
                              )
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("Director View Description"), style: TextStyle(color: Colors.black54)),
                    )
                  ],
                ),
              ),
              Card(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.search, size: 40),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("Search icon description"), style: TextStyle(color: Colors.black54),),
                    )
                  ],
                ),
              ),
              Card(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.remove_red_eye, size: 40),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("View icon(manager)"), style: TextStyle(color: Colors.black54)),
                    )
                  ],
                ),
              ),
              Card(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(MdiIcons.thermometer, size: 40),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("Change Unit Preference Button description"), style: TextStyle(color: Colors.black54),),
                    )
                  ],
                ),
              ),
              Text(Utils.translate("Units Tab"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              Card(
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.black45,
                              border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                  style: BorderStyle.solid)),
                          child: Center(child: Text(Utils.translate("Unit 1"), style: TextStyle(fontSize: 10)))),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("Units Tab description"), style: TextStyle(color: Colors.black54),),
                    )
                  ],
                ),
              ),
              Text(Utils.translate("Individuals Tab"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              Card(
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Container(
                          width: 60,
                          height: 60,
                          child: Card(
                              child: Container(
                                child: Column(
                                  children: [
                                    Center(
                                        child: Text("Bob", style: TextStyle(fontSize: 7))
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Center(
                                          child: Text("36.34" + String.fromCharCode(0x00B0) +
                                              "C", style: TextStyle(fontSize: 10, color: Colors.green)),
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text("Unit 1", style: TextStyle(fontSize: 5)),
                                              ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Text("65", style: TextStyle(fontSize: 5)),
                                              )
                                            ]
                                        )
                                    ),
                                    Stack(
                                        children: [
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Container(
                                                  width: 5,
                                                  height: 5,
                                                  decoration: BoxDecoration(
                                                      color: Colors.black45,
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 1,
                                                          style: BorderStyle.solid),
                                                      borderRadius: BorderRadius.circular(1)))
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Icon(Icons.sentiment_satisfied, size: 5,),
                                          )
                                        ]
                                    )
                                  ],
                                ),
                              )
                          )
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("Individuals Tab description"), style: TextStyle(color: Colors.black54),),
                    )
                  ],
                ),
              ),
              Text(Utils.translate("Other Icons"), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              Card(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.search, size: 40),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("Search icon description"), style: TextStyle(color: Colors.black54),),
                    )
                  ],
                ),
              ),
              Card(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.notifications, size: 40),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("Remind icon description"), style: TextStyle(color: Colors.black54)),
                    )
                  ],
                ),
              ),
              Card(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.remove_red_eye, size: 40),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("View icon(individual)"), style: TextStyle(color: Colors.black54)),
                    )
                  ],
                ),
              ),
              Card(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.refresh, size: 40),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text(Utils.translate("Refresh Icon"), style: TextStyle(color: Colors.black54)),
                    )
                  ],
                ),
              ),
            ],
          ),
        )

    );
  }
  Widget _aboutError() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.sentiment_very_dissatisfied, size: 200, color: Colors.black26,),
          Text(Utils.translate("There is a problem setting up, please delete app and reinstall. :("), style: TextStyle(fontSize: 24), textAlign: TextAlign.center,)
        ],
      ),
    );
  }
  Widget _askDeveloper() {
    return SingleChildScrollView(
      child:
        SafeArea(
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(Utils.translate("Meet the Developers!"),
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                          color: Colors.black)),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child:
                        Column(
                          children: [
                            Text("Andrew Sue", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                            InkWell(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 20, color: Colors.black54),
                                  children: [
                                    TextSpan(text: Utils.translate("Email:"), style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: "ansuefrhua@gmail.com")
                                  ],
                                ),
                              ),
                              onTap: () async {
                                if (await canLaunch("mailto:ansuefrhua@gmail.com?subject=BugReport&body=")) {
                                  launch("mailto:ansuefrhua@gmail.com?subject=BugReport&body=").then((success) {
                                    if (!success) {
                                      Utils().errDialog(Utils.translate("Can't send Message"), Utils.translate("Please email through another application, sorry!"), context);
                                    }
                                  });
                                } else {
                                  Utils().errDialog(Utils.translate("Can't send Message"), Utils.translate("Please email through another application, sorry!"), context);
                                }
                              }
                            ),
                            InkWell(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 20, color: Colors.black54),
                                  children: [
                                    TextSpan(text: Utils.translate("Tel:"), style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: "1(415)996-8529")
                                  ],
                                ),
                              ),
                              onTap: () async {
                                if (await canLaunch(
                                    "sms:14159968529")) {
                                  launch("sms:14159968529")
                                      .then((success) {
                                    if (!success) {
                                      Utils().errDialog(Utils.translate("Can't send Message"),
                                          Utils.translate("Please send SMS through another application, sorry!"),
                                          context);
                                    }
                                  });
                                } else {
                                  Utils().errDialog(Utils.translate("Can't send Message"),
                                      Utils.translate("Please send SMS through another application, sorry!"),
                                      context);
                                }
                              }
                            )
                          ],
                        ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Text("Fred Hua", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                        InkWell(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 20, color: Colors.black54),
                                children: [
                                  TextSpan(text: Utils.translate("Email:"), style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "ansuefrhua@gmail.com")
                                ],
                              ),
                            ),
                            onTap: () async {
                              if (await canLaunch("mailto:ansuefrhua@gmail.com?subject=BugReport&body=")) {
                                launch("mailto:ansuefrhua@gmail.com?subject=BugReport&body=").then((success) {
                                  if (!success) {
                                    Utils().errDialog(Utils.translate("Can't send Message"), Utils.translate("Please email through another application, sorry!"), context);
                                  }
                                });
                              } else {
                                Utils().errDialog(Utils.translate("Can't send Message"), Utils.translate("Please email through another application, sorry!"), context);
                              }
                            }
                        ),
                        InkWell(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 20, color: Colors.black54),
                                children: [
                                  TextSpan(text: Utils.translate("Tel:"), style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: Utils.translate("1(415)769-8863"))
                                ],
                              ),
                            ),
                            onTap: () async {
                              if (await canLaunch(
                                  "sms:14157698863")) {
                                launch("sms:14157698863")
                                    .then((success) {
                                  if (!success) {
                                    Utils().errDialog(Utils.translate("Can't send Message"),
                                        Utils.translate("Please send SMS through another application, sorry!"),
                                        context);
                                  }
                                });
                              } else {
                                Utils().errDialog(Utils.translate("Can't send Message"),
                                    Utils.translate("Please send SMS through another application, sorry!"),
                                    context);
                              }
                            }
                        )
                      ],
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(Utils.translate("Meet developer msg")),
                  )
                ],
              ),
          ),
        )
    );
  }
}