import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const registerPage(),
    );
  }
}

//login page 3 sections: getting started, sign up , register.

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
            image: AssetImage('assets/images/Icon_Background.png'),
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
                        builder: (context) => registerPage()));
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

class registerPage extends StatefulWidget {
  const registerPage({Key? key}) : super(key: key);

  @override
  State<registerPage> createState() => _registerPageState();
}

class _registerPageState extends State<registerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
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
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.1,
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
                    onPressed: () async {
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        print('The passwords do not match.');
                      } else {
                        try {
                          UserCredential userCredential =
                              await _auth.createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          if (userCredential.user != null) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginPage()));
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
                            builder: (context) => registerPage()));
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

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _panicModeOn = false;
  String _defaultBearImageUrl =
      'assets/images/Icon_Alert_Bear.png'; // Default bear image
  String? _bearImageUrl;

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  void _loadImageUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? bearImageUrl = prefs.getString('bearImageUrl');
    if (bearImageUrl != null) {
      setState(() {
        _bearImageUrl = bearImageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    // Image Provider
    ImageProvider imageProvider;
    if (_bearImageUrl != null) {
      imageProvider = NetworkImage(_bearImageUrl!);
    } else {
      imageProvider = AssetImage(_defaultBearImageUrl);
    }

    return ScaffoldMessenger(
      child: Scaffold(
        drawer: Container(
          width: ScreenSize * .5,
          child: Drawer(
            child: ListView(
              children: <Widget>[
                Container(
                  height: ScreenHeight * .15,
                  child: DrawerHeader(
                    child: Text(
                      'EmpowerNUS',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 24 * MediaQuery.of(context).textScaleFactor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.25,
                        color: Colors.black,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Deploy Report'),
                  onTap: () {
                    // TODO: Handle item 1 press
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ReportPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log out'),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Image_Background.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, ScreenHeight * .05, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Builder(builder: (context) {
                      return IconButton(
                        onPressed: () => {
                          Scaffold.of(context).openDrawer(),
                        },
                        icon: ImageIcon(
                          AssetImage('assets/images/Icon_TabBar.png'),
                          size: ScreenHeight * .035,
                          color: null,
                        ),
                      );
                    }),
                    IconButton(
                      onPressed: () {},
                      icon: ImageIcon(
                        AssetImage('assets/images/Icon_Camera.png'),
                        size: ScreenHeight * .05,
                        color: null,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: ImageIcon(
                        AssetImage('assets/images/Icon_Avatar.png'),
                        color: null,
                      ),
                      iconSize: ScreenHeight * .07,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    ScreenSize * .03, ScreenHeight * .01, 0, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome back,\nUserName!',
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    ScreenSize * .03, ScreenHeight * .02, ScreenSize * .03, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Panic Mode: ',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.red[400],
                      ),
                    ),
                    Text(
                      (_panicModeOn) ? 'On' : 'Off',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(ScreenHeight * .01),
                  child: GestureDetector(
                    onTap: () {},
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    ScreenSize * .02, ScreenHeight * .02, ScreenSize * .02, 0),
                child: FractionallySizedBox(
                  widthFactor: 1.2, // Take up the full available width
                  child: Container(
                    color: Colors.grey[300],
                    height: ScreenHeight * .08,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {},
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Chat.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize * .1,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AccountPage()),
                            );
                          },
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Network.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize * .1,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      HomePage()),
                            );
                          },
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Home.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize * .1,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      education_Page()),
                            );
                          },
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Read.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize * .1,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Map.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize * .1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportPage extends StatefulWidget {
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? selectedItem = 'Assault';
  File? _selectedFile;
  final String siteKey = '6Lf2XT0mAAAAANdtrwTe9ugodykvwUmuxp9cNshh';
  final TextEditingController _descriptionController =
      TextEditingController(); // To control the description TextField

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      // Generate a unique ID for the file
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a reference to the file location
      Reference reference = FirebaseStorage.instance.ref().child(fileName);

      // Upload the file
      UploadTask uploadTask = reference.putFile(file);

      // Wait until the file is uploaded
      TaskSnapshot taskSnapshot = await uploadTask;

      // Check if the upload is successful
      if (taskSnapshot.state == TaskState.success) {
        // Retrieve the download url
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        print('Upload failed: ${taskSnapshot.state}');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _submitReport(String? fileUrl) async {
    await FirebaseFirestore.instance.collection('reports').add({
      'reportType': selectedItem,
      'description': _descriptionController.text,
      'fileUrl': fileUrl,
    });
  }

  void _showCaptchaDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify CAPTCHA'),
          content: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            child: WebviewScaffold(
              url: 'https://www.google.com/recaptcha/api2/anchor?k=$siteKey',
              withJavascript: true,
              withLocalStorage: true,
            ),
          ),
          actions: [
            ElevatedButton(
              child: Text('VERIFY'),
              onPressed: () {
                // Perform CAPTCHA verification logic
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<String>> dropdownItems = [
    DropdownMenuItem(
      value: 'Assault',
      child: Text('Assault'),
    ),
    DropdownMenuItem(
      value: 'Burglary/Robbery/Theft',
      child: Text('Burglary/Robbery/Theft'),
    ),
    DropdownMenuItem(
      value: 'Vandalism',
      child: Text('Vandalism'),
    ),
    DropdownMenuItem(
      value: 'Fraud',
      child: Text('Fraud'),
    ),
    DropdownMenuItem(
      value: 'Harassment',
      child: Text('Harassment'),
    ),
    DropdownMenuItem(
      value: 'Drug Abuse',
      child: Text('Drug Abuse'),
    ),
    DropdownMenuItem(
      value: 'Others',
      child: Text('Others'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;
    double ScreenFont = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ScreenHeight * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Anonymous Reporting',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ScreenHeight * .01),
              Text(
                'Seen something wrong? Report it!',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ScreenHeight * .01),
              DropdownButton<String>(
                value: selectedItem,
                items: dropdownItems,
                onChanged: (value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
                hint: Text(
                  'Select an option',
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                // Button options styling
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
                dropdownColor: Colors.black,
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ScreenHeight * .02),
              Text(
                'Description',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.25,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ScreenHeight * .01),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    width: 2.0,
                    color: Colors.white,
                    style: BorderStyle.solid,
                  ),
                ),
                child: SingleChildScrollView(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter your text here',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.25,
                    ),
                    textAlign: TextAlign.justify,
                    cursorColor: Colors.black38,
                    maxLines: null,
                  ),
                ),
              ),
              SizedBox(height: ScreenHeight * .02),
              Text(
                'Upload Media',
                style: TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.25,
                  color: Colors.white,
                ),
              ),
              // other widgets...
              InkWell(
                onTap: _selectFile,
                child: Image.asset(
                  'assets/images/Icon_Files.png',
                  width: ScreenHeight * .65,
                  height: ScreenHeight * .20,
                ),
              ),
              SizedBox(height: ScreenHeight * .03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _showCaptchaDialog(context);
                    },
                    child: Text('Verify CAPTCHA'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomePage()),
                      );
                      if (_selectedFile != null) {
                        String? fileUrl = await _uploadFile(_selectedFile!);
                        if (fileUrl != null) {
                          await _submitReport(fileUrl);
                        } else {
                          // Error uploading the file
                        }
                      }
                    },
                    child: Text('Deploy Report'),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.green[400]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class education_Page extends StatefulWidget {
  @override
  State<education_Page> createState() => _education_PageState();
}

class _education_PageState extends State<education_Page> {
  String? _selectedCategory = 'All';
  String? _selectedMode = 'Modules';
  List<DropdownMenuItem<String>> dropdownItems = [
    DropdownMenuItem(
      value: 'All',
      child: Text('All'),
    ),
    DropdownMenuItem(
      value: 'Assault',
      child: Text('Assault'),
    ),
    DropdownMenuItem(
      value: 'Burglary/Robbery/Theft',
      child: Text('Burglary/Robbery/Theft'),
    ),
    DropdownMenuItem(
      value: 'Vandalism',
      child: Text('Vandalism'),
    ),
    DropdownMenuItem(
      value: 'Fraud',
      child: Text('Fraud'),
    ),
    DropdownMenuItem(
      value: 'Harassment',
      child: Text('Harassment'),
    ),
    DropdownMenuItem(
      value: 'Drug Abuse',
      child: Text('Drug Abuse'),
    ),
    DropdownMenuItem(
      value: 'Others',
      child: Text('Others'),
    ),
  ];

  List<DropdownMenuItem<String>> dropdownModes = [
    DropdownMenuItem(
      value: 'Modules',
      child: Text('Modules'),
    ),
    DropdownMenuItem(
      value: 'Quizzes',
      child: Text('Quizzes'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;
    double ScreenFont = MediaQuery.of(context).textScaleFactor;

    return ScaffoldMessenger(
      child: Scaffold(
        drawer: Container(
          width: ScreenWidth * .5,
          child: Drawer(
            child: ListView(
              children: <Widget>[
                Container(
                  height: ScreenHeight * .15,
                  child: DrawerHeader(
                    child: Text(
                      'EmpowerNUS',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 24 * MediaQuery.of(context).textScaleFactor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.25,
                        color: Colors.black,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Achievements'),
                  onTap: () {
                    // TODO: Handle item 1 press
                  },
                ),
                ListTile(
                  title: Text('Progress Report'),
                  onTap: () {
                    // TODO: Handle item 2 press
                  },
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Image_Background.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: ScreenHeight * .05),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Builder(builder: (context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: ImageIcon(
                        AssetImage('assets/images/Icon_TabBar.png'),
                        color: null,
                      ),
                      iconSize: ScreenHeight * .035,
                    );
                  }),
                  Padding(
                    padding: EdgeInsets.fromLTRB(ScreenWidth * .05, 0, 0, 0),
                    child: SizedBox(
                      width: ScreenWidth * .7,
                      height: ScreenHeight * .08,
                      child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                          ),
                          onChanged: (value) {
                            //perform filteration logic
                          }),
                    ),
                  ),
                ],
              ),
              //height .13 covered
              SizedBox(height: ScreenHeight * .01),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: dropdownItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    hint: Text(
                      'Select a mode',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 14 * ScreenFont,
                        fontStyle: FontStyle.italic,
                        letterSpacing: ScreenFont * 1.5,
                        color: Colors.grey[300],
                      ),
                    ),
                    // Button options styling
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * ScreenFont,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey[300],
                    ),
                    dropdownColor: Colors.grey[300],
                    underline: Container(
                      height: ScreenHeight * .001,
                      color: Colors.grey[300],
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedMode,
                    items: dropdownModes,
                    onChanged: (value) {
                      setState(() {
                        _selectedMode = value;
                      });
                    },
                    hint: Text(
                      'Select an option',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 14 * ScreenFont,
                        fontStyle: FontStyle.italic,
                        letterSpacing: ScreenFont * 1.5,
                        color: Colors.grey[300],
                      ),
                    ),
                    // Button options styling
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * ScreenFont,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey[300],
                    ),
                    dropdownColor: Colors.grey[300],
                    underline: Container(
                      height: ScreenHeight * .001,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: ScreenWidth * .8,
                    child: LinearProgressIndicator(
                      minHeight: ScreenHeight * .03,
                      color: Colors.blueAccent,
                      value: .5, //here a function keeping track of the value
                      //for courses completed by student can be returned.
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenHeight * .02),
              Container(
                width: ScreenWidth * .8,
                height: ScreenHeight * .6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenWidth * .02),
                  color: Colors.grey[700],
                ),
              )
            ],
          ),
        ),
        persistentFooterButtons: [
          Flex(
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
                          builder: (BuildContext context) => HomePage()),
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
        ],
      ),
    );
  }
}

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  User? _user;
  File? _image;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _nameController.text = _user!.displayName ?? '';
      _emailController.text = _user!.email ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Management'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.image),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              // Save button
              ElevatedButton(
                onPressed: _save,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _image = File(image.path);
      await _uploadImageToFirebase(_image!);
    }
  }

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      // Make random image name.
      int randomNumber = DateTime.now().millisecondsSinceEpoch;
      String imageLocation = 'images/image$randomNumber.jpg';

      // Upload image to firebase.
      await FirebaseStorage.instance.ref(imageLocation).putFile(image);
      String downloadUrl =
          await FirebaseStorage.instance.ref(imageLocation).getDownloadURL();

      // After uploading, save the downloadUrl in Shared Preferences.
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('bearImageUrl', downloadUrl);

      setState(() {
        // Force re-build
      });
    } catch (e) {
      print(e);
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      if (_user != null) {
        _user!.updateDisplayName(name);
        _user!.updateEmail(email);
        _user!.updatePassword(password);
      }
    }
  }
}
