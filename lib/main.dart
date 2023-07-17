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
import 'package:url_launcher/url_launcher.dart';

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
      home: const RegisterPage(),
    );
  }
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
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
          'fullname': _nameController.text,
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
                    onPressed: _registerUser,
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
                  leading: Icon(Icons.add_alert),
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
                ListTile(
                  leading: Icon(Icons.manage_accounts),
                  title: Text('Manage Account'),
                  onTap: () {
                    // TODO: Handle item 1 press
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => AccountPage()),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => AccountPage()),
                        );
                      },
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
                    child: ClipOval(
                      child: Image(
                        image: imageProvider,
                        width: 500,
                        height: 500,
                        fit: BoxFit.cover,
                      ),
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
                                      ChatListPage(
                                        chats: [chats[0], chats[1]],
                                      )),
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

  Map<String, List<Map<String, String>>> resources = {
    'All': [],
    'Assault': [
      {
        'title': 'Preventing Assault',
        'url': 'https://www.apa.org/topics/violence/preventing-assault'
      },
      {
        'title': 'Safety and Self-Defence',
        'url': 'https://www.rainn.org/articles/safety-and-self-defense-tips'
      },
    ],
    'Burglary/Robbery/Theft': [
      {
        'title': 'Prevent Home Burglary',
        'url':
            'https://www.safewise.com/home-security-faq/how-to-prevent-burglary/'
      },
      {
        'title': 'Prevent Car Theft',
        'url': 'https://www.nhtsa.gov/road-safety/vehicle-theft-prevention'
      },
    ],
    'Vandalism': [
      {
        'title': 'Prevent Vandalism',
        'url':
            'https://www.ncpc.org/resources/home-property-crime/prevent-auto-theft/'
      },
      {
        'title': 'Vandalism Facts',
        'url':
            'https://www.conserve-energy-future.com/various-vandalism-facts.php'
      },
    ],
    'Fraud': [
      {
        'title': 'Prevent Fraud',
        'url':
            'https://www.ftc.gov/faq/consumer-protection/defend-against-identity-theft'
      },
      {
        'title': 'Understanding Fraud',
        'url':
            'https://www.aarp.org/money/scams-fraud/info-2019/fraud-types.html'
      },
    ],
    'Harassment': [
      {'title': 'Prevent Harassment', 'url': 'https://www.eeoc.gov/harassment'},
      {
        'title': 'Understanding Harassment',
        'url': 'https://www.stopbullying.gov/cyberbullying/what-is-it'
      },
    ],
    'Drug Abuse': [
      {
        'title': 'Understanding Drug Abuse',
        'url':
            'https://www.drugabuse.gov/publications/drugs-brains-behavior-science-addiction/drug-abuse-addiction'
      },
      {
        'title': 'Prevent Drug Abuse',
        'url': 'https://www.cdc.gov/drugoverdose/prevention/index.html'
      },
    ],
    'Others': [
      {
        'title': 'General Safety Tips',
        'url': 'https://www.ready.gov/be-informed'
      },
      {
        'title': 'Preventing Crime',
        'url': 'https://www.crimesolutions.gov/TopicDetails.aspx?ID=63'
      },
    ],
  };

  void launchURL(String url) async {
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // double screenFont = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
        ),
        title: Text("Education Resources"),
        backgroundColor: Colors.teal,
        elevation: 0.0,
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
            SizedBox(height: screenHeight * .01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: resources.keys.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
            Container(
              height: screenHeight * 0.7,
              child: ListView.builder(
                itemCount: resources[_selectedCategory!]?.length ?? 0,
                itemBuilder: (context, index) {
                  if (_selectedCategory == 'All') {
                    return ListTile(
                      title: Text(
                          resources[_selectedCategory!]?[index]['title'] ?? ''),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => (resources == null)
                              ? Center(child: CircularProgressIndicator())
                              : SubCategoryPage(
                                  category: resources.keys.toList()[index],
                                  resources: resources,
                                  launchURL: (url) => launchURL(url),
                                ),
                        ),
                      ),
                    );
                  } else {
                    return ListTile(
                      title: Text(
                          resources[_selectedCategory!]?[index]['title'] ?? ''),
                      onTap: () => launchURL(
                          resources[_selectedCategory!]?[index]['url'] ?? ''),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPage(
                category: _selectedCategory!,
                questions: quizQuestions[_selectedCategory!]!,
              ),
            ),
          );
        },
        child: Icon(Icons.quiz_rounded),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class SubCategoryPage extends StatelessWidget {
  final String category;
  final Map<String, List<Map<String, String>>> resources;
  final Function launchURL;

  SubCategoryPage(
      {required this.category,
      required this.resources,
      required this.launchURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: resources[category]?.length ?? 0,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(resources[category]?[index]['title'] ?? ''),
            onTap: () => launchURL(resources[category]?[index]['url'] ?? ''),
          );
        },
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion(
      {required this.question,
      required this.options,
      required this.correctAnswer});
}

Map<String, List<QuizQuestion>> quizQuestions = {
  'Assault': [
    QuizQuestion(
      question: 'What should you do if you are assaulted?',
      options: [
        'Get to a safe place and call 911',
        'Ignore it',
        'Fight back',
        'Reason with the assaulter',
      ],
      correctAnswer: 'Get to a safe place and call 911',
    ),
    QuizQuestion(
      question: 'What is one recommended self-defense method?',
      options: [
        'Trust your instincts and use your voice',
        'Reason with the attacker',
        'Retaliate physically',
        'Run towards secluded areas'
      ],
      correctAnswer: 'Trust your instincts and use your voice',
    ),
    QuizQuestion(
      question: 'What are some preventive measures against assault?',
      options: [
        'Awareness, assertiveness, avoiding risk situations',
        'Taking self-defense classes',
        'Always carry a weapon',
        'Avoid going out'
      ],
      correctAnswer: 'Awareness, assertiveness, avoiding risk situations',
    ),
    QuizQuestion(
      question: 'Should you try to reason with an attacker?',
      options: [
        'Yes',
        'No',
        'Only if you know them',
        'Only if they are unarmed'
      ],
      correctAnswer: 'No',
    ),
    QuizQuestion(
      question: 'True or False: It is recommended to walk alone at night.',
      options: [
        'True',
        'False',
        'Only in well-lit areas',
        'Only in your neighborhood'
      ],
      correctAnswer: 'False',
    ),
  ],
  'Burglary/Robbery/Theft': [
    QuizQuestion(
      question: 'What is an effective way to discourage home burglary?',
      options: [
        'Installing a home security system',
        'Leaving lights on',
        'Putting a "Beware of Dog" sign',
        'Leaving the doors open'
      ],
      correctAnswer: 'Installing a home security system',
    ),
    QuizQuestion(
      question: 'What should you do if your house has been burglarized?',
      options: [
        'Investigate yourself',
        'Clean up the mess',
        'Leave immediately and call the police',
        'Wait for the burglar to return'
      ],
      correctAnswer: 'Leave immediately and call the police',
    ),
    QuizQuestion(
      question: 'How can you help prevent car theft?',
      options: [
        'Leave windows open',
        'Always lock your doors and never leave your car running unattended',
        'Leave car keys in the ignition',
        'Park in dark areas'
      ],
      correctAnswer:
          'Always lock your doors and never leave your car running unattended',
    ),
    QuizQuestion(
      question: 'What can you do to protect yourself from pickpockets?',
      options: [
        'Carry your wallet in your hand',
        'Keep your wallet in a front pocket',
        'Leave your bag open',
        'Flaunt expensive items'
      ],
      correctAnswer: 'Keep your wallet in a front pocket',
    ),
    QuizQuestion(
      question:
          'What is an effective way to protect your personal belongings in a public place?',
      options: [
        'Leave them unattended',
        'Hide them under your chair',
        'Lend them to strangers',
        'Keep your belongings in sight at all times'
      ],
      correctAnswer: 'Keep your belongings in sight at all times',
    ),
  ],
  'Vandalism': [
    QuizQuestion(
      question: 'What should you do if you witness vandalism?',
      options: [
        'Join in',
        'Ignore it',
        'Record it and post it online',
        'Report it to the police'
      ],
      correctAnswer: 'Report it to the police',
    ),
    QuizQuestion(
      question: 'What is a common cause of school vandalism?',
      options: [
        'Peer pressure',
        'Too much homework',
        'Poor cafeteria food',
        'Lack of sports activities'
      ],
      correctAnswer: 'Peer pressure',
    ),
    QuizQuestion(
      question: 'How can community involvement help to reduce vandalism?',
      options: [
        'By fostering a sense of responsibility and belonging',
        'By ignoring the problem',
        'By encouraging competitive vandalism',
        'By blaming outsiders'
      ],
      correctAnswer: 'By fostering a sense of responsibility and belonging',
    ),
    QuizQuestion(
      question:
          'True or False: Cleaning up vandalism promptly can help to deter further vandalism.',
      options: ['True', 'False', 'Sometimes', 'Only on Tuesdays'],
      correctAnswer: 'True',
    ),
    QuizQuestion(
      question: 'How can you help to prevent vandalism in your neighborhood?',
      options: [
        'By reporting suspicious activities to the police',
        'By turning a blind eye',
        'By moving to another neighborhood',
        'By organizing a vandalism party'
      ],
      correctAnswer: 'By reporting suspicious activities to the police',
    ),
  ],
  'Fraud': [
    QuizQuestion(
      question:
          'What is one common method fraudsters use to steal personal information?',
      options: [
        'Phishing',
        'Writing a book',
        'Making a documentary',
        'Hosting a TV show'
      ],
      correctAnswer: 'Phishing',
    ),
    QuizQuestion(
      question: 'What is a good preventative measure against identity theft?',
      options: [
        'Share your passwords',
        'Post your credit card numbers online',
        'Regularly review your credit reports',
        'Use simple passwords'
      ],
      correctAnswer: 'Regularly review your credit reports',
    ),
    QuizQuestion(
      question: 'What should you do if you become a victim of fraud?',
      options: [
        'Report it to the local authorities and your bank',
        'Celebrate',
        'Tell your friends on social media',
        'Do nothing'
      ],
      correctAnswer: 'Report it to the local authorities and your bank',
    ),
    QuizQuestion(
      question:
          'True or False: You should give out personal information over the phone if the caller claims to be from your bank.',
      options: ['True', 'False', 'Maybe', 'Only if they sound friendly'],
      correctAnswer: 'False',
    ),
    QuizQuestion(
      question: 'How can you protect yourself from online scams?',
      options: [
        'Share your passwords with trusted friends',
        'Always click on links in emails',
        'Be cautious of unsolicited communications and deals that seem too good to be true',
        'Buy everything you see online'
      ],
      correctAnswer:
          'Be cautious of unsolicited communications and deals that seem too good to be true',
    ),
  ],
  'Harassment': [
    QuizQuestion(
      question: 'What is a common form of workplace harassment?',
      options: [
        'Free lunch',
        'Unwelcome comments or jokes',
        'Positive feedback',
        'Team building exercises'
      ],
      correctAnswer: 'Unwelcome comments or jokes',
    ),
    QuizQuestion(
      question: 'What should you do if you are being harassed?',
      options: [
        'Laugh it off',
        'Ignore it',
        'Document the incidents and report them',
        'Encourage the harasser'
      ],
      correctAnswer: 'Document the incidents and report them',
    ),
    QuizQuestion(
      question: 'True or False: Cyberbullying is a form of harassment.',
      options: ['True', 'False', 'Maybe', 'It depends'],
      correctAnswer: 'True',
    ),
    QuizQuestion(
      question: 'How can you help to prevent harassment in the workplace?',
      options: [
        'Promote a positive, respectful work environment',
        'Spread rumors',
        'Make unwelcome jokes',
        'Exclude certain people from team activities'
      ],
      correctAnswer: 'Promote a positive, respectful work environment',
    ),
    QuizQuestion(
      question:
          'What action should a company take if an employee reports harassment?',
      options: [
        'Ignore the report',
        'Laugh it off',
        'Blame the victim',
        'Investigate the claim promptly and thoroughly'
      ],
      correctAnswer: 'Investigate the claim promptly and thoroughly',
    ),
  ],
  'Drug Abuse': [
    QuizQuestion(
      question: 'What are some common signs of drug abuse?',
      options: [
        'Change in behavior, neglecting responsibilities, health issues',
        'Increased appetite, more physical activity, better sleep',
        'Increased productivity, better relationships, improved health',
        'Improved mood, higher energy levels, better concentration'
      ],
      correctAnswer:
          'Change in behavior, neglecting responsibilities, health issues',
    ),
    QuizQuestion(
      question:
          'What should you do if you suspect a loved one is abusing drugs?',
      options: [
        'Join them',
        'Ignore the problem',
        'Express your concerns in a supportive way and encourage them to seek help',
        'Blame them for their problems'
      ],
      correctAnswer:
          'Express your concerns in a supportive way and encourage them to seek help',
    ),
    QuizQuestion(
      question: 'True or False: Prescription medications cannot be addictive.',
      options: ['True', 'False', 'Maybe', 'It depends'],
      correctAnswer: 'False',
    ),
    QuizQuestion(
      question: 'What is a common consequence of drug abuse?',
      options: [
        'Physical health problems',
        'Improved mental health',
        'Better relationships',
        'Increased productivity'
      ],
      correctAnswer: 'Physical health problems',
    ),
    QuizQuestion(
      question:
          'What is one effective approach to preventing drug abuse in youth?',
      options: [
        'Ignore the problem',
        'Make drugs more accessible',
        'Glamorize drug use',
        'Education and open communication'
      ],
      correctAnswer: 'Education and open communication',
    ),
  ],
};

class QuizPage extends StatefulWidget {
  final String category;
  final List<QuizQuestion> questions;

  QuizPage({required this.category, required this.questions});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _finished = false;
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
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
            SizedBox(height: screenHeight * .01),
            _finished
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Quiz Finished',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Your score: $_score/${widget.questions.length}',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: <Widget>[
                      LinearProgressIndicator(
                        value: _currentQuestionIndex / widget.questions.length,
                      ),
                      SizedBox(height: 20),
                      Text(
                        widget.questions[_currentQuestionIndex].question,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: widget
                            .questions[_currentQuestionIndex].options
                            .map((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                                if (_selectedOption ==
                                    widget.questions[_currentQuestionIndex]
                                        .correctAnswer) {
                                  _score++;
                                }
                                if (_currentQuestionIndex <
                                    widget.questions.length - 1) {
                                  _currentQuestionIndex++;
                                } else {
                                  _finished = true;
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            screenSize * .02, screenHeight * .02, screenSize * .02, 0),
        child: FractionallySizedBox(
          widthFactor: 1.2,
          child: Container(
            color: Colors.grey[300],
            height: screenHeight * .08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
              ],
            ),
          ),
        ),
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
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
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

      _firestore
          .collection('users')
          .doc(_user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          _usernameController.text = documentSnapshot.get('username') ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account Management',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your new username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: MediaQuery.of(context).textScaleFactor * 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: MediaQuery.of(context).textScaleFactor,
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
                      fontSize: MediaQuery.of(context).textScaleFactor * 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: MediaQuery.of(context).textScaleFactor,
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
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: MediaQuery.of(context).textScaleFactor * 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: MediaQuery.of(context).textScaleFactor,
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
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: MediaQuery.of(context).textScaleFactor * 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: MediaQuery.of(context).textScaleFactor,
                    ),
                    textAlign: TextAlign.justify,
                    cursorColor: Colors.black38,
                    maxLines: 1,
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Change Panic Button Image'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.teal),
                  ),
                ),
                ElevatedButton(
                  onPressed: _save,
                  child: Text('Save'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            screenSize * .02, screenHeight * .02, screenSize * .02, 0),
        child: FractionallySizedBox(
          widthFactor: 1.2,
          child: Container(
            color: Colors.grey[300],
            height: screenHeight * .08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Chat.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
                IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: screenSize * .1,
                ),
              ],
            ),
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
      int randomNumber = DateTime.now().millisecondsSinceEpoch;
      String imageLocation = 'images/image$randomNumber.jpg';
      await FirebaseStorage.instance.ref(imageLocation).putFile(image);
      String downloadUrl =
          await FirebaseStorage.instance.ref(imageLocation).getDownloadURL();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('bearImageUrl', downloadUrl);

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String email = _emailController.text;
      String username = _usernameController.text;
      String password = _passwordController.text;

      if (_user != null) {
        _user!.updateDisplayName(name);
        _user!.updateEmail(email);
        _user!.updatePassword(password);

        _firestore.collection('users').doc(_user!.uid).update({
          'username': username,
        });
      }
    }
  }
}

class ChatPage extends StatefulWidget {
  final String username;

  const ChatPage({Key? key, required this.username}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Future<void> callback() async {
    if (messageController.text.length > 0) {
      await FirebaseFirestore.instance.collection('messages').add({
        'text': messageController.text,
        'from': FirebaseAuth.instance.currentUser?.email,
        'to': widget.username,
        'time': FieldValue.serverTimestamp(),
      });
      messageController.clear();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where('to', isEqualTo: widget.username)
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    List<DocumentSnapshot> docs = snapshot.data!.docs;
                    List<Widget> messages = docs
                        .map((doc) => Message(
                              from: doc['from'],
                              text: doc['text'],
                              me: FirebaseAuth.instance.currentUser?.email ==
                                  doc['from'],
                            ))
                        .toList();

                    return ListView(
                      controller: scrollController,
                      children: <Widget>[
                        ...messages,
                      ],
                    );
                  }
                },
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onSubmitted: (value) => callback(),
                      decoration: InputDecoration(
                        hintText: "Enter a Message...",
                        border: const OutlineInputBorder(),
                      ),
                      controller: messageController,
                    ),
                  ),
                  SendButton(
                    text: "Send",
                    callback: callback,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            ScreenSize * .02, ScreenHeight * .02, ScreenSize * .02, 0),
        child: FractionallySizedBox(
          widthFactor: 1.2,
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
                              ChatPage(username: widget.username)),
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
                          builder: (BuildContext context) => HomePage()),
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
                          builder: (BuildContext context) => education_Page()),
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
    );
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({required this.text, required this.callback});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.send),
      onPressed: callback,
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;
  final bool me;

  const Message({required this.from, required this.text, required this.me});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(from),
          Material(
            color: me ? Colors.teal : Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            elevation: 6.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(text),
            ),
          )
        ],
      ),
    );
  }
}

class Chat {
  final String username;
  final String lastMessage;
  final String avatarUrl;

  Chat({
    required this.username,
    required this.lastMessage,
    required this.avatarUrl,
  });
}

List<Chat> chats = [
  Chat(
      username: 'John',
      lastMessage: 'Hello!',
      avatarUrl: 'assets/images/user.png'),
  Chat(
      username: 'Ben',
      lastMessage: 'How are you?',
      avatarUrl: 'assets/images/user.png'),
];

class ChatListPage extends StatelessWidget {
  final List<Chat> chats;

  ChatListPage({required this.chats});

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: // AppBar in ChatListPage:

          AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_comment),
            tooltip: 'New Message',
            onPressed: () {
              // Navigate to the NewMessageScreen1 when this button is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewMessageScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            tooltip: 'Add Friends',
            onPressed: () {
              // Navigate to the AddFriendsScreen when this button is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFriendsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(chats[index].avatarUrl),
              ),
              title: Text(chats[index].username),
              subtitle: Text(chats[index].lastMessage),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to chat page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatPage(username: chats[index].username),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
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
                          builder: (BuildContext context) => ChatListPage(
                                chats: [chats[0], chats[1]],
                              )),
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
                          builder: (BuildContext context) => HomePage()),
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
                          builder: (BuildContext context) => education_Page()),
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
    );
  }
}

class AddFriendsScreen extends StatefulWidget {
  AddFriendsScreen({Key? key}) : super(key: key);

  @override
  _AddFriendsScreenState createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUser = FirebaseAuth.instance.currentUser!.uid;
  String _email = '';

  // Sends a friend request
  Future<void> sendFriendRequest(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    print('Query results: ${querySnapshot.docs}');

    if (querySnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user found with that email')),
      );
      return;
    }

    final userDoc = querySnapshot.docs.first;

    await _firestore.collection('friend_requests').add({
      'senderId': _currentUser,
      'receiverId': userDoc.id,
      'status': 'pending',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friends'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Enter email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    _email = value!;
                  });
                },
              ),
              ElevatedButton(
                child: Text('Add Friend'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Now you can use _email to add the friend
                    sendFriendRequest(_email);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
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
                          builder: (BuildContext context) => ChatListPage(
                                chats: [chats[0], chats[1]],
                              )),
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
                          builder: (BuildContext context) => HomePage()),
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
                          builder: (BuildContext context) => education_Page()),
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
    );
  }
}

class NewMessageScreen extends StatefulWidget {
  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final messageController = TextEditingController();
  String dropdownValue = 'Friend 1'; // Initialize to first friend

  Future<void> sendMessage() async {
    if (messageController.text.length > 0) {
      // Implement your message sending logic here.
    }
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Message'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Image_Background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButton<String>(
                value: dropdownValue,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Friend 1', 'Friend 2', 'Friend 3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Enter your message here",
                ),
              ),
              ElevatedButton(
                onPressed: sendMessage,
                child: Text('Send Message'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
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
                          builder: (BuildContext context) => ChatListPage(
                                chats: [], // Pass the chat list
                              )),
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
                          builder: (BuildContext context) => HomePage()),
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
                          builder: (BuildContext context) => education_Page()),
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
    );
  }
}
