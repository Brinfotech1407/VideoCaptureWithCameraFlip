/*
import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class VideoRecorderExample extends StatefulWidget {
  const VideoRecorderExample({super.key});

  @override
  _VideoRecorderExampleState createState() {
    return _VideoRecorderExampleState();
  }
}

class _VideoRecorderExampleState extends State<VideoRecorderExample>
    with WidgetsBindingObserver {
  CameraController? controller;
  String? videoPath;

  List<CameraDescription>? cameras;
  int? selectedCameraIdx;

  Map<String, bool> arrCheckedMap = <String, bool>{};
  Timer? countdownTimer;
  Duration myDuration = const Duration(seconds: 30);
  bool isInitialized = false;

  int isRecodingStart = 0;
  bool isAudioPlay = false;
  final CarouselController _controller = CarouselController();

  final assetsAudioPlayer = AssetsAudioPlayer();

  List<String> musicTracks = [
    'assets/audio/1.mp3',
    'assets/audio/2.mp3',
    'assets/audio/3.mp3',
    'assets/audio/4.mp3',
    'assets/audio/5.mp3',
    'assets/audio/6.mp3',
    'assets/audio/7.mp3',
    'assets/audio/8.mp3',
    'assets/audio/9.mp3',
    'assets/audio/10.mp3',
  ];
  List<String> musicImage = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    'assets/images/4.png',
    'assets/images/5.png',
    'assets/images/6.png',
    'assets/images/7.png',
    'assets/images/8.png',
    'assets/images/9.png',
    'assets/images/10png',
  ];

  List<String> musicTracksNames = [
    ' Dark Trap Beat (It Follows You) - Alex Kizenkov',
    ' Fun Life - FASSounds',
    ' Snow - Dubdown',
    'Danger - Monument Music',
    'Boom Bap Hip-Hop - AlexiAction',
    ' Extreme Trap - Playsound',
    'Trap - The Mountain',
    'Beat 3 - ENheee',
    'Audio Pon - Magiksolo',
    'Urban - lemonmusicstudio',
  ];
  int _currentTrackIndex = 0;

  void playAudio(int index) {
    final assetsAudioPlayer = AssetsAudioPlayer();

    assetsAudioPlayer.open(
      Audio(musicTracks[index]),
    );

    assetsAudioPlayer.play();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Get the listonNewCameraSelected of available cameras.
    // Then set the first camera as selected.
    _initCameraController();
  }

  void _initCameraController() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras!.isNotEmpty) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _onCameraSwitched(cameras![selectedCameraIdx!]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLifecycleState.paused == state) {
      _disposeCameraController();
    } else {
      if (controller == null) {
        _initCameraController();
      }
    }
  }

  @override
  void dispose() {
    _disposeCameraController();

    WidgetsBinding.instance.removeObserver(this);
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    // Step 7
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
      appBar: null,
      bottomNavigationBar: null,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _cameraPreviewWidget(),
          ),
          _cameraTogglesRowWidget(),
          if (controller != null &&
              controller!.value.isInitialized &&
              controller!.value.isRecordingVideo) ...<Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 155.0),
              child: Text(
                '$minutes:$seconds',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              ),
            ),
          ],
          Container(
            margin: const EdgeInsets.only(bottom: 70.0),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: _captureControlRowWidget(),
            ),
          ),
          Container(
            color: Colors.transparent,
            height: 60,
            child: CarouselSlider.builder(
              carouselController: _controller,
              itemCount: musicTracks.length,
              itemBuilder: (BuildContext context, int index, int realIndex) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isAudioPlay = true;
                    });
                    playAudio(index);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: _currentTrackIndex == index
                          ? Colors.white
                          : Colors.white30,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 23,
                            height: 23,
                            margin: const EdgeInsets.only(left: 2, right: 2),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(musicImage[index]),
                                  fit: BoxFit.cover),
                              borderRadius: const BorderRadius.all(
                                  Radius.elliptical(25, 25)),
                            )),
                        SizedBox(
                          width: 70,
                          child: Text(
                            musicTracksNames[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                              color: _currentTrackIndex == index
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 40,
                viewportFraction: 0.3,
                initialPage: _currentTrackIndex,
                enableInfiniteScroll: false,
                onScrolled: (value) {
                  assetsAudioPlayer
                      .seek(Duration(milliseconds: value!.toInt()));
                  if (!assetsAudioPlayer.isPlaying.value) {
                    assetsAudioPlayer.play();
                  }
                },
                onPageChanged: (index, reason) {
                  _onItemChanged(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _onItemChanged(int index) {

    setState(() {
      _currentTrackIndex = index;
    });


  }

  void buildAudioPlayStop() {
    setState(() {
      if(assetsAudioPlayer.isPlaying.value) {
        assetsAudioPlayer.stop();
      } else {
        assetsAudioPlayer.play();
      }

      */
/*if(assetsAudioPlayer.playlistFinished.value){
        assetsAudioPlayer.playlistPlayAtIndex()
      }*//*

    });
  }

  void updateCheckView(String key) {
    if (arrCheckedMap.containsKey(key)) {
      arrCheckedMap.clear();
      isRecodingStart = 0;
    } else {
      arrCheckedMap.clear();
      arrCheckedMap[key] = true;
      isRecodingStart = 1;
    }
    setState(() {});
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.flip_camera_android_outlined;
      case CameraLensDirection.front:
        return Icons.flip_camera_android_outlined;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  // Display 'Loading' text when the camera is still loading.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return CameraPreview(controller!);
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null) {
      return Container();
    }

    CameraDescription selectedCamera = cameras![selectedCameraIdx!];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: _onSwitchCamera,
        child: Padding(
          padding: const EdgeInsets.only(right: 14, top: 45),
          child: IconButton(
              onPressed: _onSwitchCamera,
              icon: Icon(_getCameraLensIcon(lensDirection)),
              color: Colors.white,
              iconSize: 35),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to record videos.
  Widget _captureControlRowWidget() {
    return GestureDetector(
      onTap: () {
        if (controller != null &&
            controller!.value.isInitialized &&
            !controller!.value.isRecordingVideo &&
            arrCheckedMap.isNotEmpty) {
          _onRecordButtonPressed();
          startTimer();
        } else {}
      },
      child: Container(
        width: 67,
        height: 67,
        decoration: BoxDecoration(
          border: Border.all(
            color: controller != null &&
                controller!.value.isInitialized &&
                !controller!.value.isRecordingVideo
                ?isRecodingStart == 0 ? const Color.fromRGBO(217, 217, 217, 1).withOpacity(0.5):Colors.white
                :Colors.red,
            width: 6,
          ),
          borderRadius: const BorderRadius.all(Radius.elliptical(67, 67)),
        ),
        child: Container(
            width: 47,
            height: 47,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: controller != null &&
                  controller!.value.isInitialized &&
                  !controller!.value.isRecordingVideo
                  ? isRecodingStart == 0 ?const Color.fromRGBO(217, 217, 217, 1).withOpacity(0.5):Colors.white
                  : Colors.red,
              borderRadius: const BorderRadius.all(Radius.elliptical(47, 47)),
            )),
      ),
    );

    */
/*return Center(
      child: GestureDetector(
        onTap: controller != null &&
                controller!.value.isInitialized &&
                !controller!.value.isRecordingVideo
            ? _onRecordButtonPressed
            : null,
        child: SizedBox(
          width: 35,
          height: 35,
          child: Image.asset(
            'assets/captureIcon.png',
            width: 35,
            height: 35,
            color: controller != null &&
                    controller!.value.isInitialized &&
                    controller!.value.isRecordingVideo
                ? Colors.red
                : Colors.black,
          ),
        ),
      ),
    );*//*


    */
/*Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[

        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: controller != null &&
              controller!.value.isInitialized &&
              controller!.value.isRecordingVideo
              ? _onStopButtonPressed
              : null,
        )
      ],
    );*//*

  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    */
/* if (controller != null) {
      await controller!.dispose();
    }*//*


    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller! is updated then update the UI.
    controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller!.value.hasError) {
        print('Camera error${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
      isInitialized = true;
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
    selectedCameraIdx! < cameras!.length - 1 ? selectedCameraIdx! + 1 : 0;
    CameraDescription selectedCamera = cameras![selectedCameraIdx!];

    controller?.setDescription(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed() {
    _startVideoRecording().then((String? filePath) {
      if (filePath != null) {
        stopRecordingAfter30Seconds(filePath);
      }
    });
  }

  void _onStopButtonPressed(String filePath) {
    _stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      print('videoPath :: $videoPath');
      arrCheckedMap.clear();
      countdownTimer?.cancel();
      isRecodingStart = 0;
      assetsAudioPlayer.stop();
      setState(() {});
    });
  }

  void showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white);
  }

  Future<String?> _startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      return null;
    }

    // Do nothing if a recording is on progress
    if (controller!.value.isRecordingVideo) {
      return null;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/${currentTime}.mp4';

    final File videoFile =
    File('${(await getTemporaryDirectory()).path}/video.mp4');

    print('temp filePath ${videoFile.path}');

    try {
      await controller!.startVideoRecording(
        onAvailable: (CameraImage image) {
          debugPrint('${image.planes}');
        },
      );
      videoPath = videoFile.path;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  Future<void> _stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller!.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);
  }

  void stopRecordingAfter30Seconds(String filePath) {
    Future.delayed(const Duration(seconds: 30), () {
      _onStopButtonPressed(filePath);
    });
  }

  Widget bottomButton(
      {required String text,
        required Function() onClickListener,
        required String imagePath}) {
    return GestureDetector(
      onTap: onClickListener,
      child: Container(
        //  width: 96,
        height: 29,
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: arrCheckedMap.containsKey(text)
                ? Colors.white
                : Colors.white30),
        child: Row(
          children: [
            Container(
                width: 20,
                height: 25,
                margin: const EdgeInsets.only(left: 1),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(imagePath), fit: BoxFit.cover),
                  borderRadius:
                  const BorderRadius.all(Radius.elliptical(25, 25)),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: Text(text,
                  style: TextStyle(
                      color: arrCheckedMap.containsKey(text)
                          ? Colors.black
                          : Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _disposeCameraController() async {
    if (controller == null) {
      return Future.value();
    }

    final cameraController = controller;

    controller = null;
    if (mounted) {
      setState(() {});

      // Wait for the post frame callback.
      final completerPostFrameCallback = Completer<Duration>();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        completerPostFrameCallback.complete(timeStamp);
      });
      await completerPostFrameCallback.future;
    }

    return cameraController!.dispose();
  }
}

class VideoRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VideoRecorderExample(),
    );
  }
}
*/
