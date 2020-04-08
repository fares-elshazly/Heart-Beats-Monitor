import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:smart_signal_processing/smart_signal_processing.dart';

class ImageProcessing {
  double redBlueRatio = 0;
  double stdRed = 0;
  double stdBlue = 0;
  double sumRed = 0;
  double sumBlue = 0;
  List<double> redAvgList = List<double>();

  List<double> getImageColors(CameraImage image) {
    int redSum = 0;
    int blueSum = 0;
    int greenSum = 0;

    int width = image.width;
    int height = image.height;
    int imageSize = width * height;

    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

        redSum += r;
        blueSum += b;
        greenSum += g;
      }
    }

    return [blueSum / imageSize, greenSum / imageSize, redSum / imageSize];
  }

  void addCameraFrame(CameraImage image) {
    final colors = getImageColors(image);

    double redAvg = colors[2];
    double blueAvg = colors[1];

    sumRed = sumRed + redAvg;
    sumBlue = sumRed + blueAvg;

    redAvgList.add(colors[2]);
  }

  Future<int> calculateBPM(int totalTimeInSeconds) async {
    if (redAvgList.length == 0) return -1;

    double samplingFrequency = (redAvgList.length / totalTimeInSeconds);

    List redAvgListCopy = redAvgList.map((element) => element).toList();
    double frequency = await calculateFrequency(redAvgListCopy, samplingFrequency);

    int bpm = (frequency * 60).ceil();

    return bpm > 0 ? bpm : -1;
  }

  Future<double> calculateFrequency(
      List<double> redAvgList, double samplingFrequency) async {
    double tmp = 0;
    double pomp = 0;
    double frequency;

    int redAvgListLength = redAvgList.length;
    int lengthNearestPower = nearestPowerOfTwo(redAvgListLength);

    for (int i = redAvgListLength; i < lengthNearestPower; ++i) {
      redAvgList.add(0);
    }

    assert(redAvgList.length == lengthNearestPower);

    Float64List redAvgListFloatList = Float64List.fromList(redAvgList);

    Float64List redAvgListImages = Float64List(redAvgList.length);

    FFT.transform(redAvgListFloatList, redAvgListImages);

    for (int p = 35; p < redAvgListLength; p++) {
      redAvgListFloatList[p] = redAvgListFloatList[p].abs();
      assert(redAvgListFloatList[p] >= 0);
    }

    for (int p = 35; p < redAvgListLength; p++) {
      assert(redAvgListFloatList[p] >= 0);

      if (tmp < redAvgListFloatList[p]) {
        tmp = redAvgListFloatList[p];
        pomp = p.toDouble();
      }
    }

    if (pomp < 35) pomp = 0;

    frequency = pomp * samplingFrequency / (2 * redAvgListLength);

    return frequency;
  }

  int nearestPowerOfTwo(int v) {
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v++;

    return v;
  }
}
