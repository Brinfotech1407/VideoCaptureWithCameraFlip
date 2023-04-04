import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_recording_app/upload/upload_media.dart';

import 'audio_player_widet.dart';

class VideoRecorderTempExample extends StatefulWidget {
  VideoRecorderTempExample(this.cameras, {super.key});

  List<CameraDescription> cameras;

  @override
  _VideoRecorderTempExampleState createState() {
    return _VideoRecorderTempExampleState();
  }
}

class _VideoRecorderTempExampleState extends State<VideoRecorderTempExample>
    with WidgetsBindingObserver {
  CameraController? controller;
  XFile? videoFile;
  Timer? countdownTimer;
  Timer? stopVideoTimer;
  Duration myDuration = const Duration(seconds: 30);
  int selectedCamera = 0;
  bool isRecodingStart = false;
  bool isMusicPlaying = false;
  late AudioPlayer player;
  int currentAudioPlayingIndex = 0;
  ValueNotifier<String> uploadProgress = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    findCameraDevices();
    // Get the listonNewCameraSelected of available cameras.
    // Then set the first camera as selected.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      disposeAllCapture(cameraController);
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  void disposeAllCapture(CameraController cameraController) {
    cameraController.dispose();
    countdownTimer?.cancel();
    stopVideoTimer?.cancel();
    myDuration = const Duration(seconds: 30);
    player.stop();
    isRecodingStart = false;
    isMusicPlaying = false;
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Step
    String strDigits(int n) => n.toString().padLeft(2, '0');

    // Step 7
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return Scaffold(
      appBar: null,
      bottomNavigationBar: null,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _cameraPreviewWidget(),
          ),
          ValueListenableBuilder(
            valueListenable: uploadProgress,
            builder: (context, value, child) {
              if (value == '100.00') {
                return const SizedBox();
              } else {
                if (value == '0') {
                  return Align(
                    alignment: Alignment.center,
                    child: MediaUploadView(
                      mediaPath: videoFile!.path,
                      uploadProgress: (progress) {
                        uploadProgress.value = progress;
                      },
                    ),
                  );
                }
              }
              return const SizedBox();
            },
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
                    fontSize: 24),
              ),
            ),
          ],
          Container(
            margin: const EdgeInsets.only(bottom: 70),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: _captureControlRowWidget(),
            ),
          ),
          AudioSelectors(
            isRecodingStart: isRecodingStart,
            isAudioPreview: (value) {
              setState(() {
                isMusicPlaying = value;
              });
            },
            player: (audioPlayer) {
              player = audioPlayer;
            },
            currentIndex: (currentIndex) {
              currentAudioPlayingIndex = currentIndex;
            },
          ),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CameraPreview(
          controller!,
        ),
      );
    }
  }

  Widget _cameraTogglesRowWidget() {
    if (controller!.description.lensDirection == CameraLensDirection.front) {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            _onSwitchCamera(1);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 14, top: 45),
            child: IconButton(
                onPressed: () {
                  _onSwitchCamera(1);
                },
                icon: Icon(getCameraLensIcon(CameraLensDirection.front)),
                color: Colors.white,
                iconSize: 35),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            _onSwitchCamera(2);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 14, top: 45),
            child: IconButton(
                onPressed: () {
                  _onSwitchCamera(2);
                },
                icon: Icon(getCameraLensIcon(CameraLensDirection.front)),
                color: Colors.white,
                iconSize: 35),
          ),
        ),
      );
    }
  }

  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.flip_camera_android_outlined;
      case CameraLensDirection.front:
        return Icons.flip_camera_android_outlined;
      case CameraLensDirection.external:
        return Icons.camera;
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  Widget _captureControlRowWidget() {
    return GestureDetector(
      onTap: () {
        if (controller != null &&
            controller!.value.isInitialized &&
            !controller!.value.isRecordingVideo) {
          if(isMusicPlaying) {
            onVideoRecordButtonPressed();

            startTimer();
          }
        } else {
          //onStopButtonPressed();
        }
      },
      child: Container(
        width: 67,
        height: 67,
        decoration: BoxDecoration(
          border: Border.all(
            color: controller != null &&
                    controller!.value.isInitialized &&
                    !controller!.value.isRecordingVideo
                ? isMusicPlaying
                    ? Colors.white
                    : const Color.fromRGBO(217, 217, 217, 1).withOpacity(0.5)
                : Colors.red,
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
                  ? isMusicPlaying
                      ? Colors.white
                      : const Color.fromRGBO(217, 217, 217, 1).withOpacity(0.5)
                  : Colors.red,
              borderRadius: const BorderRadius.all(Radius.elliptical(47, 47)),
            )),
      ),
    );
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

  void showInSnackBar(String s) {
    print("Error $s");
  }

  Future<void> onVideoRecordButtonPressed() async {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    await player.stop();
    player.play();
  }

  void onStopButtonPressed() {
    player.stop();
    countdownTimer?.cancel();
    stopVideoTimer?.cancel();
    isRecodingStart = false;
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {});
      }
      player.stop();
      isRecodingStart = false;
      isMusicPlaying=false;
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        myDuration = const Duration(seconds: 30);
        player.stop();
        uploadProgress.value = "0";
      }
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    isRecodingStart = true;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
      stopRecordingAfter30Seconds();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
    setState(() {});
  }

  void stopRecordingAfter30Seconds() {
    stopVideoTimer = Timer(
      const Duration(seconds: 30),
      () {
        onStopButtonPressed();
      },
    );
    // Future.delayed(const Duration(seconds: 30), () {});
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void findCameraDevices() {
    for (final CameraDescription cameraDescription in widget.cameras) {
      if (cameraDescription.lensDirection == CameraLensDirection.back) {
        onNewCameraSelected(cameraDescription);
      }
    }
  }

  void _onSwitchCamera(int i) {
    if (i == 1) {
      for (final CameraDescription cameraDescription in widget.cameras) {
        if (cameraDescription.lensDirection == CameraLensDirection.back) {
          onNewCameraSelected(cameraDescription);
        }
      }
    } else {
      for (final CameraDescription cameraDescription in widget.cameras) {
        if (cameraDescription.lensDirection == CameraLensDirection.front) {
          onNewCameraSelected(cameraDescription);
        }
      }
    }
  }
}
