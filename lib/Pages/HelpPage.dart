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
            title: Text("Help"),
            bottom: TabBar(
              tabs: [
                Tab(text: "About/Help"),
                Tab(text: "Ask the Developers"),
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
                child: Text("This is the history icon, you can tap this to see your historical temperature trends.", style: TextStyle(color: Colors.black54),),
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
                child: Text("This is the thermometer icon, you can tap this icon to measure your current temperature.", style: TextStyle(color: Colors.black54),),
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
                child: Text("These are the primary tags that represent your current health condition: \n\n"
                    "Black - ill. \nGray - potentially ill, or under recovery. \nWhite - healthy", style: TextStyle(color: Colors.black54),),
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
                child: Text("These are the secondary tags that represent your current temperature: \n\n"
                    "Red - fever. \nGreen - normal \nBlue - hypothermia", style: TextStyle(color: Colors.black54),),
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
                child: Text("This is options icon, you can tap this icon to:\n\n"
                    "Change Mode - this changes the temperature taking mode to be constant monitoring mode, "
                    "which monitors your temperature constantly. Press the starts button to start monitoring, "
                    "stop button to stop monitoring.\n\n"
                    "Disconnect - disconnect from current device and connect to a new device. \n\n"
                    "Delete - deletes the current temperature measurement from record. \n\n"
                    "Change Unit Preference - changes the unit you view your temperature in, "
                    "if you are on fahrenheit, it will swap to celsius and vice versa.", style: TextStyle(color: Colors.black54),),
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
            Text("Units Tab", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                        child: Center(child: Text("Unit 1", style: TextStyle(fontSize: 10)))),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text("In the units tab, you can see all the units under your responsibility. "
                        "Each unit is represented by a tile with the unit name in the middle and its condition is represented by its color:\n\n"
                        "Black - ill. \nGray - potentially ill, or under recovery. \nWhite - healthy\n\nTap on the unit tile to see all the individuals in the unit", style: TextStyle(color: Colors.black54),),
                  )
                ],
              ),
            ),
            Text("Individuals Tab", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                    child: Text("In the individuals tab, you can see the health information of the individual. "
                        "Each individual is represented by a tile with the their temperature in the middle, name on top, and condition is represented by a tag following this color code:\n\n"
                        "Black - ill. \nGray - potentially ill, or under recovery. \nWhite - healthy\n\n"
                        "Their temperature is displayed with colors following this color code:\n\nRed - fever. \nGreen - normal \nBlue - hypothermia\n\nTap on the individual tile to see the individual's information in detail", style: TextStyle(color: Colors.black54),),
                  )
                ],
              ),
            ),
            Text("Icons", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                    child: Text("This is the search icon, you can tap this icon to search for specific unit or individual.", style: TextStyle(color: Colors.black54),),
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
                    child: Text("This is the remind icon, you can tap this icon to see all individuals that had not taken a temperature measurement in the last 12 hours, so that you can remind them.", style: TextStyle(color: Colors.black54)),
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
                    child: Text("This is the view icon, you can tap this icon to sort the individuals/units by their health condition.", style: TextStyle(color: Colors.black54)),
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
                    child: Text("This is the Change Unit Preference button, it changes the unit you view your temperature in, "
                        "if you are on fahrenheit, it will swap to celsius and vice versa.", style: TextStyle(color: Colors.black54),),
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
                    child: Text("Pull down page to refresh data. Please remember to do so before viewing a specific individual.", style: TextStyle(color: Colors.black54)),
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
              Text("Director View", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              Card(
                child: Row(
                  children: [
                    Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Center(
                              child: Text("Mary", style: TextStyle(fontSize: 10))
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Center(
                                child: Text("# of Residents", style: TextStyle(fontSize: 7)),
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
                      child: Text("In the director view, you can see all the managers under your responsibility. "
                          "Each manager is represented by a tile with the manager name on the top and number of residents under the specific manager's responsibility."
                          " Tap on the manager tile to see all the units under the manager's responsibility", style: TextStyle(color: Colors.black54)),
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
                      child: Text("This is the search icon, you can tap this icon to search for specific manager.", style: TextStyle(color: Colors.black54),),
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
                      child: Text("This is the view icon, you can tap this icon to see all managers.", style: TextStyle(color: Colors.black54)),
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
                      child: Text("This is the Change Unit Preference button, it changes the unit you view your temperature in, "
                          "if you are on fahrenheit, it will swap to celsius and vice versa.", style: TextStyle(color: Colors.black54),),
                    )
                  ],
                ),
              ),
              Text("Units Tab", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                          child: Center(child: Text("Unit 1", style: TextStyle(fontSize: 10)))),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: Text("In the units tab, you can see all the units under your responsibility. "
                          "Each unit is represented by a tile with the unit name in the middle and its condition is represented by its color:\n\n"
                          "Black - ill. \nGray - potentially ill, or under recovery. \nWhite - healthy\n\nTap on the unit tile to see all the individuals in the unit", style: TextStyle(color: Colors.black54),),
                    )
                  ],
                ),
              ),
              Text("Individuals Tab", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                      child: Text("In the individuals tab, you can see the health information of the individual. "
                          "Each individual is represented by a tile with the their temperature in the middle, name on top, and condition is represented by a tag following this color code:\n\n"
                          "Black - ill. \nGray - potentially ill, or under recovery. \nWhite - healthy\n\n"
                          "Their temperature is displayed with colors following this color code:\n\nRed - fever. \nGreen - normal \nBlue - hypothermia\n\nTap on the individual tile to see the individual's information in detail", style: TextStyle(color: Colors.black54),),
                    )
                  ],
                ),
              ),
              Text("Other Icons", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                      child: Text("This is the search icon, you can tap this icon to search for specific unit or individual.", style: TextStyle(color: Colors.black54),),
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
                      child: Text("This is the remind icon, you can tap this icon to see all individuals that had not taken a temperature measurement in the last 12 hours, so that you can remind them.", style: TextStyle(color: Colors.black54)),
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
                      child: Text("This is the view icon, you can tap this icon to sort the individuals/units by their health condition.", style: TextStyle(color: Colors.black54)),
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
                      child: Text("Pull down page to refresh data. Please remember to do so before viewing a specific individual.", style: TextStyle(color: Colors.black54)),
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
          Text("There is a problem setting up, please delete app and reinstall. :(", style: TextStyle(fontSize: 24), textAlign: TextAlign.center,)
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
                  Text("Meet the Developers!",
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
                                    TextSpan(text: "Email:", style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: "ansuefrhua@gmail.com")
                                  ],
                                ),
                              ),
                              onTap: () async {
                                if (await canLaunch("mailto:ansuefrhua@gmail.com?subject=BugReport&body=")) {
                                  launch("mailto:ansuefrhua@gmail.com?subject=BugReport&body=").then((success) {
                                    if (!success) {
                                      Utils().errDialog("Can't send Message", "Please email through another application, sorry!", context);
                                    }
                                  });
                                } else {
                                  Utils().errDialog("Can't send Message", "Please email through another application, sorry!", context);
                                }
                              }
                            ),
                            InkWell(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 20, color: Colors.black54),
                                  children: [
                                    TextSpan(text: "Tel:", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      Utils().errDialog("Can't send Message",
                                          "Please send SMS through another application, sorry!",
                                          context);
                                    }
                                  });
                                } else {
                                  Utils().errDialog("Can't send Message",
                                      "Please send SMS through another application, sorry!",
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
                                  TextSpan(text: "Email:", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "ansuefrhua@gmail.com")
                                ],
                              ),
                            ),
                            onTap: () async {
                              if (await canLaunch("mailto:ansuefrhua@gmail.com?subject=BugReport&body=")) {
                                launch("mailto:ansuefrhua@gmail.com?subject=BugReport&body=").then((success) {
                                  if (!success) {
                                    Utils().errDialog("Can't send Message", "Please email through another application, sorry!", context);
                                  }
                                });
                              } else {
                                Utils().errDialog("Can't send Message", "Please email through another application, sorry!", context);
                              }
                            }
                        ),
                        InkWell(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 20, color: Colors.black54),
                                children: [
                                  TextSpan(text: "Tel:", style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: "1(415)769-8863")
                                ],
                              ),
                            ),
                            onTap: () async {
                              if (await canLaunch(
                                  "sms:14157698863")) {
                                launch("sms:14157698863")
                                    .then((success) {
                                  if (!success) {
                                    Utils().errDialog("Can't send Message",
                                        "Please send SMS through another application, sorry!",
                                        context);
                                  }
                                });
                              } else {
                                Utils().errDialog("Can't send Message",
                                    "Please send SMS through another application, sorry!",
                                    context);
                              }
                            }
                        )
                      ],
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text("Feel free to message us anything about this app! If you found it a bug please email us about it, "
                        "providing a thorough description and if you can attach a screenshot or screen recording of the bug. Thank you! \n\n "
                        "You can email us by clicking on their email addresses or compose a SMS by tapping on our phone numbers. \n \n"
                        "If you are not comfortable with English, you can also message or email us in Chinese! \n如果您使用中文，您可以点击以上电子邮箱"
                        "或电话号码用中文跟我们联系，谢谢！"),
                  )
                ],
              ),
          ),
        )
    );
  }
}