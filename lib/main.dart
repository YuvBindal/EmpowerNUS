import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: Scanner(),
  ));
}

class Scanner extends StatefulWidget {
  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late CameraController controller;
  bool _isCameraInitialized = false;
  bool _isFrontCamera = false;
  bool _isTakingPicture = false;
  bool _picStorage = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }




  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void initializeCamera() async {
    final cameras = await availableCameras();
    final camera = _isFrontCamera ? cameras.last : cameras.first;
    controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    await controller.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  void switchCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraInitialized = false;
    });
    controller.dispose();
    initializeCamera();
  }

  Future<void> takePicture() async {
    if (_isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
      _picStorage = true;
    });

    player.play(AssetSource('assets/audios/camera-shutter-18399.mp3'));
    await Future.delayed(Duration(milliseconds: 500)); //add a little effect

    try {
      final XFile picture = await controller.takePicture();
      print('Picture saved at: ${picture.path}');
      uploadImageToFirebase(picture.path); // Call the method to upload the image
    } catch (e) {
      print('Error taking picture: $e');
    }  finally {
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<void> uploadImageToFirebase(String imagePath) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final destination = 'images/$fileName.png';

      final firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref(destination);
      final firebase_storage.UploadTask uploadTask = ref.putFile(File(imagePath));

      final firebase_storage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      print('Image uploaded. Download URL: $downloadURL');
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;
    double ScreenFont = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      //.93 of the container height
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[



            Container(

              // camera goes here
              width: ScreenWidth * 1,
              height: ScreenHeight * .70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: _isTakingPicture ?
                5.0 :
                0.0),

              ),

              child: _isCameraInitialized
                  ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              )
                  : Center(child: CircularProgressIndicator()),
            ),

            Container(
              //picture storage goes here
              width: ScreenWidth * 1,
              height: ScreenHeight * .15,
              color: Colors.grey[800],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  (_picStorage) ?

                      //create a scrollbar with image addition
                  Text('true'):
                  //create a placeholder text
                  Text(
                      'No Images Found',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        shadows: [
                          Shadow(
                            color: Colors.grey,
                            offset: Offset(2, 2),
                            blurRadius: 2,
                          ),
                        ],
                        fontSize: ScreenWidth * 0.05* 1.1,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[200],
                      ),


                    ),


                  ),
                ],

              ),

            ),
            Container(
              width: ScreenWidth * 1,
              height: ScreenHeight * .06,
              color: Colors.grey[400],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      onPressed: takePicture,
                      icon: ImageIcon(
                        AssetImage('assets/images/Icon_Camera.png'),
                        color: null,
                      ),
                      iconSize: ScreenHeight * .06,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: switchCamera,
                      icon: Icon(
                        Icons.switch_camera,
                        color: null,
                      ),
                      iconSize: ScreenHeight * .04,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      persistentFooterButtons: [
        Container(
          height: ScreenHeight * .07,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: ScreenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: ScreenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: ScreenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: ScreenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: ScreenWidth * .1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
