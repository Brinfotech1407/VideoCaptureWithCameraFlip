import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_recording_app/AudioPlayerWidet.dart';
import 'package:video_recording_app/audio_utils.dart';

class VideoRecorderTempExample extends StatefulWidget {
  const VideoRecorderTempExample({super.key});

  @override
  _VideoRecorderTempExampleState createState() {
    return _VideoRecorderTempExampleState();
  }
}

class _VideoRecorderTempExampleState extends State<VideoRecorderTempExample>
    with WidgetsBindingObserver {

  



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Get the listonNewCameraSelected of available cameras.
    // Then set the first camera as selected.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLifecycleState.paused == state) {
    } else {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Step
    return Scaffold(
      appBar: null,
      bottomNavigationBar: null,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.grey,
          ),
          AudioSelectors(),
        ],
      ),
    );
  }





  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white);
  }

}

class VideoRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VideoRecorderTempExample(),
    );
  }
}
