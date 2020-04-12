import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hello_heart/BPMScreen.dart';
import 'package:hello_heart/MediumCode.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyRate(),
      home: HomePage(),
    );
  }
}

class MyRate extends StatefulWidget {
  MyRate({Key key}) : super(key: key);

  @override
  _MyRateState createState() => _MyRateState();
}

class _MyRateState extends State<MyRate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          child: Text('Heart Rate'),
          color: Colors.red,
          onPressed: () async {
            final cameras = await availableCameras();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BPMScreen(camera: cameras.first),
              ),
            );
          },
        ),
      ),
    );
  }
}

// class TakePictureScreen extends StatefulWidget {
//   final CameraDescription camera;

//   const TakePictureScreen({
//     Key key,
//     @required this.camera,
//   }) : super(key: key);

//   @override
//   TakePictureScreenState createState() => TakePictureScreenState();
// }

// class TakePictureScreenState extends State<TakePictureScreen> {
//   CameraController _controller;
//   Future<void> _initializeControllerFuture;
//   int counter = 0;
//   //O2Process o2process = O2Process();

//   @override
//   void initState() {
//     super.initState();
//     // To display the current output from the Camera,
//     // create a CameraController.
//     _controller = CameraController(
//       // Get a specific camera from the list of available cameras.
//       widget.camera,
//       // Define the resolution to use.
//       ResolutionPreset.medium,
//     );

//     // Next, initialize the controller. This returns a Future.
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Take a picture')),
//       // Wait until the controller is initialized before displaying the
//       // camera preview. Use a FutureBuilder to display a loading spinner
//       // until the controller has finished initializing.
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             // If the Future is complete, display the preview.
//             return CameraPreview(_controller);
//           } else {
//             // Otherwise, display a loading indicator.
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.camera_alt),
//         // Provide an onPressed callback.
//         onPressed: () async {
//           //o2process.reset();
//           Stopwatch sw = Stopwatch();
//           sw.start();
//           _controller.startImageStream((CameraImage availableImage) async {
//             // _controller.stopImageStream();
//             //final results = colorAverageCameraImage(availableImage);
//             //o2process.processFrameCamera(availableImage);
//             counter++;
//             print(counter);
//             if(sw.elapsed.inSeconds > 10) {
//               _controller.stopImageStream();
//               sw.stop();
//              // List bpm = await o2process.processO2(sw.elapsed.inSeconds);
//               print('Hii');
//              // print(bpm[0]);
//              // print(bpm[1]);
//               //print(bpm.length);
//             }
//           });
//           // Take the Picture in a try / catch block. If anything goes wrong,
//           // catch the error.
//           // try {
//           //   // Ensure that the camera is initialized.
//           //   await _initializeControllerFuture;

//           //   // Construct the path where the image should be saved using the
//           //   // pattern package.
//           //   final path = join(
//           //     // Store the picture in the temp directory.
//           //     // Find the temp directory using the `path_provider` plugin.
//           //     (await getTemporaryDirectory()).path,
//           //     '${DateTime.now()}.png',
//           //   );

//           //   // Attempt to take a picture and log where it's been saved.
//           //   await _controller.takePicture(path);

//           //   // If the picture was taken, display it on a new screen.
//           //   // Navigator.push(
//           //   //   context,
//           //   //   MaterialPageRoute(
//           //   //     builder: (context) => DisplayPictureScreen(imagePath: path),
//           //   //   ),
//           //   // );
//           // } catch (e) {
//           //   // If an error occurs, log the error to the console.
//           //   print(e);
//           // }
//         },
//       ),
//     );
//   }
// }

// List<double> colorAverageCameraImage(CameraImage image) {
//   int r_sum = 0;
//   int b_sum = 0;
//   int g_sum = 0;

//   int width = image.width;
//   int height = image.height;
// //  var img = imglib.Image(image.planes[0].bytesPerRow, height); // Create Image buffer
//   const int hexFF = 0xFF000000;
//   final int uvyButtonStride = image.planes[1].bytesPerRow;
//   final int uvPixelStride = image.planes[1].bytesPerPixel;
//   for (int x = 0; x < width; x++) {
//     for (int y = 0; y < height; y++) {
//       final int uvIndex =
//           uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
//       final int index = y * width + x;
//       final yp = image.planes[0].bytes[index];
//       final up = image.planes[1].bytes[uvIndex];
//       final vp = image.planes[2].bytes[uvIndex];
//       // Calculate pixel color
//       int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
//       int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
//           .round()
//           .clamp(0, 255);
//       int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
//       // color: 0x FF  FF  FF  FF
//       //           A   B   G   R
// //      img.data[index] = hexFF | (b << 16) | (g << 8) | r;

//       r_sum = r_sum + r;
//       b_sum = b_sum + b;
//       g_sum = g_sum + g;
//     }
//   }
//   // Rotate 90 degrees to upright
// //    var img1 = imglib.copyRotate(img, 90);

//   int size_img = width * height;

//   print("rgb: " +
//       r_sum.toString() +
//       " " +
//       b_sum.toString() +
//       " " +
//       g_sum.toString());

//   return [b_sum / size_img, g_sum / size_img, r_sum / size_img];
// //  return img;
// }
