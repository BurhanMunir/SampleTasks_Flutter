import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:sample_tasks/ui/views/signature_display_view.dart';

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  List<Offset> _points = [];
  Uint8List? imgBytes;
  bool _isShowBtnVisible = false;

  Future<void> _captureSignature() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < _points.length - 1; i++) {
      canvas.drawLine(_points[i], _points[i + 1], paint);
    }

    final picture = recorder.endRecording();
    final img =
        await picture.toImage(300, 300); // Adjust the image size as needed
    final imgByteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = Uint8List.sublistView(imgByteData!.buffer.asUint8List());

    // Call setState to update the UI after the asynchronous operation has completed.
    setState(() {
      imgBytes = uint8List;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Signatures Here"),
          Container(
            color: Colors.grey,
            height: 300,
            width: 300,
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  RenderBox object = context.findRenderObject() as RenderBox;
                  Offset localPosition =
                      object.localToGlobal(details.localPosition);
                  if (localPosition.dx >= 0 &&
                      localPosition.dy >= 0 &&
                      localPosition.dx <= 300 &&
                      localPosition.dy <= 300) {
                    _points = List.from(_points)..add(localPosition);
                  }
                });
              },
              onPanEnd: (DragEndDetails details) =>
                  _points.add(Offset.infinite),
              child: ClipRect(
                child: Container(
                  color: Colors.amber,
                  child: CustomPaint(
                    painter: Signature(points: _points),
                    size: const Size(300, 300),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _captureSignature();
                      _isShowBtnVisible = true;
                      print(imgBytes);
                    });
                  },
                  child: const Text("Save")),
              const SizedBox(
                width: 30,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _points.clear();
                    });
                  },
                  child: const Text("Clear"))
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Visibility(
              visible: _isShowBtnVisible,
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SignatureDisplayPage(signatureBytes: imgBytes),
                        ),
                      );
                    });
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      child: const Text("Show"))))
        ]),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Signature Pad"),
      ),
    );
  }
}

class Signature extends CustomPainter {
  List<Offset> points;
  Signature({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}
