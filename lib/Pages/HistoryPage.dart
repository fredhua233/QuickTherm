import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/src/text_element.dart' as text;
import 'package:charts_flutter/src/text_style.dart' as style;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart' as cup;

import '../Utils/UserInfo.dart';
import '../Utils/Utils.dart';

String _time = "N/A";
String _temp = "N/A";


//FIXME: add points on graph?

class HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HistoryPageState();
}

// Graph of previous temperatures, time window, 1 month, 1 week, 1 day, 1 hour
class HistoryPageState extends State<HistoryPage> {
  UserInfo _user = new UserInfo();
  Utils _utils = new Utils();
  DocumentReference _log;
  Map<String, dynamic> _data;
  List<Series<TempsData, DateTime>> _line;
  _Mode _displayMode = _Mode.Day;

  String _lastMeasured = "";
  String dropdownValue = "Last Day";
  final _textController = TextEditingController();


  _onSelectionChanged(SelectionModel model) {
    String time, temp = "";
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
    _init();
  }

  _init() async {
    // Sets up fire base
    _log = _user.log;
    DocumentSnapshot doc = await _log.get();
    if (doc != null) {
      _data = doc.data;
    } else {
      _utils.errDialog("Unable to get data", "Incorrect path", context);
    }
    setState(() {
      _line = _getData(_displayMode);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              ButtonBar(
                alignment: MainAxisAlignment.start,
                buttonAlignedDropdown: true,
                children: <Widget>[
                  DropdownButton<String>(
                  value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
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
                          case 'Custom':
                            _displayMode = _Mode.Custom;
                            _inputDialog();
                            break;
                        }
                      });
                    },
                    items: <String>['Last Hour', 'Last Day', 'Last Three Days', 'Last Week', 'Custom']
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
              Align(
                alignment: cup.Alignment.topLeft,
                child: Padding(
                  padding: new EdgeInsets.only(top: 5.0, left: 10.0),
                  child: new Text("(Date : Temperature): " , style: new cup.TextStyle(fontSize: 15),))
              ),
              Align(
                  alignment: cup.Alignment.topLeft,
                  child: Padding(
                      padding: new EdgeInsets.only(top: 5.0, left: 10.0),
                      child: _time != null && _temp != null ? new Text(_time + " : " + _temp +  String.fromCharCode(0x00B0) + "C") : new Text(" "))
              )
            ],
        )
      )
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
          new ChartTitle('Date v Temperature',
              subTitle: String.fromCharCode(0x00B0) + "C",
              behaviorPosition: BehaviorPosition.top,
              titleOutsideJustification: OutsideJustification.start,
              innerPadding: 18),
          new ChartTitle('Date',
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

  List<Series<TempsData, DateTime>> _getData(_Mode m, {String day}) {
    var points = new List<TempsData>();
    if (_data != null) {
      Map<String, dynamic> t = _data["Temperature"];
      List<String> date = t.keys.toList();
      date.sort((a, b) => a.compareTo(b));
      setState(() {
        _lastMeasured = date.last;
      });
      if (m == _Mode.BeginningOfTime) {
        for (var s in date) {
          points.add(new TempsData(DateTime.parse(s), t[s], Colors.blueAccent));
        }
      } else if (m == _Mode.Day) {
        DateTime last = DateTime.parse(date.last);
        for (int i = date.length - 1; i >= 0 && last
            .difference(DateTime.parse(date[i]))
            .inDays <= 1; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), t[date[i]], Colors.blueAccent));
        }
      } else if (m == _Mode.Hour) {
        DateTime last = DateTime.parse(date.last);
        for (int i = date.length - 1; i >= 0 && last
            .difference(DateTime.parse(date[i]))
            .inHours <= 1; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), t[date[i]], Colors.blueAccent));
        }
      } else if (m == _Mode.Week) {
        DateTime last = DateTime.parse(date.last);
        for (int i = date.length - 1; i >= 0 && last
            .difference(DateTime.parse(date[i]))
            .inDays <= 7; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), t[date[i]], Colors.blueAccent));
        }
      } else if (m == _Mode.ThreeDays) {
        DateTime last = DateTime.parse(date.last);
        for (int i = date.length - 1; i >= 0 && last
            .difference(DateTime.parse(date[i]))
            .inDays <= 3; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), t[date[i]], Colors.blueAccent));
        }
      } else if (m == _Mode.Custom) {
        List<String> tempDay = date.where((element) => element.contains(day)).toList();
        for (var s in tempDay) {
          points.add(new TempsData(DateTime.parse(s), t[s], Colors.blueAccent));
        }
      }
      if (points.length == 0 || points.length == 1) {
        _utils.errDialog("Not Enough Value!", "There are no measurements or not "
            "enough measurements taken in the selected time window. ", context);
      }
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
                print("Date");
                print(date);
                setState(() {
                  _line = _getData(_displayMode, day: date);
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
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

enum _Mode { Week, Hour, Day, ThreeDays, BeginningOfTime, Custom}

class TempsData {
  final DateTime time;
  final double temp;
  final MaterialAccentColor color;

  TempsData(this.time, this.temp, MaterialAccentColor color)
      : this.color = Colors.blueAccent;
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
        text.TextElement(_time.substring(11, 19) + " , " + _temp + String.fromCharCode(0x00B0) + "C", style: textStyle),
        (bounds.left - 58).round(),
        (bounds.top - 28).round()
    );
  }
}