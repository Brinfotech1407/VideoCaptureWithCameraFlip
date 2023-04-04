import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:video_recording_app/upload/firebase_api.dart';

class MediaUploadView extends StatefulWidget {
  MediaUploadView({
    required this.mediaPath,
    required this.uploadProgress,
    required this.task,
    required this.updateUploadTask,
  });

  String mediaPath;
  Function(String) uploadProgress;
  Function(UploadTask) updateUploadTask;
  UploadTask? task;

  @override
  _MediaUploadViewState createState() => _MediaUploadViewState();
}

class _MediaUploadViewState extends State<MediaUploadView> {
  File? file;

  @override
  void initState() {
    super.initState();
    selectFile();
  }

  @override
  Widget build(BuildContext context) {
    return widget.task != null ? buildUploadStatus(widget.task!) : Container();
  }

  Future selectFile() async {
    setState(() => file = File(widget.mediaPath));
    uploadFile();
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    widget.task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});


    if (widget.task == null) return;

    widget.updateUploadTask(widget.task!);

    final snapshot = await widget.task!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
    widget.uploadProgress('100.00');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                      // margin: const EdgeInsets.only(top: 15),
                      child: Text(
                        '$percentage %',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      );
}
