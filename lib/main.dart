import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
class ReportPage extends StatefulWidget {
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? selectedItem = 'Assault';
  File? _selectedFile;
  final String siteKey = '6Lf2XT0mAAAAANdtrwTe9ugodykvwUmuxp9cNshh';

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 35.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              SizedBox(height: 10.0),
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
              SizedBox(height: 25.0),
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
              SizedBox(height: 10.0),
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
              SizedBox(height: 8.0),
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
              SizedBox(height: 10.0),
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
              SizedBox(height: 5.0),
              InkWell(
                onTap: _selectFile,
                child: Image.asset(
                  'assets/images/Icon_Files.png',
                  width: 300.0,
                  height: 175.0,
                ),
              ),
              SizedBox(height: 10.0),
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
                    onPressed: () {
                      // Perform submit logic (store to backend);
                    },
                    child: Text('Deploy Report'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green[400]),
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


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _panicModeOn = false;

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: EdgeInsets.fromLTRB(16, 25, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () {},
                    icon: ImageIcon(
                      AssetImage('assets/images/Icon_TabBar.png'),
                      size: 24,
                      color: null,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: ImageIcon(
                      AssetImage('assets/images/Icon_Camera.png'),
                      size: 33,
                      color: null,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: ImageIcon(
                      AssetImage('assets/images/Icon_Avatar.png'),
                      color: null,
                    ),
                    iconSize: 40,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 0, 0),
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {},
                  child: Image(
                    image: AssetImage('assets/images/Icon_Alert_Bear.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.fromLTRB(16, 23, 16, 0),
              child: FractionallySizedBox(
                widthFactor: 1.2, // Take up the full available width
                child: Container(
                  color: Colors.grey[300],
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {},
                        icon: ImageIcon(
                          AssetImage('assets/images/Icon_Chat.png'),
                          color: null,
                        ),
                        iconSize: 45,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: ImageIcon(
                          AssetImage('assets/images/Icon_Network.png'),
                          color: null,
                        ),
                        iconSize: 45,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: ImageIcon(
                          AssetImage('assets/images/Icon_Home.png'),
                          color: null,
                        ),
                        iconSize: 45,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: ImageIcon(
                          AssetImage('assets/images/Icon_Read.png'),
                          color: null,
                        ),
                        iconSize: 45,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: ImageIcon(
                          AssetImage('assets/images/Icon_Map.png'),
                          color: null,
                        ),
                        iconSize: 45,
                      ),
                    ],
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


