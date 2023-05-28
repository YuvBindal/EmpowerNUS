import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: education_Page(),
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
    double ScreenSize  = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;
    double ScreenFont = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ScreenHeight*.05),
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
              SizedBox(height:ScreenHeight*.01),
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
              SizedBox(height: ScreenHeight*.01),
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
              SizedBox(height: ScreenHeight*.02),
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
              SizedBox(height:ScreenHeight*.01),
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
              SizedBox(height: ScreenHeight*.02),
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
              SizedBox(height:ScreenHeight*.01),
              InkWell(
                onTap: _selectFile,
                child: Image.asset(
                  'assets/images/Icon_Files.png',
                  width: ScreenHeight*.65,
                  height: ScreenHeight*.20,
                ),
              ),
              SizedBox(height: ScreenHeight*.03),
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
    double ScreenSize  = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

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
                  },
                ),
                ListTile(
                  title: Text('Item 2'),
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
              Padding(
                padding: EdgeInsets.fromLTRB(0, ScreenHeight*.05, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Builder(
                      builder: (context) {
                        return IconButton(
                          onPressed: () => {
                            Scaffold.of(context).openDrawer(),
                          },
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_TabBar.png'),
                            size: ScreenHeight*.035,
                            color: null,
                          ),
                        );
                      }
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: ImageIcon(
                        AssetImage('assets/images/Icon_Camera.png'),
                        size: ScreenHeight*.05,
                        color: null,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: ImageIcon(
                        AssetImage('assets/images/Icon_Avatar.png'),
                        color: null,
                      ),
                      iconSize: ScreenHeight*.07,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(ScreenSize*.03, ScreenHeight*.01, 0, 0),
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
                padding: EdgeInsets.fromLTRB(ScreenSize*.03, ScreenHeight*.02, ScreenSize*.03, 0),
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
                  padding: EdgeInsets.all(ScreenHeight*.01),
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
                padding:  EdgeInsets.fromLTRB(ScreenSize*.02, ScreenHeight * .02, ScreenSize*.02, 0),
                child: FractionallySizedBox(
                  widthFactor: 1.2, // Take up the full available width
                  child: Container(
                    color: Colors.grey[300],
                    height: ScreenHeight*.08,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          onPressed: () {},
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Chat.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize*.1,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Network.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize*.1,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Home.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize*.1,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Read.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize*.1,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: ImageIcon(
                            AssetImage('assets/images/Icon_Map.png'),
                            color: null,
                          ),
                          iconSize: ScreenSize*.1,
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


class education_Page extends StatefulWidget {

  @override
  State<education_Page> createState() => _education_PageState();
}

class _education_PageState extends State<education_Page> {
  String? _selectedCategory= 'All';
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
              SizedBox(height: ScreenHeight*.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: ImageIcon(
                          AssetImage('assets/images/Icon_TabBar.png'),
                          color: null,
                        ),
                        iconSize: ScreenHeight*.035,
                      );
                    }
                  ),

                  Padding(
                    padding:  EdgeInsets.fromLTRB(ScreenWidth * .05, 0, 0, 0),
                    child: SizedBox(
                      width: ScreenWidth * .7,
                      height: ScreenHeight * .08,
                      child:
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                        ),
                        onChanged: (value) {
                          //perform filteration logic
                        }
                      ),
                    ),
                  ),
                ],
              ),
              //height .13 covered
              SizedBox(height: ScreenHeight *.01),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget> [
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
                        letterSpacing: ScreenFont* 1.5,
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
                        letterSpacing: ScreenFont* 1.5,
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
                children:  <Widget>[
                  Container(
                    width: ScreenWidth * .8,
                    child: LinearProgressIndicator(
                      minHeight: ScreenHeight * .03,
                      color: Colors.blueAccent,
                      value: .5,//here a function keeping track of the value
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
        ],



      ),
    );
  }
}
