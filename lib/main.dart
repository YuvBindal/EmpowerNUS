import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                                builder: (context) => loginPage()));
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
                            builder: (context) => loginPage()));
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

class loginPage extends StatefulWidget {
  const loginPage({Key? key}) : super(key: key);

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
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
            //.6
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: TextField(
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
                    //redirect to forgot password page
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
            //.85
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
                    //getting started logic (redirect to lo.gin page)
                  },
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
            //.93
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

                        //sign up logic goes here
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
