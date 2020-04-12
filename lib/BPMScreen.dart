import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hello_heart/ImageProcessing.dart';

var result = -1;
var averageIndex = 0;
final averageArraySize = 4;
List<int> averageArray = List<int>.filled(averageArraySize, 0);
enum TYPE { GREEN, RED }
TYPE currentType = TYPE.GREEN;
TYPE getCurrent() {
  return currentType;
}

var beatsIndex = 0;
final beatsArraySize = 3;
List<int> beatsArray = List<int>.filled(beatsArraySize, 0);
double beats = 0;
var startTime = 0;

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
      appBar: AppBar(title: Text('Heart Beat AVG: $result')),
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
          _controller.flash(true);
          ImageProcessing imageProcessing = ImageProcessing();
          stopWatch.start();

          _controller.startImageStream((CameraImage image) async {
            // imageProcessing.addCameraFrame(image);
            // if (stopWatch.elapsed.inSeconds > 10) {
            //   _controller.stopImageStream();
            //   if (await Torch.hasTorch) Torch.turnOff();
            //   int bpm = await imageProcessing.calculateBPM(stopWatch.elapsed.inSeconds);
            //   print('Heart Beats Per Minute: $bpm');
            //   stopWatch.stop();
            //   stopWatch.reset();
            //   Navigator.of(context).pop();
            // }
            int width = image.width;
            int height = image.height;
            print('New Image');
            print('Time: ${stopWatch.elapsed.inSeconds}');

            int imgAvg = imageProcessing.getImageColors(image)[2].round();
            print('ImageAvg: $imgAvg');
            if (imgAvg == 0 || imgAvg == 255) {
              print('Image Not Valid!');
              return;
            }

            int averageArrayAvg = 0;
            int averageArrayCnt = 0;
            print(averageArray[0]);
            for (int i = 0; i < averageArray.length; i++) {
              if (averageArray[i] > 0) {
                averageArrayAvg += averageArray[i];
                averageArrayCnt++;
              }
            }

            int rollingAverage =
                (averageArrayCnt > 0) ? (averageArrayAvg / averageArrayCnt).round() : 0;
            TYPE newType = currentType;
            if (imgAvg < rollingAverage) {
              newType = TYPE.RED;
              if (newType != currentType) {
                beats++;
                print('BEAT!! Beats = $beats');
                // Log.d(TAG, "BEAT!! beats="+beats);
              }
            } else if (imgAvg > rollingAverage) {
              newType = TYPE.GREEN;
            }

            if (averageIndex == averageArraySize) averageIndex = 0;
            averageArray[averageIndex] = imgAvg;
            averageIndex++;

            if (newType != currentType) {
              currentType = newType;
            }

            int totalTimeInSecs = stopWatch.elapsed.inSeconds;
            if (stopWatch.elapsed.inSeconds > 10) {
              print('If Condition');
              _controller.stopImageStream();
              _controller.flash(false);
              print('Stopping Image Streeeeam!');
              double bps = (beats / totalTimeInSecs);
              int dpm = (bps * 60).round();
              if (dpm < 30 || dpm > 180) {
                stopWatch.reset();
                beats = 0;
                print('DPM: $dpm');
                return;
              }

              // Log.d(TAG,
              // "totalTimeInSecs="+totalTimeInSecs+" beats="+beats);
              print('Total Time In Seconds: $totalTimeInSecs And Beats: $beats');

              if (beatsIndex == beatsArraySize) beatsIndex = 0;
              beatsArray[beatsIndex] = dpm;
              beatsIndex++;

              int beatsArrayAvg = 0;
              int beatsArrayCnt = 0;
              for (int i = 0; i < beatsArray.length; i++) {
                if (beatsArray[i] > 0) {
                  beatsArrayAvg += beatsArray[i];
                  beatsArrayCnt++;
                }
              }
              int beatsAvg = (beatsArrayAvg / beatsArrayCnt).round();
              print(beatsAvg);
              setState(() {
                result = beatsAvg;
              });
              stopWatch.reset();
              beats = 0;
            }
          });
        },
      ),
    );
  }
}
