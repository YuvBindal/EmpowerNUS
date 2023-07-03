import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ChatMessage.dart';
import 'main.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audioplayers.dart';


class VerifyIDForm extends StatefulWidget {
  const VerifyIDForm({Key? key}) : super(key: key);

  @override
  State<VerifyIDForm> createState() => _VerifyIDFormState();
}

class _VerifyIDFormState extends State<VerifyIDForm> {
  String? filePath;
  String? _imageUrl;

  bool isFilePickerActive = false;

  late CameraController controller;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  bool _isFrontCamera = false;
  bool _picStorage = false;

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
      ResolutionPreset.high,
    );

    controller.addListener(() {
      if (controller.value.isInitialized) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    });

    try {
      await controller.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }
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

    await Future.delayed(Duration(milliseconds: 500)); //add a little effect

    try {
      final XFile picture = await controller.takePicture();
      print('Picture saved at: ${picture.path}');
      uploadFaceImagetoFirebase(
          picture.path); // Call the method to upload the image
    } catch (e) {
      print('Error taking picture: $e');
    } finally {
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<void> uploadFaceImagetoFirebase(String imagePath) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final destination = 'images/$fileName.png';

      final firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref(destination);
      final firebase_storage.UploadTask uploadTask =
      ref.putFile(File(imagePath));

      final firebase_storage.TaskSnapshot taskSnapshot =
      await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      print('Image uploaded. Download URL: $downloadURL');
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }

  Future<void> uploadImageToFirebase(String imagePath) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final destination = 'images/$fileName.png';

      final firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref(destination);
      final firebase_storage.UploadTask uploadTask = ref.putFile(File(imagePath));

      final firebase_storage.TaskSnapshot taskSnapshot =
      await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('verifyID', downloadURL);
      String? imageUrl = prefs.getString('verifyID');
      if (imageUrl != null) {
        setState(() {
          _imageUrl = imageUrl;
        });
      }
      print('Image uploaded. Download URL: $downloadURL');
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }

  Future<String?> selectFile() async {
    if (isFilePickerActive) {
      // File picker is already active, so return null or handle it as needed
      return null;
    }

    isFilePickerActive = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        filePath = result.files.single.path;
        if (filePath != null && filePath!.isNotEmpty) {
          uploadImageToFirebase(filePath!);
          return filePath;
        }
      }
      // User canceled the file picker or no valid file path found
      return null;
    } finally {
      isFilePickerActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    ImageProvider imageProvider;
    if (_imageUrl != null) {
      imageProvider = NetworkImage(_imageUrl!);
    } else {
      imageProvider = AssetImage('');
    }

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: screenWidth * 1,
          height: screenHeight * .1,
          child: Center(
            child: Text(
              'Verify ID',
              style: GoogleFonts.montserrat(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                letterSpacing: .8,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: screenHeight * .05),
            Center(
              child: Container(
                width: screenWidth * .9,
                height: screenHeight * .35,
                decoration: BoxDecoration(
                  image: _imageUrl != null
                      ? DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // ID Loading Code
                selectFile();
              },
              child: Text('Upload ID'),
            ),
            if (_imageUrl != null)

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Please remember to remove accessories such as hats, glasses, etc',
                         style: GoogleFonts.montserrat(),
                      ),
                    ),
                    SizedBox(height: screenHeight * .05),
                    Container(
                      // camera goes here
                      width: screenWidth * .7,
                      height: screenHeight * .4,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.red, width: _isTakingPicture ? 5.0 : 0.0),
                      ),
                      child: _isCameraInitialized
                          ? AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: CameraPreview(controller),
                      )
                          : Center(child: CircularProgressIndicator()),
                    ),
                    TextButton(
                      onPressed:  () {
                        takePicture();
                      },
                      child: Text(
                        'Scan Face',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: screenWidth * .03,
                        ),
                      ),
                    ),

                  ],
                ),





          ],
        ),
      ),
      persistentFooterButtons: [
        Container(
          height: screenHeight * .07,
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
                  iconSize: screenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: screenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: screenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: screenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: screenWidth * .1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class angelForm extends StatefulWidget {
  const angelForm({super.key});

  @override
  State<angelForm> createState() => _angelFormState();
}

class _angelFormState extends State<angelForm> {
  late OpenAI? chatGPT;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    chatGPT = OpenAI.instance.build(
        token: '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',
        baseOption: HttpSetup(receiveTimeout: Duration(seconds: 60000)));
    super.initState();
  }

  @override
  void dispose() {
    chatGPT?.close();
    _controller.dispose();
    super.dispose();
  }

  void generateMessage() async {
    final request = CompleteText(
      model: kTextDavinci3,
      prompt:
      'Generate a short emergency message for the user to send a contact in case of emergencies or danger',
    );

    final response = await chatGPT?.onCompletion(request: request);
    setState(() {
      _controller.text += response?.choices[0].text ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;



    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: ScreenWidth * 1,
          height: ScreenHeight * .1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      letterSpacing: .8,
                  ),

                ),
              ),
              Text(
                'New Contact',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  letterSpacing: .8,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                    'Confirm',
                    style: GoogleFonts.montserrat(
                    letterSpacing: .8,
                    )
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget> [

            Container(
              width: ScreenWidth,
              height: ScreenHeight * .2,
              child: Transform.scale(
                scale: 1.5,
                child: Image(
                  image: AssetImage('assets/images/Icon_Avatar.png'),
                ) ,
              ),
            ),
            Container(
              width: ScreenWidth * .5,
              height: ScreenHeight * .05,
              child: TextButton(
                onPressed: () {},
                child: Text(
                    'Add Photo',
                    style: GoogleFonts.montserrat(
                      letterSpacing: .8,
                      color: Colors.blue,
                    ),
                ),
              ),
            ),
            Container(
              width: ScreenWidth,
              height: ScreenHeight * .24,
              child: Column(
                children: <Widget>[
                  Container(
                    width: ScreenWidth,
                    height: ScreenHeight * .08,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'First name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ScreenWidth * .01),
                        ),
                    ),
                  ),
                  ),
                  Container(
                    width: ScreenWidth,
                    height: ScreenHeight * .08,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Last name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ScreenWidth * .01),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: ScreenWidth,
                    height: ScreenHeight * .08,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'EmpowerNUS #userID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ScreenWidth * .01),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenHeight * .05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: EdgeInsets.all(ScreenWidth*.01),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: ScreenWidth * .8,
                  height: ScreenHeight * .08,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenHeight * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: EdgeInsets.all(ScreenWidth*.01),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: ScreenWidth * .8,
                  height: ScreenHeight * .08,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenHeight * .02),
            Text(
                'Add Location',
              style: GoogleFonts.montserrat(
                fontSize: ScreenWidth * .05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height:ScreenHeight * .01),

            Container(
              width: ScreenWidth * .8,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Add Street/Flat No.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ScreenWidth * .01),
                  ),
                ),
              ),
            ),
            SizedBox(height:ScreenHeight * .01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: ScreenWidth * .3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add City',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: ScreenWidth * .3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add State',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: ScreenWidth * .3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add Country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenHeight * .02),
            Text(
              'Add Emergency Message',
              style: GoogleFonts.montserrat(
                fontSize: ScreenWidth * .05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height:ScreenHeight * .01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: ScreenWidth * .8,
                  child: TextField(
                    
                    style: TextStyle(color: Colors.black),
                    controller: _controller, // Add this line to connect the controller
                    decoration: InputDecoration(
                      hintText: 'Help, I am in danger!',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: ScreenWidth *.1,
                  child: IconButton(
                    onPressed: () {
                      generateMessage();
                    },
                    icon: Image(
                      image: AssetImage('assets/images/icon_reload.png'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenHeight * .02),
            Container(
              decoration: BoxDecoration(
                color: Colors.green[300],

                borderRadius: BorderRadius.circular(ScreenWidth * .02),
              ),
              child: TextButton(
                onPressed: () {},
                child: Text(
                    'Verify Contact ID',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: .8,
                    )
                ),
              ),
            ),
            SizedBox(height: ScreenHeight * .02),

          ],

        ),
      ),

      //.93
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

