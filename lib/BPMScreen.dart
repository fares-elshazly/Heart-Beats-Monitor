import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hello_heart/ImageProcessing.dart';
import 'package:torch/torch.dart';

class BPMScreen extends StatefulWidget {
  final CameraDescription camera;
  BPMScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _BPMScreenState createState() => _BPMScreenState();
}

class _BPMScreenState extends State<BPMScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  Stopwatch stopWatch = Stopwatch();

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Heart Beat Test')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.timer),
        onPressed: () async {
          if (await Torch.hasTorch) Torch.turnOn();
          ImageProcessing imageProcessing = ImageProcessing();
          stopWatch.start();
          _controller.startImageStream((CameraImage image) async {
            imageProcessing.addCameraFrame(image);
            if (stopWatch.elapsed.inSeconds > 10) {
              _controller.stopImageStream();
              if (await Torch.hasTorch) Torch.turnOff();
              int bpm = await imageProcessing.calculateBPM(stopWatch.elapsed.inSeconds);
              print('Heart Beats Per Minute: $bpm');
              stopWatch.stop();
              stopWatch.reset();
              Navigator.of(context).pop();
            }
          });
        },
      ),
    );
  }
}
