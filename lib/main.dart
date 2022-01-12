import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class DrawingArea {
  late Offset point;
  late Paint areaPaint;

  DrawingArea({required this.point, required this.areaPaint});
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final
  List<DrawingArea> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  void selectColor() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Color Chooser'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  this.setState(() {
                    selectedColor = color;
                  });
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(169, 241, 223, 1.0),
                    Color.fromRGBO(255, 187, 187, 1.0),
                  ]),
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width * 0.80,
                  height: height * 0.80,
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                        )
                      ]),
                  child: GestureDetector(
                    onPanDown: (details) {
                      setState(() {
                        points.add(DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        points.add(DrawingArea(
                            point: details.localPosition,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        Offset Nopoint = Offset(-100.0, -100.0);
                        points.add(DrawingArea(
                            point: Nopoint,
                            areaPaint: Paint()
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth));
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      child: CustomPaint(
                        painter: MyCustomPainter(
                            points: points,
                            color: selectedColor,
                            strokeWidth: strokeWidth),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Container(
                  width: width * 0.80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            selectColor();
                          },
                          icon: Icon(
                            Icons.color_lens,
                          )),
                      Expanded(
                          child: Slider(
                              min: 1.0,
                              max: 7.0,
                              value: strokeWidth,
                              onChanged: (value) {
                                this.setState(() {
                                  strokeWidth = value;
                                });
                              })),
                      IconButton(
                          onPressed: () {
                            this.setState(() {
                              points.clear();
                            });
                          },
                          icon: const Icon(Icons.layers_clear)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> points;
  Color color;
  double strokeWidth;
  Offset Nopoint = Offset(-100.0, -100.0);

  MyCustomPainter(
      {required this.points, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);

    for (int x = 0; x < points.length - 1; x++) {
      if (points[x].point != Nopoint && points[x + 1].point != Nopoint) {
        Paint paint = points[x].areaPaint;
        canvas.drawLine(points[x].point, points[x + 1].point, paint);
      } else if (points[x].point != Nopoint && points[x + 1].point == Nopoint) {
        Paint paint = points[x].areaPaint;
        canvas.drawPoints(PointMode.points, [points[x].point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
