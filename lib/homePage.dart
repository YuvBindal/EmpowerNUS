import 'dart:async';

import 'package:flutter/material.dart';
import 'accountPage.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'permissons.dart';
import 'videoCapture.dart';
import 'package:meta/meta.dart'; // Import the meta package

/*
PANIC BUTTON FEATURES:
UI changes: background becomes tinted red, mode gets turned on + noise alarm  (work later)
send notifications to angels
launch emergency mode (start recording screen for 15 seconds)
generate a report and save it to panic button  history


 */





class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  bool _panicModeOn = false;

  Color _backgroundColor = Color.fromRGBO(230, 0, 0, .3); // Initial background color
  Timer? _timer;
  late TwilioFlutter twilioFlutter;
  late String? lat;
  late String? long;
  late String? googleUrl;

  Future<void> _openMap(String lat, String long) async {
    setState(() {
      googleUrl = 'The user has shared their last known location with you. https://www.google.com/maps/search/?api=1&query=$lat,$long';
    });
    for (int i = 0; i< phoneNumbers.length; i++) {
      twilioFlutter.sendSMS(toNumber: '+${phoneNumbers[i]!}', messageBody: googleUrl!);
    }


  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location perm denied forever.');
    }

    return await Geolocator.getCurrentPosition();


  }
  //listen for location updates
  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 25, //update every 25 meters moved

    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {

      setState(() {
        lat = position.latitude.toString();
        long = position.longitude.toString();
      });
    });

  }


  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        _backgroundColor = _backgroundColor == Color.fromRGBO(230, 0, 0, .3)
            ? Color.fromRGBO(255, 0, 0, .1)
            : Color.fromRGBO(230, 0, 0, .3); // work with color scheme
      });
    });
  }






  String _defaultBearImageUrl =
      'assets/images/Icon_Alert_Bear.png'; // Default bear image
  String? _bearImageUrl;
  late List<String> phoneNumbers = [];
  late List<String> emailAddresses = [];
  late List<String> emergencyMessages= [];

  @override
  void initState() {
    twilioFlutter =
        TwilioFlutter(accountSid: 'AC3a55f7b6b5ef43b211aa09cc20793b81', authToken: 'a446618209562ab3d0b0a1bd3d9fb0f0', twilioNumber: '+16184278485');
    super.initState();
    _loadImageUrl();
    _startTimer();

  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //O(n)
  void _loadContactDetails() async {

      for (int i = 0; i < angels.length; i++) {
        phoneNumbers.add(angels[i].phoneNumber!);
        emailAddresses.add(angels[i].email!);
        emergencyMessages.add(angels[i].emergencyMessage!);
        twilioFlutter.sendSMS(toNumber: '+${angels[i].phoneNumber!}', messageBody: angels[i].emergencyMessage!);

    }

  }

  void sendSms() async {
    twilioFlutter.sendSMS(toNumber: '+917678330874', messageBody: 'testing server code sending');
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
                    //report page here
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_box_sharp),
                  title: Text('Angel List'),
                  onTap: () {
                    // TODO: Handle item 1 press
                    //angel list
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                angelList())
                    );

                  },

                ),
                ListTile(
                  leading: Icon(Icons.add_circle),
                  title: Text('Permissions'),
                  onTap: () async {

                    // TODO: Handle item 1 press
                    //angel list
                    await loadedPermissions();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                permissionPage())
                    );


                  },

                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log out'),
                  onTap: () {
                    //login page here
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
          child: Container(
            width: ScreenSize,
            height: ScreenHeight,
            color: (_panicModeOn) ?
            _backgroundColor: null,


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
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      Scanner())
                          );
                        },
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
                      onTap: () async {
                        if (_panicModeOn == false) {
                          print('activating panic mode');
                          setState(() {
                            _panicModeOn = true;
                          });
                          //start the timer for effects (make better color scheme)
                          _startTimer();
                          _loadContactDetails(); //message sent here


                          //location sharing
                          _getCurrentLocation().then((value)  {
                            setState(() {
                              lat = '${value.latitude}';
                              long = '${value.longitude}';
                            });
                            print('${lat} ${long}');
                            _liveLocation();
                            _openMap(lat!, long!);


                          });

                          //launch after 5 seconds
                          await Future.delayed(Duration(seconds: 5));
                          //open scanner
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      VideoCapture())
                          );










                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Are you sure you want to deactivate Panic Mode?',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      //turn off panic mode
                                      setState(() {
                                        _panicModeOn = false;
                                        _timer?.cancel();
                                        _timer = null;
                                      });





                                      // Perform an action when the button in the popup is clicked
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Deactivate',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Perform an action when the button in the popup is clicked
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );



                        }






                      },
                      child: ClipOval(
                        child: Image(
                          image: imageProvider,
                          width: ScreenSize*.9,
                          height: ScreenHeight * .5,
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
                              //chatlistpage here
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
                              //education page here
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
      ),
    );
  }
}