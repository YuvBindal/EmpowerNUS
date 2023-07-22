import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:async';
import 'chatMessage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'angelForm.dart';
import 'ContactList.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'angelContact.dart';
import 'homePage.dart';
import 'accountPage.dart';
import 'geolocator.dart';
import 'permissons.dart';
import 'permhandler.dart';
import 'videoCapture.dart';

//add a cross, add it to display on angelContacts when delete contacts is selected,
//add a confirmation, when delete it is hit run a searching algo



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print(message);
  runApp(MaterialApp(
    title: 'EmpowerNUS',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
      useMaterial3: true,
    ),
    home: HomePage(),
  ));
}



/*
Logic: after message returns if its not a match just tell them to take a picture again.
If it is a match. Add contents of angelDetails to angels. Pass those details of contact first and last name + city/state/country and create an angel
contact side by side.

//notes to self:
implement delete logic for angel list
try using a listview builder to make code more robust
host server endpoint on AWS or something for testing of others.

 */

List<angelContact> angelContacts = [];
List<angelDetails> angels = [];


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
  bool _isLoadingReport = false;
  List<ReportFrame> reportFrames = [];

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
  void addFrame() {
    setState(() {
      reportFrames.add(ReportFrame());
      _isLoadingReport = false;
    });
  }

  void initializeCamera() async {
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

  void switchCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraInitialized = false;
    });

    controller.dispose();
    await Future.delayed(Duration(milliseconds: 500));

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
      uploadImageToFirebase(picture.path); // Call the method to upload the image



    } catch (e) {
      print('Error taking picture: $e');
    } finally {
      setState(() {
        _isTakingPicture = false;
      });
    }

  }

  Future<void> uploadImageToFirebase(String imagePath) async {
    setState(() {
      _isLoadingReport = true;
    });
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

      //setting up image url to api
      final url = Uri.http('10.0.2.2:5000', '/reportGen');
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'Raw_Picture': downloadURL}));
      print('Response status: ${response.statusCode}');


      print('Image uploaded. Download URL: $downloadURL');
      addFrame();
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
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
      addFrame();
    } catch (e) {
      print('Error uploading video to Firebase Storage: $e');
    }
  }

  void startRecording() async {
    print('reached starting');

    if (!_isTakingPicture) {
      try {
        final Directory extDir = await getTemporaryDirectory();
        final String dirPath = '${extDir.path}/Videos/flutter_test';
        await Directory(dirPath).create(recursive: true);
        final String filePath = '$dirPath/${DateTime.now()}.mp4';
        await controller.startVideoRecording();
      } catch (e) {
        print('Error starting video recording: $e');
      } finally {
        setState(() {
          _isTakingPicture = true;
        });
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
    double ScreenFont = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      //.93 of the container height
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //can better customise the UI

            _isLoadingReport ?
            Container(
              width: ScreenWidth * 1,
              height: ScreenHeight * .7,
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
              height: ScreenHeight * .70,
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
            Container(
              //picture storage goes here
              width: ScreenWidth * 1,
              height: ScreenHeight * .15,
              color: Colors.grey[800],
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: reportFrames,
                ),
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
                      onPressed:
                          (!_isTakingPicture) ? startRecording : stopRecording,
                      icon: ImageIcon(
                        AssetImage('assets/images/Icon_Record.png'),
                        color: null,
                      ),
                      iconSize: ScreenHeight * .1,
                    ),
                  ),
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
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ChatBot())
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: ScreenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    //friend chat goes here
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: ScreenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                HomePage())
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: ScreenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    //education page goes here
                  },
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

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI? chatGPT;

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
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    ChatMessage _message = ChatMessage(
        text: _controller.text,
        sender: "user"); // need to fetch username and replace here

    setState(() {
      _messages.insert(0, _message);
    });

    _controller.clear();

    //using davinci 3 model
    final request = CompleteText(
      model: kTextDavinci3,
      prompt: _message.text,
    );
    final response = await chatGPT!.onCompletion(request: request);
    Vx.log(response!.choices[0].text);
    insertNewData(response.choices[0].text);
  }

  void insertNewData(String response) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: 'bot',
    );
    setState(() {
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration:
                InputDecoration.collapsed(hintText: "Got any questions?"),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => _sendMessage(),
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    double ScreenHeight = MediaQuery.of(context).size.height;
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenFont = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
          title: Center(
        child: Text(
          "Crime Fighting GPT",
          style: GoogleFonts.openSans(),
        ),
      )),

      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
              ),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
      //.93 HEIGHT remains
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

class angelList extends StatefulWidget {
  const angelList({super.key});

  @override
  State<angelList> createState() => _angelListState();
}

class _angelListState extends State<angelList> {



  @override
  Widget build(BuildContext context) {
    double ScreenHeight = MediaQuery.of(context).size.height;
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenFont = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Image_Background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget> [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, ScreenHeight *.05, 0, ScreenHeight *.05),
                      child: Container(
                        height: ScreenHeight * .06,
                        width: ScreenWidth * .42,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (BuildContext context) =>
                                angelForm())
                            );

                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(ScreenWidth * .02),
                            ),
                            backgroundColor: Colors.lightGreen[300],
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Image(
                                width: ScreenWidth * .05,
                                height: ScreenHeight * .04,
                                image: AssetImage(
                                    'assets/images/icon_contact.png'),
                              ),
                              Text(
                                'Add Contact',
                                style: GoogleFonts.montserrat(
                                  fontSize: ScreenWidth * .035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, ScreenHeight *.05, 0, ScreenHeight *.05),
                      child: Container(
                        height: ScreenHeight * .06,
                        width: ScreenWidth * .46,
                        child: ElevatedButton(
                          onPressed: () {
                            if (showDelete){
                              setState(() {
                                showDelete = false;
                                print(showDelete);
                              });
                            } else {
                              setState(() {
                                showDelete = true;
                                print(showDelete);
                              });
                            }


                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(ScreenWidth * .02),
                            ),
                            backgroundColor: Colors.red[300],
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Image(
                                width: ScreenWidth * .05,
                                height: ScreenHeight * .04,
                                image: AssetImage(
                                    'assets/images/icon_contact.png'),
                              ),
                              Text(
                                'Delete Contact',
                                style: GoogleFonts.montserrat(
                                  fontSize: ScreenWidth * .035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: ScreenWidth,
                      color: Colors.white,
                      child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: angelContacts,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      //.93 HEIGHT REMAINS
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
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                HomePage())
                    );
                  },
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
