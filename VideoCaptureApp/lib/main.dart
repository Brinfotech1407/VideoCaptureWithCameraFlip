import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_recording_app/video_recorder_app_temp.dart';

List<CameraDescription> _cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(MaterialApp(home: VideoRecorderTempExample(_cameras)));
}
