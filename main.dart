import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class Pimple {
  Offset position;
  double size;
  bool popped;

  Pimple(this.position, this.size, this.popped);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PimplePopperApp(),
    );
  }
}

class PimplePopperApp extends StatefulWidget {
  @override
  _PimplePopperAppState createState() => _PimplePopperAppState();
}

class _PimplePopperAppState extends State<PimplePopperApp> {
  List<Pimple> pimples = [];
  final GlobalKey _circleAvatarKey = GlobalKey();

  double _horizontalScale = 1.0;
  double _verticalScale = 1.0;
  double _previousHorizontalScale = 1.0;
  double _previousVerticalScale = 1.0;
  Offset _previousOffset = Offset(0, 0);
  Offset _offset = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    generateRandomPimples();
  }

  void generateRandomPimples() {
    final random = Random();
    final numPimples = random.nextInt(8) + 3; // Generate between 3 and 10 pimples
    pimples.clear();

    for (int i = 0; i < numPimples; i++) {
      pimples.add(
        Pimple(
          Offset(
            random.nextDouble() * 400 + 50,
            random.nextDouble() * 400 + 50,
          ),
          20.0,
          false,
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pimple Popper App'),
      ),
      body: Center(
        child: GestureDetector(
          onScaleUpdate: (ScaleUpdateDetails details) {
            print('Number of pointers: ${details.pointerCount}');

            if (details.pointerCount == 2) {
              _horizontalScale = (_previousHorizontalScale * details.horizontalScale).clamp(0.5, 2.0);
              _verticalScale = (_previousVerticalScale * details.verticalScale).clamp(0.5, 2.0);
            }

            if (details.pointerCount == 1) {
              _offset = (_previousOffset + details.localFocalPoint - _previousOffset);
            }

            setState(() {
              _previousHorizontalScale = _horizontalScale;
              _previousVerticalScale = _verticalScale;
              _previousOffset = _offset;
            });
          },
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_horizontalScale, _verticalScale),
            child: Stack(
              children: [
                // Draw the face with CustomPainter
                CircleAvatar(
                  key: _circleAvatarKey,
                  radius: 250,
                  backgroundColor: Colors.yellow,
                  child: CustomPaint(
                    painter: FacePainter(),
                  ),
                ),
                // Draw pimples
                for (var pimple in pimples)
                  Positioned(
                    left: pimple.position.dx - pimple.size / 2,
                    top: pimple.position.dy - pimple.size / 2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          // Single tap on a pimple, pop it
                          pimple.popped = true;
                        });
                      },
                      onDoubleTap: () {
                        setState(() {
                          // Double tap on a pimple, increase size
                          pimple.size *= 1.25;
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          // Long press on a pimple, delete it
                          pimples.remove(pimple);
                        });
                      },
                      child: Container(
                        width: pimple.size,
                        height: pimple.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pimple.popped ? Colors.white : Colors.red,
                          border: Border.all(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            generateRandomPimples();
          });
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    //eyes
    canvas.drawCircle(Offset(-40, -40), 20, paint);
    canvas.drawCircle(Offset(40, -40), 20, paint);

    //mouth
    canvas.drawRect(
      Rect.fromPoints(Offset(-100, 20), Offset(100, 60)),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
