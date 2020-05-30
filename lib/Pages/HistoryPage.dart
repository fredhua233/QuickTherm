//import 'dart:math';
//
//import 'package:flutter/material.dart';
//import 'package:charts_flutter/flutter.dart';
//import 'package:charts_flutter/src/text_element.dart' as text;
//import 'package:charts_flutter/src/text_style.dart' as style;
//
//class Chart extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return LineChart(
//      _createSampleData(),
//      behaviors: [
//        LinePointHighlighter(
//            symbolRenderer: CustomCircleSymbolRenderer()
//        )
//      ],
//      selectionModels: [
//        SelectionModelConfig(
//            changedListener: (SelectionModel model) {
//              if(model.hasDatumSelection)
//                print(model.selectedSeries[0].measureFn(model.selectedDatum[0].index));
//            }
//        )
//      ],
//    );
//  }
//
//  List<Series<LinearSales, int>> _createSampleData() {
//    final data = [
//      new LinearSales(0, 5),
//      new LinearSales(1, 25),
//      new LinearSales(2, 100),
//      new LinearSales(3, 75),
//    ];
//    return [
//      new Series<LinearSales, int>(
//        id: 'Sales',
//        colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
//        domainFn: (LinearSales sales, _) => sales.year,
//        measureFn: (LinearSales sales, _) => sales.sales,
//        data: data,
//      )
//    ];
//  }
//}
//
//class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
//  @override
//  void paint(ChartCanvas canvas, Rectangle<num> bounds, {List<int> dashPattern, Color fillColor, FillPatternType fillPattern, Color strokeColor, double strokeWidthPx}) {
//    super.paint(canvas, bounds, dashPattern: dashPattern, fillColor: fillColor, fillPattern : fillPattern, strokeColor: strokeColor, strokeWidthPx: strokeWidthPx);
//    canvas.drawRect(
//        Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 10, bounds.height + 10),
//        fill: Color.white
//    );
//    var textStyle = style.TextStyle();
//    textStyle.color = Color.black;
//    textStyle.fontSize = 15;
//    canvas.drawText(
//        text.TextElement("1", style: textStyle),
//        (bounds.left).round(),
//        (bounds.top - 28).round()
//    );
//  }
//}
//class LinearSales {
//  final int year;
//  final int sales;
//  LinearSales(this.year, this.sales);
//}
//



import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/src/text_element.dart' as text;
import 'package:charts_flutter/src/text_style.dart' as style;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../Utils/UserInfo.dart';
import '../Utils/Utils.dart';

String _time;
String _temp;

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
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.landscapeRight,
//      DeviceOrientation.landscapeLeft,
//    ]);
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
      _line = _getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 350,
                  height: 400,
                  child: _graph())),

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
          LinePointHighlighter(
              symbolRenderer: CustomCircleSymbolRenderer()
          )
        ])
        : Container();
    return wid;
  }

//  @override
//  dispose() {
////    SystemChrome.setPreferredOrientations([
////      DeviceOrientation.portraitUp,
////      DeviceOrientation.portraitDown,
////    ]);
//    super.dispose();
//  }

  List<Series<TempsData, DateTime>> _getData() {
    var points = new List<TempsData>();
    Map<String, dynamic> t = _data["Temperature"];
    List<String> date = t.keys.toList();
    date.sort((a, b) => a.compareTo(b));
    for (var s in date) {
      points.add(new TempsData(DateTime.parse(s), t[s], Colors.blueAccent));
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
  }
}

enum _Mode { Week, Hour, Day }

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