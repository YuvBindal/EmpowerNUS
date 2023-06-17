import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:async';
import 'chatMessage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    title: 'EmpowerNUS',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
      useMaterial3: true,
    ),
    home: ChatBot(),
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
      ResolutionPreset.high,
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
    } finally {
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<void> uploadImageToFirebase(String imagePath) async {
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

  Future<void> uploadVideoToFirebase(String videoPath) async {
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

      print('Video uploaded. Download URL: $downloadURL');

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
            Container(
              // camera goes here
              width: ScreenWidth * 1,
              height: ScreenHeight * .70,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.red,
                    width: _isTakingPicture ? 5.0 : 0.0),
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
                  (_picStorage)
                      ? Text('true')
                      : Text(
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
                        fontSize: ScreenWidth * 0.05 * 1.1,
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
                      onPressed: (!_isTakingPicture) ? startRecording : stopRecording,
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

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages  = [];
  late OpenAI? chatGPT;


  @override
  void initState() {
    chatGPT = OpenAI.instance.build(
      token: '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',
      baseOption: HttpSetup(receiveTimeout: Duration(seconds:60000)));
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
        sender: "user"
    ); // need to fetch username and replace here


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
            decoration: InputDecoration.collapsed(hintText: "Got any questions?"),
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

      appBar: AppBar(title:

        Center(
          child: Text(
              "Crime Fighting GPT",
            style: GoogleFonts.openSans(),
          ),
        )
      ),

      body: SafeArea(
        child: Column(
          children:  [
            Flexible (
              child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                scrollDirection: Axis.vertical,
                itemBuilder:(context, index) {
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
