import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as cup;

import 'package:charts_flutter/flutter.dart';
// ignore: implementation_imports
import 'package:charts_flutter/src/text_element.dart' as text;
// ignore: implementation_imports
import 'package:charts_flutter/src/text_style.dart' as style;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quicktherm/main.dart';

import 'package:url_launcher/url_launcher.dart';
import '../Utils/UserInfo.dart';
import '../Utils/Utils.dart';

String _time = Utils.translate("N/A");
String _temp = Utils.translate("N/A");



//FIXME: replace dash with slash

class HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HistoryPageState();
}

// Graph of previous temperatures, time window, 1 month, 1 week, 1 day, 1 hour
class HistoryPageState extends State<HistoryPage> {
  UserInfo _user = new UserInfo.defined();
  Utils _utils = new Utils();
  DocumentReference _log;
  Map<String, dynamic> _data;
  List<Series<TempsData, DateTime>> _line;
  _Mode _displayMode = _Mode.Day;

  String _lastMeasured, _lastTemp, _mode, _min, _max, _avg, _timeWindow = " ";
  String dropdownValue = Utils.translate("Last Day");
  final _textController = TextEditingController();


  _onSelectionChanged(SelectionModel model) {
    String time, temp = Utils.translate("N/A");
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
      _utils.errDialog(Utils.translate("Unable to get data"), Utils.translate("Incorrect path"), context);
    }
    setState(() {
      _line = _getData(_displayMode);
      _time = Utils.translate("N/A");
      _temp = Utils.translate("N/A");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Utils.translate("History")),
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
                        if (newValue == Utils.translate('Last Hour')) {
                          _displayMode = _Mode.Hour;
                          _line = _getData(_displayMode);
                        } else if (newValue == Utils.translate('Last Day')) {
                          _displayMode = _Mode.Day;
                          _line = _getData(_displayMode);
                        } else if (newValue == Utils.translate('Last Three Days')) {
                          _displayMode = _Mode.ThreeDays;
                          _line = _getData(_displayMode);
                        } else if (newValue == Utils.translate('Last Week')) {
                          _displayMode = _Mode.Week;
                          _line = _getData(_displayMode);
                        } else if (newValue == Utils.translate('Beginning of Time')) {
                          _displayMode = _Mode.BeginningOfTime;
                          _line = _getData(_displayMode);
                        } else {
                          _displayMode = _Mode.Custom;
                          _inputDialog();
                        }
                      });
                    },
                    items: <String>[Utils.translate('Last Hour'), Utils.translate('Last Day'), Utils.translate('Last Three Days'), Utils.translate('Last Week'), Utils.translate('Beginning of Time'), Utils.translate('Custom')]
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
                alignment: cup.FractionalOffset(0.04,0),
                child: Padding(
                  padding: new EdgeInsets.only(top: 15.0),
                  child: new Text(Utils.translate("Selected point: ") , style: new cup.TextStyle(fontSize: 16),))
              ),
              Align(
                  alignment: cup.Alignment.topCenter,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: cup.FractionalOffset(0.04,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: _time != null && _time != Utils.translate("N/A")? new Text(_time.substring(0, 19)) : new Text(Utils.translate("N/A"))),
                      ),
                      Align(
                          alignment: cup.FractionalOffset(0.75,0),
                          child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: _tag(_secondaryTag(_temp)))
                          ),
                      Align(
                        alignment: cup.FractionalOffset(0.975,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child:  _temp != null ? new Text(_temp +  String.fromCharCode(0x00B0) + UNITPREF) : new Text(" ")),
                      ),
                    ],
                  )
              ),
              Divider(
                color: Colors.blue[200],
                height: 20,
                thickness: 3,
                indent: 0,
                endIndent: 0,
              ),
              Align(
                  alignment: cup.FractionalOffset(0.04,0),
                  child: Padding(
                      padding: new EdgeInsets.only(top: 30.0),
                      child: new Text(Utils.translate("Statistics") + " \n" + _timeWindow, style: new cup.TextStyle(fontSize: 17),))
              ),
              Align(
                  alignment: cup.Alignment.topCenter,
                  child: Stack(
                    children: <Widget>[
                      Align(
                          alignment: cup.FractionalOffset(0.175,0),
                          child: Padding(
                              padding: new EdgeInsets.only(top: 10.0),
                              child: _tag(_secondaryTag(_avg)))
                      ),
                      Align(
                        alignment: cup.FractionalOffset(0.04,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: new Text(Utils.translate("Avg"))),
                      ),
                      Align(
                          alignment: cup.FractionalOffset(0.575,0),
                          child: Padding(
                              padding: new EdgeInsets.only(top: 10.0),
                              child: _tag(_secondaryTag(_max)))
                      ),
                      Align(
                        alignment: cup.FractionalOffset(0.45,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: new cup.Text(Utils.translate("Max")))
                      ),
                      Align(
                          alignment: cup.FractionalOffset(0.98,0),
                          child: Padding(
                              padding: new EdgeInsets.only(top: 10.0),
                              child: _tag(_secondaryTag(_min)))
                      ),
                      Align(
                        alignment: cup.FractionalOffset(0.875,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child:  new Text(Utils.translate("Min"))),
                      ),
                    ],
                  )
              ),
              Align(
                  alignment: cup.Alignment.topCenter,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: cup.FractionalOffset(0.04,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: _avg != null ? new Text(_avg + String.fromCharCode(0x00B0) + UNITPREF) : Text("")),
                      ),
                      Align(
                          alignment: cup.FractionalOffset(0.5,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: _max != null ? new Text(_max + String.fromCharCode(0x00B0) + UNITPREF) : Text(""))
                      ),
                      Align(
                        alignment: cup.FractionalOffset(0.975,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: _min != null ? new Text(_min + String.fromCharCode(0x00B0) + UNITPREF) : Text(""))
                      ),
                    ],
                  )
              ),
              Divider(
                color: Colors.blue[200],
                height: 20,
                thickness: 3,
                indent: 0,
                endIndent: 0,
              ),
              Align(
                  alignment: cup.FractionalOffset(0.04,0),
                  child: Padding(
                      padding: new EdgeInsets.only(top: 30.0),
                      child: new Text(Utils.translate("Last Measurement:") , style: new cup.TextStyle(fontSize: 17),))
              ),
              Align(
                  alignment: cup.Alignment.topCenter,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: cup.FractionalOffset(0.04,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: new Text(Utils.translate("Time"))),
                      ),
                      Align(
                        alignment: cup.FractionalOffset(0.975,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child:  new Text(Utils.translate("Temperature"))),
                      ),
                    ],
                  )
              ),
              Align(
                  alignment: cup.Alignment.topCenter,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: cup.FractionalOffset(0.04,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: _lastMeasured != null && _lastMeasured.length > 19? new Text(_lastMeasured.substring(0, 19)) : Text("")),
                      ),
                      Align(
                          alignment: cup.FractionalOffset(0.625,0),
                          child: Padding(
                              padding: new EdgeInsets.only(top: 10.0),
                              child: _tag(_primaryTag())),
                      ),
                      Align(
                        alignment: cup.FractionalOffset(0.725,0),
                        child: Padding(
                            padding: new EdgeInsets.only(top: 10.0),
                            child: _tag(_secondaryTag(_lastTemp))),
                      ),
                      Align(
                          alignment: cup.FractionalOffset(0.975,0),
                          child: Padding(
                              padding: new EdgeInsets.only(top: 10.0),
                              child: _lastTemp != null ? new Text(_lastTemp + String.fromCharCode(0x00B0) + UNITPREF) : Text(""))
                      ),
                    ],
                  )
              ),
              Divider(
                color: Colors.blue[200],
                height: 20,
                thickness: 3,
                indent: 0,
                endIndent: 0,
              ),
              Align(
                  alignment: cup.FractionalOffset(0.04,0),
                  child: Padding(
                      padding: new EdgeInsets.only(top: 30.0),
                      child: new Text(Utils.translate("About the Coronavirus (COVID-19)") , style: new cup.TextStyle(fontSize: 17)))
              ),
              Align(
                  alignment: cup.FractionalOffset(0.04,0),
                  child: Padding(
                      padding: new EdgeInsets.only(top: 30.0, bottom: 20),
                      child:new InkWell(
                          child: new Text(Utils.translate('Learn more (tap here) at:') + ' https://www.cdc.gov/coronavirus/2019-ncov/'),
                          onTap: () => _launchInBrowser("https://www.cdc.gov/coronavirus/2019-ncov/")
                      )
                  ),
              ),
            ],
        )
      )
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        enableJavaScript: true,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      _utils.errDialog(Utils.translate("Unable to Open Link"), Utils.translate("Sorry, please navigate to link using the default browser of your device."), context);
    }
  }

  //Gets color of secondary tag
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


  //Gets the color of primary tag
  cup.Color _primaryTag() {
    if (_data != null) {
      String ptag = _data["Primary Tag"];
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
  //Creates tag
  Widget _tag(cup.Color c) {
    return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            color: c,
            border: Border.all(
                color: Colors.black,
                width: 2,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(5)));
  }

  //creates and returns the graph
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
          new ChartTitle(Utils.translate('Date'),
              subTitle: _timeWindow,
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

  //Gets data depending on mode
  List<Series<TempsData, DateTime>> _getData(_Mode m, {String day}) {
    var points = new List<TempsData>();
    double max = double.negativeInfinity,
           min = double.infinity,
           avg, sum = 0;
    if (_data != null) {
      Map<String, dynamic> t = _data["Temperature"];
      List<String> date = t.keys.toList();
      date.sort((a, b) => a.compareTo(b));
      setState(() {
        _lastMeasured = date.last;
        _lastTemp = Utils().compNumTemp(t[_lastMeasured]).toString();
      });
      if (m == _Mode.BeginningOfTime) {
        for (int i = date.length - 1; i >= 0; i--) {
          points.add(new TempsData(
              DateTime.parse(date[i]), t[date[i]], Colors.blueAccent));
        }
        setState(() {
          _mode = Utils.translate("Beginning of Time");
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
          _mode = Utils.translate("Last Day");
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
          _mode = Utils.translate("Last Hour");
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
          _mode = Utils.translate("Last Week");
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
          _mode = Utils.translate("Last Three Days");
        });
      } else if (m == _Mode.Custom) {
        List<String> tempDay = date.where((element) => element.contains(day)).toList();
        for (var s in tempDay) {
          points.add(new TempsData(DateTime.parse(s), Utils().compNumTemp(t[s]), Colors.blueAccent));
        }
        setState(() {
          _mode = Utils.translate("Custom");
        });
      }
      if (points.length == 0 || points.length == 1) {
        _utils.errDialog(Utils.translate("Not Enough Value!"), Utils.translate("There are no measurements or not enough measurements taken in the selected time window. "), context);
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
        _timeWindow = "(" + points.last.time.toString().substring(5, 10) + Utils.translate(" to ") + points.first.time.toString().substring(5, 10) + ")";
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
          title: new Text(Utils.translate("Input Date")),
          content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: Utils.translate('YYYY-MM-DD'),
                ),
              )
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text(Utils.translate("View")),
              onPressed: () {
                String date = _textController.text;
                setState(() {
                  _line = _getData(_displayMode, day: date);
                });
                if (_line[0].data.length == 0) {
                  _utils.errDialog(Utils.translate("Not Enough Value!"), Utils.translate("There are no measurements or not enough measurements taken in the selected time window. "), context);
                }
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text(Utils.translate("Close")),
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

enum _Mode {
  Week, Hour, Day, ThreeDays, BeginningOfTime, Custom
}

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
        text.TextElement(_time.substring(11, 19) + " , " + _temp + String.fromCharCode(0x00B0) + UNITPREF, style: textStyle),
        (bounds.left - 58).round(),
        (bounds.top - 28).round()
    );
  }
}