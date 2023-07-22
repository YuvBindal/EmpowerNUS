import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'angelForm.dart';
import 'main.dart';
import 'accountPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';


bool locationSwitched = false;
bool cameraSwitched = false;
bool audioSwitched = false;
bool voiceSwitched = false;
Future<String> loadedPermissions() async {
  // Your function implementation
  locationSwitched = await Geolocator.isLocationServiceEnabled();



  if(await Permission.microphone.isGranted) {

    audioSwitched = true;
  }
  if(await Permission.camera.isGranted) {
    cameraSwitched = true;
  }

  return 'done';


}

class permissionPage extends StatefulWidget {
  const permissionPage({super.key});

  @override
  State<permissionPage> createState() => _permissionPageState();
}

class _permissionPageState extends State<permissionPage> {




  @override
  void initState() {
    super.initState();


  }


  @override
  Widget build(BuildContext context) {
    double ScreenSize = MediaQuery.of(context).size.width;
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
            child: Column(
              children: [
                SizedBox(height: ScreenHeight * .05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(ScreenSize* .02, 0, 0, 0),
                      child: Text(
                        'Permissions Status',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenSize * .07

                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: ScreenHeight * .03),

                Text(
                    'Please enable the following permissions for our app to function properly!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: ScreenSize * .05,
                    ),
                ),
                SizedBox(height: ScreenHeight * .1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Location',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenSize * .05,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if(await Permission.location.isDenied) {
                          Permission.location.request();

                        }
                        await loadedPermissions();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    permissionPage())
                        );




                      },
                      child: Container(
                        width: ScreenSize * .15,
                        height: ScreenHeight * .03,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: locationSwitched ? Colors.green : Colors.red,
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: Duration(milliseconds: 200),
                              alignment: locationSwitched ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                width: ScreenSize * .10,
                                height: ScreenHeight * .02,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  'We require your location to share with your angel list in case of emergencies.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: ScreenSize * .035,
                  ),
                ),
                SizedBox(height: ScreenHeight * .02),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      ' Camera',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenSize * .05,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if(await Permission.camera.isDenied) {
                          Permission.camera.request();


                        }
                        await loadedPermissions();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    permissionPage())
                        );




                      },
                      child: Container(
                        width: ScreenSize * .15,
                        height: ScreenHeight * .03,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: cameraSwitched ? Colors.green : Colors.red,
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: Duration(milliseconds: 200),
                              alignment: cameraSwitched ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                width: ScreenSize * .10,
                                height: ScreenHeight * .02,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  'We require your camera access to collect evidence in case of emergencies.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: ScreenSize * .035,
                  ),
                ),
                SizedBox(height: ScreenHeight * .02),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '   Audio',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenSize * .05,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if(await Permission.microphone.isDenied) {
                          Permission.microphone.request();



                        }

                        await loadedPermissions();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    permissionPage())
                        );



                      },
                      child: Container(
                        width: ScreenSize * .15,
                        height: ScreenHeight * .03,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: audioSwitched ? Colors.green : Colors.red,
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: Duration(milliseconds: 200),
                              alignment: audioSwitched ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                width: ScreenSize * .10,
                                height: ScreenHeight * .02,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  'We require your audio access to collect evidence in case of emergencies.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: ScreenSize * .035,
                  ),
                ),
                SizedBox(height: ScreenHeight * .05),



                TextButton(
                  onPressed:  () {
                    openAppSettings();
                  },
                  child: Text(
                    'Toggle App Permissions'
                  ),

                ),










              ],
            ),

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
                    iconSize: ScreenSize * .1,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {},
                    icon: ImageIcon(
                      AssetImage('assets/images/Icon_Network.png'),
                      color: null,
                    ),
                    iconSize: ScreenSize * .1,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {},
                    icon: ImageIcon(
                      AssetImage('assets/images/Icon_Home.png'),
                      color: null,
                    ),
                    iconSize: ScreenSize * .1,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {},
                    icon: ImageIcon(
                      AssetImage('assets/images/Icon_Read.png'),
                      color: null,
                    ),
                    iconSize: ScreenSize * .1,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {},
                    icon: ImageIcon(
                      AssetImage('assets/images/Icon_Map.png'),
                      color: null,
                    ),
                    iconSize: ScreenSize * .1,
                  ),
                ),
              ],
            ),
          ),
        ],

      ),
    );
  }
}
