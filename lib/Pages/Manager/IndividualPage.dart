

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quicktherm/Pages/LoadingPage.dart';
import 'package:flutter/cupertino.dart' as cup;
import 'package:quicktherm/Utils/Utils.dart';
import 'package:charts_flutter/flutter.dart';
// ignore: implementation_imports
import 'package:charts_flutter/src/text_element.dart' as text;
// ignore: implementation_imports
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:quicktherm/main.dart';

String _time = "N/A";
String _temp = "N/A";


class IndividualPage extends StatefulWidget {
  DocumentReference IndividualDoc;
  DocumentReference UnitDoc;

  IndividualPage(this.IndividualDoc, this.UnitDoc);

  @override
  State<StatefulWidget> createState() {
    return IndividualPageState(IndividualDoc, UnitDoc);
  }
}

class TempsData {
  final DateTime time;
  final double temp;
  final MaterialAccentColor color;

  TempsData(this.time, this.temp, MaterialAccentColor color)
      : this.color = Colors.blueAccent;
}

enum _Mode {
  Week, Hour, Day, ThreeDays, BeginningOfTime, Custom
}

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  @override
  void paint(ChartCanvas canvas, Rectangle<num> bounds, {List<int> dashPattern, Color fillColor, FillPatternType fillPattern, Color strokeColor, double strokeWidthPx}) {
    super.paint(canvas, bounds, dashPattern: dashPattern, fillColor: fillColor, fillPattern : fillPattern, strokeColor: strokeColor, strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 60, bounds.top - 30, bounds.width + 120, bounds.height + 10),
        fill: Color.fromHex(code: "#b3daff"));

    var textStyle = style.TextStyle();
    textStyle.color = Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(
        text.TextElement(_time.substring(11, 19) + " , " + _temp + String.fromCharCode(0x00B0) + UNITPREF, style: textStyle),
        (bounds.left - 58).round(),
        (bounds.top - 28).round()
    );
  }
}

class IndividualPageState extends State<IndividualPage> {
  DocumentReference IndividualDoc;
  DocumentReference UnitDoc;

  Map<String, dynamic> _userInfo;
  Map<String, dynamic> _unitInfo;
  bool _edit = false;
  String dropdownValue = "Last Day";
  String _lastMeasured, _lastTemp, _mode, _min, _max, _avg, _timeWindow = " ";
  _Mode _displayMode = _Mode.Day;
  Utils _utils = new Utils();
  List<Series<TempsData, DateTime>> _line;
  final _textController = TextEditingController();

  IndividualPageState(this.IndividualDoc, this.UnitDoc);

  _onSelectionChanged(SelectionModel model) {
    String time, temp = "N/A";
    if(model.hasDatumSelection) {
      temp = model.selectedSeries[0].measureFn(model.selectedDatum[0].index).toString();
      time = model.selectedDatum.first.datum.time.toString();
    }
    // Request a build.
    setState(() {
      _time = time;
      _temp = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  List<Series<TempsData, DateTime>> _getData(_Mode m, {String day}) {
    var points = new List<TempsData>();
    double max = double.negativeInfinity,
        min = double.infinity,
        avg, sum = 0;
    if (_userInfo != null) {
      Map<String, dynamic> t = _userInfo["Temperature"];
      List<String> date = t.keys.toList();
      date.sort((a, b) => a.compareTo(b));
      setState(() {
        _lastMeasured = date.last;
        _lastTemp = Utils().compNumTemp(t[_lastMeasured]).toString();
      });
      if (m == _Mode.BeginningOfTime) {
        for (int i = date.length - 1; i >= 0; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), Utils().compNumTemp(t[date[i]]), Colors.blueAccent));
        }
        setState(() {
          _mode = "Since Beginning of Time";
        });
      } else if (m == _Mode.Day) {
        DateTime last = DateTime.parse(date.last);
        for (int i = date.length - 1; i >= 0 && last
            .difference(DateTime.parse(date[i]))
            .inHours <= 24; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), Utils().compNumTemp(t[date[i]]), Colors.blueAccent));
        }
        setState(() {
          _mode = "Last Day";
        });
      } else if (m == _Mode.Hour) {
        DateTime last = DateTime.parse(date.last);
        for (int i = date.length - 1; i >= 0 && last
            .difference(DateTime.parse(date[i]))
            .inHours < 1; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), Utils().compNumTemp(t[date[i]]), Colors.blueAccent));
        }
        setState(() {
          _mode = "Last Hour";
        });
      } else if (m == _Mode.Week) {
        DateTime last = DateTime.parse(date.last);
        for (int i = date.length - 1; i >= 0 && last
            .difference(DateTime.parse(date[i]))
            .inDays < 7; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), Utils().compNumTemp(t[date[i]]), Colors.blueAccent));
        }
        setState(() {
          _mode = "Last Week";
        });
      } else if (m == _Mode.ThreeDays) {
        DateTime last = DateTime.parse(date.last);
        for (int i = date.length - 1; i >= 0 && last
            .difference(DateTime.parse(date[i]))
            .inDays < 3; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), Utils().compNumTemp(t[date[i]]), Colors.blueAccent));
        }
        setState(() {
          _mode = "Last 3 Days";
        });
      } else if (m == _Mode.Custom) {
        List<String> tempDay = date.where((element) => element.contains(day)).toList();
        for (var s in tempDay) {
          points.add(new TempsData(DateTime.parse(s), Utils().compNumTemp(t[s]), Colors.blueAccent));
        }
        setState(() {
          _mode = "Custom";
        });
      }
      if (points.length == 0 || points.length == 1) {
        _utils.errDialog("Not Enough Value!", "There are no measurements or not "
            "enough measurements taken in the selected time window. ", context);
      }
      for(var pt in points) {
        sum += pt.temp;
        if (pt.temp < min) {
          min = pt.temp;
        }
        if (pt.temp > max) {
          max = pt.temp;
        }
      }
      avg = sum / points.length;
      setState(() {
        _timeWindow = "(" + points.last.time.toString().substring(5, 10) + " to " + points.first.time.toString().substring(5, 10) + ")";
        _max = max.toString();
        _min = min.toString();
        _avg = avg.toString().length > 5 ? avg.toString().substring(0, 5) : avg.toString();
      });
      return [
        new Series<TempsData, DateTime>(
          id: 'Temperature',
          colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
          domainFn: (TempsData pts, _) => pts.time,
          measureFn: (TempsData pts, _) => pts.temp,
          data: points,
        )
      ];
    } else {
      return new List<Series<TempsData, DateTime>>();
    }
  }


  _inputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Input Date"),
          content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'YYYY-MM-DD',
                ),
              )
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("View"),
              onPressed: () {
                String date = _textController.text;
                setState(() {
                  _line = _getData(_displayMode, day: date);
                });
                if (_line[0].data.length == 0) {
                  _utils.errDialog("Not Enough Value!", "There are no measurements or not "
                      "enough measurements taken in the selected time window. ", context);
                }
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
  }

  Widget _graph() {
    var wid = _line != null ? TimeSeriesChart(
        _line,
        animate: true,
        primaryMeasureAxis: new NumericAxisSpec(
            tickProviderSpec: new BasicNumericTickProviderSpec(zeroBound: false)),
        selectionModels: [
          new SelectionModelConfig(
            type: SelectionModelType.info,
            changedListener: _onSelectionChanged,
          )
        ],
        behaviors: [
          new ChartTitle(_mode,
              subTitle: String.fromCharCode(0x00B0) + UNITPREF,
              behaviorPosition: BehaviorPosition.top,
              titleOutsideJustification: OutsideJustification.start,
              innerPadding: 18),
          new ChartTitle('Dates: $_timeWindow',
              behaviorPosition: BehaviorPosition.bottom,
              titleOutsideJustification:
              OutsideJustification.middleDrawArea),
          new LinePointHighlighter(
              symbolRenderer: CustomCircleSymbolRenderer()
          )
        ])
        : Container();
    return wid;
  }

  cup.Color _primaryTag() {
    if (_userInfo != null) {
      String ptag = _userInfo["Primary Tag"];
      if (ptag == Colors.black.toString()) {
        return Colors.black;
      } else if (ptag == Colors.black45.toString()) {
        return Colors.black45;
      } else if (ptag == Colors.white.toString()) {
        return Colors.white;
      }
    }
    return Colors.white;
  }

  cup.Color _secondaryTag(String tag) {
    if (UNITPREF== "C") {
      return tag != null && tag != "" && tag != " " && tag != "N/A" && (double.parse(tag) ?? 0) > 37.5 ? Colors.red :
      tag != null && tag != "" && tag != " " && tag != "N/A" && (double.parse(tag) ?? 36) < 35.0 ? Colors.blue :
      tag != null && tag != "" && tag != " " && tag != "N/A" && (double.parse(tag) ?? 90) < 37.5 && (double.parse(tag) ?? 0) > 35.0 ? Colors.green : Colors.white;
    } else {
      return tag != null && tag != "" && tag != " " && tag != "N/A" && (double.parse(tag) ?? 0) > 99.5 ? Colors.red :
      tag != null && tag != "" && tag != " " && tag != "N/A" && (double.parse(tag) ?? 96) < 95.0 ? Colors.blue :
      tag != null && tag != "" && tag != " " && tag != "N/A" && (double.parse(tag) ?? 100) < 99.5 && (double.parse(tag) ?? 0) > 95.0 ? Colors.green : Colors.white;
    }

  }

  Widget _tag(cup.Color c) {
    return Container(
        width: 50,
        height: 20,
        decoration: BoxDecoration(
            color: c,
            border: Border.all(
                color: Colors.black, width: 2, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(5)));
  }

  Future<Map<String, dynamic>> getUserData() async {
    DocumentSnapshot _userInfoSS = await IndividualDoc.get();
    DocumentSnapshot _unitInfoSS = await UnitDoc.get();

    if (_userInfoSS != null && _unitInfoSS != null) {
      _unitInfo = _unitInfoSS.data;
      _userInfo = _userInfoSS.data;
    } else {
      _utils.errDialog("Unable to get data", "Incorrect path", context);
    }
    return _userInfoSS.data;
  }

  Widget profileView(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (!snapshot.hasData || snapshot.data['Temperature'].isEmpty) {
            return LoadingPage();
          } else {
            return buildProfPage();
          }
        }
        );
  }

  Widget buildProfPage() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('Unit Name: ', style: cup.TextStyle(fontSize: 20)),
                        SizedBox(height: 10),
                        Text(' ', style: cup.TextStyle(fontSize: 20)),
                        Text(_userInfo['Unit Name'],
                            style: cup.TextStyle(fontSize: 40)),
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Last Measured: ', style: cup.TextStyle(fontSize: 20)),
                        SizedBox(height: 10),
                        Text(
                            _userInfo['Last Measured']
                                .toString()
                                .substring(0, 10),
                            style: cup.TextStyle(fontSize: 20)),
                        Text(Utils().compTemp(_userInfo['Temperature'][_userInfo['Last Measured']]),
                            style: _userInfo['Temperature']
                                        [_userInfo['Last Measured']] <
                                    35
                                ? cup.TextStyle(fontSize: 40, color: Colors.blue)
                                : _userInfo['Temperature']
                                            [_userInfo['Last Measured']] >
                                        37.5
                                    ? cup.TextStyle(fontSize: 40, color: Colors.red)
                                    : cup.TextStyle(
                                        fontSize: 40, color: Colors.green)),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _userInfo['Health Message'],
                decoration: InputDecoration(
                  labelText: 'Your current predicted condition',
                ),
                enabled: false,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _userInfo['Primary Tag'] == 'Color(0xff000000)'
                          ? Column(children: [
                              Text('Ill, seek medical help immediately')
                            ])
                          : _userInfo['Primary Tag'] == 'Color(0x73000000)'
                              ? Column(children: [
                                  Text(
                                      'Potentially sick or recovering, Medical attention suggested')
                                ])
                              : Column(
                                  children: [Text('Healthy, Stay safe!')])),
                  _tag(_primaryTag())
                ],
              ),
              Divider(
                color: Colors.blue[200],
                height: 20,
                thickness: 3,
                indent: 0,
                endIndent: 0,
              ),
              Row(
                children: [
                  Expanded(
                      child: _userInfo['Secondary Tag'].substring(29, 46) ==
                              'Color(0xfff44336)'
                          ? Column(children: [
                              Text(
                                  'High Temperature, Potentially Fever or COVID-19')
                            ])
                          : _userInfo['Secondary Tag'].substring(29, 46) ==
                                  'Color(0xff2196f3)'
                              ? Column(children: [
                                  Text(
                                      'Low Temperature, Potentially hypothermia')
                                ])
                              : Column(children: [
                                  Text('Normal Temperature, Keep it up!')
                                ])),
                  _tag(_secondaryTag(_userInfo['Temperature']
                          [_userInfo['Last Measured']]
                      .toString())),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: _userInfo['Prior Medical Condition'] == false
                    ? 'None'
                    : _userInfo['Prior Medical Condition'],
                decoration: InputDecoration(
                  labelText: 'Pre-existing health conditions',
                  hintText: 'Please briefly describe your conditions',
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                enabled: _edit,
                onChanged: (val) => setState(() {
                  val == ' ' || val == ''
                      ? _userInfo['Prior Medical Condition'] = false
                      : _userInfo['Prior Medical Condition'] = val;
                }),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.person),
                  Text('Name: '),
                  Spacer(),
                  Text(_userInfo['Name'])
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone),
                  Text('Contact: '),
                  Spacer(),
                  Text(_userInfo['Contacts'])
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today),
                  Text('Date of birth: '),
                  Spacer(),
                  Text((_userInfo['Date of Birth'] as String).substring(0,10))
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Age:'),
                  Spacer(),
                  Text((DateTime.now().difference(DateTime.parse(_userInfo['Date of Birth'])).inDays / 365).floor().toString()),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Sex:'),
                  Spacer(),
                  Text(_userInfo['Sex'])
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Address in ${_userInfo['Organization']}:'),
                  Spacer()
                ],
              ),
              SizedBox(height: 7),
              Text(_userInfo['Address']),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Managed by: '),
                  Spacer(),
                  Text(_userInfo['Manager Name']),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Temperature trend:'),
                  Spacer(),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 14,
                    elevation: 16,
                    style: cup.TextStyle(color: Colors.black),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        switch (newValue) {
                          case 'Last Hour':
                            _displayMode = _Mode.Hour;
                            _line = _getData(_displayMode);
                            break;
                          case 'Last Day':
                            _displayMode = _Mode.Day;
                            _line = _getData(_displayMode);
                            break;
                          case 'Last Three Days':
                            _displayMode = _Mode.ThreeDays;
                            _line = _getData(_displayMode);
                            break;
                          case 'Last Week':
                            _displayMode = _Mode.Week;
                            _line = _getData(_displayMode);
                            break;
                          case 'Beginning of Time':
                            _displayMode = _Mode.BeginningOfTime;
                            _line = _getData(_displayMode);
                            break;
                          case 'Custom':
                            _displayMode = _Mode.Custom;
                            _inputDialog();
                            break;
                        }
                      });
                    },
                    items: <String>['Last Hour', 'Last Day', 'Last Three Days', 'Last Week', 'Beginning of Time', 'Custom']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                ],
              ),
              Center(
                  child: Container(
                      width: 350,
                      height: 400,
                      child: _graph())),
            ],
          ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: profileView(context),
    );
  }
}

