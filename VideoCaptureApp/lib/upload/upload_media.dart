import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:video_recording_app/upload/firebase_api.dart';

class MediaUploadView extends StatefulWidget {
  MediaUploadView({required this.mediaPath, required this.uploadProgress});

  String mediaPath;
  Function(String) uploadProgress;

  @override
  _MediaUploadViewState createState() => _MediaUploadViewState();
}

class _MediaUploadViewState extends State<MediaUploadView> {
  UploadTask? task;
  File? file;

  @override
  void initState() {
    // TODO: implement initState
    selectFile();
  }

  @override
  Widget build(BuildContext context) {

    return task != null ? buildUploadStatus(task!) : Container();
  }

  Future selectFile() async {
    setState(() => file = File(widget.mediaPath));
    uploadFile();
  }

  Future uploadFile() async {
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final  percentage = (progress * 100).toStringAsFixed(2);

            widget.uploadProgress(percentage);

            return Column(
              children: [
                const Center(child: CircularProgressIndicator()),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: Text(
                    '$percentage %',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      );
}
