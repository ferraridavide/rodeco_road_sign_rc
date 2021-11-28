import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as IOImage;

class RilevamentoResult {
  RilevamentoResult(this.photoPath, this.values);
  String photoPath;
  List<String> values;
}

class RilevamentoView extends StatefulWidget {
  const RilevamentoView(this.aspectRatio, this.blockPerc, {Key? key})
      : super(key: key);
  final List<List<double>> blockPerc;
  final double aspectRatio;

  @override
  _RilevamentoViewState createState() => _RilevamentoViewState();
}

class _RilevamentoViewState extends State<RilevamentoView>
    with WidgetsBindingObserver {
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    loadCamera();
  }

  void loadCamera() async {
    controller = CameraController(
        (await availableCameras())[0], ResolutionPreset.max,
        enableAudio: false);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator()));
    }

    return GestureDetector(
      onTap: () => scattaFoto(widget.blockPerc, widget.aspectRatio),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              FittedBox(
                clipBehavior: Clip.antiAlias,
                fit: BoxFit.contain,
                child: SizedBox(
                  height: controller!.value.previewSize!.width,
                  width: controller!.value.previewSize!.height,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      CameraPreview(controller!),
                      new CustomPaint(
                        painter: new CameraGuidelines(widget.aspectRatio,
                            targets: widget.blockPerc,
                            paintColor: Colors.yellow.withOpacity(0.75)),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: RawMaterialButton(
                  onPressed: () =>
                      scattaFoto(widget.blockPerc, widget.aspectRatio),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.camera,
                    size: 35.0,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<RilevamentoResult> _scanImage(
      List<List<double>> blockPerc, double aspectRatio) async {
    final picture = await takePicture();

    IOImage.Image image =
        IOImage.decodeImage(new File(picture!.path).readAsBytesSync())!;
    final inputImage = InputImage.fromFilePath(picture.path);
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);

    final values = blockPerc.map<String>((perc) {
      final target = getTarget(perc[0], perc[1], aspectRatio,
          max(image.height, image.width), min(image.height, image.width));
      final blocks = recognisedText.blocks;
      blocks.sort((a, b) =>
          ((a.rect.center - target).distance.toInt()) -
          ((b.rect.center - target).distance.toInt()));
      return blocks.first.text;
    }).toList();

    textDetector.close();

    return RilevamentoResult(picture.path, values);
  }

  scattaFoto(List<List<double>> blockPerc, double aspectRatio) async {
    try {
      Navigator.pop(context, await _scanImage(blockPerc, aspectRatio));
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
          (SnackBar(content: Text("Errore nella rilevazione, riprovare"))));
      print("ERROR");
    }
  }

  Offset getTarget(double xPerc, double yPerc, double aspectRatio,
      int imgHeight, int imgWidth) {
    final shownWidth = imgWidth;
    final shownHeight = (imgWidth / (aspectRatio));
    final shownX = (imgWidth - shownWidth) / 2;
    final shownY = (imgHeight - shownHeight) / 2;

    final areaWidth = shownWidth * 0.8;
    final areaHeight = shownHeight * 0.8;
    final areaX = shownX + ((shownWidth - areaWidth) / 2);
    final areaY = shownY + ((shownHeight - areaHeight) / 2);

    final targetX = areaX + (areaWidth * xPerc);
    final targetY = areaY + (areaHeight * yPerc);

    return Offset(targetX, targetY);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(controller!.description);
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    await controller!.dispose();
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {}
    });

    await cameraController.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      print("Select a camera first!");
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();

      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    print(e.description);
  }
}

class CameraGuidelines extends CustomPainter {
  CameraGuidelines(this.aspectRatio,
      {this.zoomFactor = 0.8,
      this.targets,
      this.paintColor = const Color.fromRGBO(255, 255, 0, 0.75)});
  double zoomFactor;
  double aspectRatio;
  List<List<double>>? targets;
  Color paintColor;

  @override
  void paint(Canvas canvas, Size screenSize) {
    final Rect screenRect = (Offset.zero) & screenSize;

    final imgWidth = screenSize.width;
    final imgHeight = screenSize.height;

    final shownWidth = imgWidth;
    final shownHeight = (imgWidth / (aspectRatio));
    final shownX = (imgWidth - shownWidth) / 2;
    final shownY = (imgHeight - shownHeight) / 2;

    final areaWidth = shownWidth * zoomFactor;
    final areaHeight = shownHeight * zoomFactor;
    final areaX = shownX + ((shownWidth - areaWidth) / 2);
    final areaY = shownY + ((shownHeight - areaHeight) / 2);

    final cutoutSize = Size(areaWidth, areaHeight);
    final cutoutOffset = Offset(areaX, areaY);

    final RRect cutoutRect = RRect.fromRectAndRadius(
        cutoutOffset & cutoutSize, Radius.circular(8.0));

    canvas.drawPath(
        Path.combine(PathOperation.difference, Path()..addRect(screenRect),
            Path()..addRRect(cutoutRect)),
        Paint()..color = this.paintColor);

    if (targets != null) {
      targets!.forEach((element) {
        canvas.drawCircle(
            Offset(cutoutOffset.dx + cutoutSize.width * element[0],
                cutoutOffset.dy + cutoutSize.height * element[1]),
            8.0,
            Paint()..color = this.paintColor);
      });
    }
  }

  @override
  bool shouldRepaint(CameraGuidelines oldDelegate) => false;
}
