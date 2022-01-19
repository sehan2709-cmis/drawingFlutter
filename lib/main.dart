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


  Widget close = Icon(Icons.close, color: Colors.white);

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
              // child: BlockPicker(
              //   pickerColor: selectedColor,
              //   onColorChanged: (color) {
              //     this.setState(() {
              //       selectedColor = color;
              //     });
              //   },
              // ),


              child: ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  this.setState(
                    () {
                      selectedColor = color;
                    },
                  );
                },
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),

            // child: MaterialPicker(
            //    pickerColor: selectedColor,
            //    onColorChanged: (color) {
            //           this.setState(
            //             () {
            //               selectedColor = color;
            //             },
            //           );
            //         },
            //    showLabel: true, // only on portrait mode
             //),

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
    List<Widget> menus = [
      IconButton(
          onPressed: () {
            selectColor();
          },
          icon: const Icon(
            Icons.color_lens,
          )),
      Slider(
          min: 1.0,
          max: 7.0,
          value: strokeWidth,
          onChanged: (value) {
            setState(() {
              strokeWidth = value;
            });
          }
      ),
      IconButton(
          onPressed: () {
            this.setState(() {
              points.clear();
            });
          },
          icon: const Icon(Icons.layers_clear)),
    ];

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
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 20.0,
                  child: JamesBar(
                      color: Colors.orange,
                      closeIcon: this.close,
                      items: menus,
                      cb: (int i) => print(i)),
                ),
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


class JamesBar extends StatefulWidget {
  final Axis axis;
  final Widget closeIcon;
  final List<Widget> items;
  final void Function(int) cb;
  final Color color;

  const JamesBar({
    Key? key,
    this.axis = Axis.horizontal,
    required this.closeIcon,
    required this.items,
    required this.cb,
    required this.color,
  }) : super(key: key);

  @override
  State<JamesBar> createState() => _JamesBarState();
}

class _JamesBarState extends State<JamesBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _act;
  Animation<double>? _anim;

  bool check = false;

  @override
  void initState() {
    this._act =
    AnimationController(vsync: this, duration: Duration(milliseconds: 300))
      ..addListener(() {
        if (!this.mounted) return;
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    this._act?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => this._horizontal(context);

  Widget _trigger() => IconButton(
    icon: this.widget.closeIcon as Icon,
    onPressed: () {
      if (!check) {
        this._act?.forward();
      } else {
        this._act?.reverse();
      }
      this.check = !this.check;
    },
  );

  Widget _horizontal(BuildContext context) {
    this._anim =
        Tween<double>(begin: MediaQuery.of(context).size.width * 0.87, end: 0)
            .animate(_act!);
    return Transform.translate(
      offset: Offset(this._anim?.value ?? 0, 0),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 60.0),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        elevation: 4.0,
        color: this.widget.color,
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            height: 80.0,
            child: Container(
              child: Row(
                children: [
                  Container(child: this._trigger()),
                  Expanded(
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [...this._bar()],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  List<Widget> _bar() => this
      .widget
      .items
      .map<Widget>((Widget item) => InkWell(
    onTap: () => this.widget.cb(widget.items.indexOf(item)),
    child: item,
  ))
      .toList();
}