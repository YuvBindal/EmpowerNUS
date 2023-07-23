import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:flutter_driver/driver_extension.dart';

//add a cross, add it to display on angelContacts when delete contacts is selected,
//add a confirmation, when delete it is hit run a searching algo

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

void main() async {
  enableFlutterDriverExtension();
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
    home: LoginPage(),
  ));
}

class getStarted extends StatefulWidget {
  const getStarted({Key? key}) : super(key: key);

  @override
  State<getStarted> createState() => _getStartedState();
}

class _getStartedState extends State<getStarted> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double ScreenFont = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: screenHeight * .05),
            Center(
              child: Container(
                width: screenWidth * .8,
                height: screenHeight * .15,
                child: Image.asset('assets/images/Icon_Logo.png'),
              ),
            ),
            SizedBox(height: screenHeight * .05),
            Center(
              child: Container(
                width: screenWidth * .8,
                height: screenHeight * .30,
                child: Image.asset('assets/images/Icon_GetStartedImage.png'),
              ),
            ),
            SizedBox(height: screenHeight * .05),
            Center(
              child: Container(
                width: screenWidth * .8,
                height: screenHeight * .25,
                child: Image.asset('assets/images/Icon_GetStartedText.png'),
              ),
            ),
            Center(
              child: Container(
                width: screenWidth * .8,
                height: screenHeight * .08,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.teal[100], // Set the background color
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RegisterPage()));
                  },
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: ScreenFont * 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: ScreenFont * 1.25,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
//  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
//    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      print('The passwords do not match.');
      return;
    }

    // Check if username is already taken
    final usernameSnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: _usernameController.text)
        .get();

    if (usernameSnapshot.docs.length > 0) {
      print('Username already exists. Please choose another username.');
      return;
    }

    // If username is not taken, continue with registration
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // If registration is successful, add user data to Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': _usernameController.text,
          'email': _emailController.text,
        });

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenFont = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Icon_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: screenHeight * .05),
              Center(
                child: Container(
                  width: screenWidth * .8,
                  height: screenHeight * .15,
                  child: Image.asset('assets/images/Icon_Logo.png'),
                ),
              ),
              SizedBox(height: screenHeight * .05),
              Center(
                child: Container(
                  width: screenWidth * .8,
                  height: screenHeight * .20,
                  child: Image.asset('assets/images/Icon_RegisterText.png'),
                ),
              ),
              Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: screenFont * 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: screenFont,
                  ),
                  textAlign: TextAlign.justify,
                  cursorColor: Colors.black38,
                  maxLines: 1,
                ),
              ),
              Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: screenFont * 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: screenFont,
                  ),
                  textAlign: TextAlign.justify,
                  cursorColor: Colors.black38,
                  maxLines: 1,
                ),
              ),
              Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  maxLength: 12,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: screenFont * 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: screenFont,
                  ),
                  textAlign: TextAlign.justify,
                  cursorColor: Colors.black38,
                  maxLines: 1,
                ),
              ),
              Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  maxLength: 12,
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: screenFont * 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: screenFont,
                  ),
                  textAlign: TextAlign.justify,
                  cursorColor: Colors.black38,
                  maxLines: 1,
                ),
              ),
              Center(
                child: Container(
                  width: screenWidth * .8,
                  height: screenHeight * .08,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[100],
                    ),
                    onPressed: () {
                      _registerUser();
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: screenFont * 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: screenFont * 1.25,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Have an account already?',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: screenFont * 14,
                        letterSpacing: screenFont,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginPage()));
                      },
                      child: Text('Sign in'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle the error in your app here.
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenFont = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Icon_Background.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: screenHeight * .05),
                Center(
                  child: Container(
                    width: screenWidth * .8,
                    height: screenHeight * .15,
                    child: Image.asset('assets/images/Icon_Logo.png'),
                  ),
                ),
                Center(
                  child: Container(
                    width: screenWidth * .8,
                    height: screenHeight * .05,
                    child: Image.asset('assets/images/Icon_LoginText.png'),
                  ),
                ),
                Center(
                  child: Container(
                    width: screenWidth * 1,
                    height: screenHeight * .35,
                    child: Image.asset('assets/images/Icon_LoginImage.png'),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: screenFont * 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: screenFont,
                    ),
                    textAlign: TextAlign.justify,
                    cursorColor: Colors.black38,
                    maxLines: 1,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    maxLength: 12,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: screenFont * 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: screenFont,
                    ),
                    textAlign: TextAlign.justify,
                    cursorColor: Colors.black38,
                    maxLines: 1,
                  ),
                ),
                Container(
                  width: screenWidth * 1,
                  height: screenHeight * .05,
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ResetPasswordPage()));
                      },
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: screenFont * 16,
                          decoration: TextDecoration.underline,
                          letterSpacing: screenFont,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: screenWidth * .8,
                    height: screenHeight * .08,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.teal[100], // Set the background color
                      ),
                      onPressed: _login,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: screenFont * 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: screenFont * 1.25,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: screenHeight * .07,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontSize: screenFont * 14,
                            letterSpacing: screenFont,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RegisterPage()));
                          },
                          child: Text('Sign up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred while sending password reset email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter an email'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    _resetPassword(_emailController.text);
                  }
                },
                child: Text('Reset Password'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal, // background
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
List<String> pdfReports = [];


class Scanner extends StatefulWidget {
  @override
  State<Scanner> createState() => ScannerState();
}

class ScannerState extends State<Scanner> {
  late CameraController? controller;
  bool _isCameraInitialized = false;
  bool get isCameraInitialized => _isCameraInitialized;
  bool _isFrontCamera = false;
  bool _isTakingPicture = false;
  bool _picStorage = false;
  bool _isLoadingReport = false;
  List<ReportFrame> reportFrames = [];
  late Future<String> currentUrl;
  int index= 0;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
  void addFrame(Future<String> policeUrl) {
    setState(() {
      reportFrames.add(ReportFrame(frameUrl: policeUrl));
      _isLoadingReport = false;
    });
  }
  Future<String> fetchReportUrl() async {
    final url = Uri.http('10.0.2.2:5000', '/reportGen');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        pdfReports.add(jsonData['photo_reports'][0].toString());
        for (int i =0; i< pdfReports.length; i++) {
          print(pdfReports[i]);
        }
      });
      return jsonData['photo_reports'][0].toString();
      //after verifications push angelDetails to angels list, store to firebase. reset angelDetails
    } else {
      return 'There was an error';

    }
  }

  Future<String> fetchVideoUrl() async {
    final url = Uri.http('10.0.2.2:5000', '/reportGenVideos');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        pdfReports.add(jsonData['video_reports'][0].toString());
        for (int i =0; i< pdfReports.length; i++) {
          print(pdfReports[i]);
        }
      });
      return jsonData['video_reports'][0].toString();
      //after verifications push angelDetails to angels list, store to firebase. reset angelDetails
    } else {
      return 'There was an error';

    }
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final camera = _isFrontCamera ? cameras.last : cameras.first;
    controller = CameraController(
      camera,
      ResolutionPreset.high,
    );

    try {
      await controller!.initialize();
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

    controller!.dispose();
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
      final XFile picture = await controller!.takePicture();
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
      setState(() {
        currentUrl = fetchReportUrl();
      });

      addFrame(currentUrl);
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
      setState(() {
        currentUrl = fetchVideoUrl();
      });
      addFrame(currentUrl);
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
        await controller!.startVideoRecording();
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
        final XFile videoFile = await controller!.stopVideoRecording();
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
                      aspectRatio: controller!.value.aspectRatio,
                      child: CameraPreview(controller!),
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
