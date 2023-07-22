import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'homePage.dart';
class VideoCapture extends StatefulWidget {
  const VideoCapture({super.key});

  @override
  State<VideoCapture> createState() => _VideoCaptureState();
}

class _VideoCaptureState extends State<VideoCapture> {
  late CameraController controller;
  bool _isFrontCamera = false;
  bool _isCameraInitialized = false;
  bool _isLoadingReport = false;
  bool _isTakingPicture = false;


  @override
  void initState() {
    super.initState();
    initializeCamera().then((_) {
      if (_isCameraInitialized) {
        startRecording().then((_) {
          stopRecording();
        });
      } else {
        Future.delayed(Duration(seconds: 2));
        startRecording().then((_) {
          stopRecording();
        });
      }
    });

  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final camera = _isFrontCamera ? cameras.last : cameras.first;
    controller = CameraController(
      camera,
      ResolutionPreset.high,
    );

    try {
      await controller.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> uploadVideoToFirebase(String videoPath) async {
    setState(() {
      _isLoadingReport = true;
    });
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final destination = 'videos/$fileName.mp4';

      final firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref(destination);
      final firebase_storage.UploadTask uploadTask =
      ref.putFile(File(videoPath));

      final firebase_storage.TaskSnapshot taskSnapshot =
      await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      final url = Uri.http('10.0.2.2:5000', '/reportGenVideos');
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'Raw_Video': downloadURL}));
      print('Response status: ${response.statusCode}');

      print('Video uploaded. Download URL: $downloadURL');
      setState(() {
        _isLoadingReport = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  HomePage())
      );



    } catch (e) {
      print('Error uploading video to Firebase Storage: $e');
    }
  }
  Future<void> startRecording() async {
    print('reached starting');


    if (!_isTakingPicture && _isCameraInitialized) {
      try {
        print('reached here1');
        final Directory extDir = await getTemporaryDirectory();
        final String dirPath = '${extDir.path}/Videos/flutter_test';
        await Directory(dirPath).create(recursive: true);
        final String filePath = '$dirPath/${DateTime.now()}.mp4';
        await controller.startVideoRecording();
        print('reached here2');
        print('reached here3');

      } catch (e) {
        print('Error starting video recording: $e');
      } finally {
        setState(() {
          _isTakingPicture = true;
        });
        await Future.delayed(Duration(seconds: 10)); //15 seconds record

      }
    }
  }


  void stopRecording() async {
    print('reached stopping');

    if (_isTakingPicture) {
      try {
        final XFile videoFile = await controller.stopVideoRecording();
        await uploadVideoToFirebase(videoFile.path);
      } catch (e) {
        print('Error stopping video recording: $e');
      } finally {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body:
          // full screen container camera
      _isLoadingReport ?
      Container(
        width: ScreenWidth * 1,
        height: ScreenHeight * 1,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5), // Set opacity to 50%
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),



              ),
              SizedBox(height: ScreenHeight *.1),
              Text(
                'Your report is being generated, please wait!',
                style: GoogleFonts.montserrat(
                  fontSize: ScreenWidth * .04,

                ),


              ),
            ],
          ),
        ),

      )

          :

      Container(
        // camera goes here
        width: ScreenWidth * 1,
        height: ScreenHeight * 1,
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.red, width: _isTakingPicture ? 5.0 : 0.0),
        ),
        child:

        _isCameraInitialized
            ? AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        )
            : Center(child: CircularProgressIndicator()),
      ),

      );

  }
}
