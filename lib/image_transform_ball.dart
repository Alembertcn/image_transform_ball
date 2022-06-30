library image_transform_ball;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class ImageTransformBallWidget extends StatefulWidget {
  Size? size;
  String assetImage;
  int jd;
  ImageTransformBallWidget(
      {required this.assetImage, this.size, this.jd = 3, Key? key})
      : super(key: key);

  @override
  State<ImageTransformBallWidget> createState() =>
      _ImageTransformBallWidgetState();
}

class _ImageTransformBallWidgetState extends State<ImageTransformBallWidget> {
  var rx = 0.0, ry = 0.0;
  Offset _offset = Offset.zero;
  var positions = [];

  @override
  void didUpdateWidget(covariant ImageTransformBallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetImage != widget.assetImage) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print('widget build');
    return Container(
      child: FutureBuilder<List>(
        future: loadPositionByImage(),
        builder: (context, snapshot) => snapshot.hasData
            ? Center(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    print('onPanUpdate');
                    setState(() {
                      _offset += details.delta;
                    });
                  },
                  child: CustomPaint(
                    size: widget.size ?? Size(180, 180),
                    painter: BallPainter(
                        _offset.dy * 0.005, -_offset.dx * 0.005, snapshot.data),
                  ),
                ),
              )
            : Container(),
      ),
    );
  }

  Future<List> loadPositionByImage() async {
    print('loadPositionByImage');
    Completer<List> completer = Completer();
    var image = AssetImage(widget.assetImage);
    image
        .load(
            await image.obtainKey(ImageConfiguration.empty),
            (bytes, {cacheWidth, cacheHeight, allowUpscaling = false}) =>
                ui.instantiateImageCodec(bytes))
        .addListener(
            ImageStreamListener((ImageInfo image, bool synchronousCall) async {
      var imgWidth = image.image.width;
      var imgHeight = image.image.height;
      var positons = [];

      var res = await image.image.toByteData();
      if (res != null) {
        var list = res.buffer.asUint8List();
        var totalPoint = list.length / 4;
        var u, v;
        for (var i = 0; i < totalPoint; i++) {
          u = i % imgWidth; // 横坐标
          v = i ~/ imgWidth; // 纵坐标
          if (u % widget.jd == 0 &&
              v % widget.jd == 0 &&
              isNotWidth(list[i * 4], list[i * 4 + 1], list[i * 4 + 2],
                  list[i * 4 + 3])) {
            var jd = pi * 2 / imgWidth * u - pi;
            var wd = pi / imgHeight * v - pi / 2;
            positons.add({jd, wd});
          }
        }
        completer.complete(positons);
      } else {
        completer.completeError({'msg': 'load error'});
      }
    }));
    return completer.future;
  }

  bool isNotWidth(int? a, int? r, int? g, int? b) {
    return (a ?? 0) < 205 || (r ?? 0) < 205 || (g ?? 0) < 205 || (b ?? 0) < 205;
  }
}

class BallPainter extends CustomPainter {
  final rx, ry;
  var r = 180.0;

  // 经纬度坐标
  var positions;
  BallPainter(this.rx, this.ry, this.positions);

  @override
  void paint(Canvas canvas, Size size) {
    r = min(size.width, size.height) > 0 ? min(size.width, size.height) : r;

    canvas.translate(size.center(Offset.zero).dx, size.center(Offset.zero).dy);
    //画图坐标
    positions.forEach((element) {
      var jd = element.first;
      var wd = element.last;

      var x = cos(jd) * cos(wd) * r;
      var y = sin(jd) * cos(wd) * r;
      var z = sin(wd) * r;

      var rxx = x;
      var rxy = cos(rx) * y + sin(rx) * z;
      var rxz = -sin(rx) * y + cos(rx) * z;

      var ryx = rxx * cos(ry) - sin(ry) * rxz;
      var ryy = rxy;
      var ryz = sin(ry) * rxx + cos(ry) * rxz;

      canvas.drawCircle(
          Offset(ryx, ryy),
          1,
          Paint()
            ..color = ryz > 0 ? Colors.blue : Colors.blue.withOpacity(0.15));
    });

    // 画一个球
    // for (var i = 0; i < 100; i++) {
    //   var theta = pi / 100 * i - pi / 2; //[-pi/2,pi/2]

    // for (var j = 0; j < 100; j++) {
    //   var fai = 2 * pi / 100 * j - pi; //[-pi,pi]

    //   var x = r * cos(theta) * sin(fai);
    //   var y = r * cos(theta) * cos(fai);
    //   var z = r * sin(theta);
    //   //  1   0   0     0
    //   //  0   cos -sin  0
    //   //  0   sin cos   0
    //   //  0   0   0     1
    //   var rxx = x;
    //   var rxy = cos(rx) * y - sin(rx) * z;
    //   var rxz = sin(rx) * y + cos(rx) * z;

    //   canvas.drawCircle(Offset(rxx, rxy), 1,
    //       Paint()..color = rxz > 0 ? Colors.black : Colors.black12);
    // }
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
