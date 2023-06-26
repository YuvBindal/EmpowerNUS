
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plzwork/chatbot.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:async';
import 'chatMessage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'main.dart';

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
                          onPressed: () {},
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
                                    '/assets/images/icon_contact.png'),
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
                          onPressed: () {},
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //angel list contacts go in here
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, ScreenWidth*.02, 0, ScreenWidth*.02),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0.05 * ScreenWidth),
                                  color: Colors.amber,
                                ),
                                width: ScreenWidth * 0.9,
                                height: ScreenHeight * 0.25,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    //load contact image here
                                    Image(
                                      image: AssetImage('assets/images/Icon_Avatar.png'),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: ScreenHeight * .02),
                                        Text(
                                          'Contact Name',
                                          style: GoogleFonts.montserrat(
                                            fontSize: ScreenWidth * .06,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Image(
                                              width: ScreenWidth * .07,
                                              height: ScreenHeight * .05,
                                              color: null,
                                              image: AssetImage(
                                                  'assets/images/icon_location.png'),
                                            ),
                                            Text(
                                              'City, State, Country',
                                              style: GoogleFonts.montserrat(
                                                fontSize: ScreenWidth * .035,
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(ScreenWidth * .02),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Image(
                                                width: ScreenWidth * .05,
                                                height: ScreenHeight * .02,
                                                image: AssetImage(
                                                    'assets/images/icon_fav.png'),
                                              ),
                                              Text(
                                                'Favourite',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: ScreenWidth * .035,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(ScreenWidth * .02),
                                            ),
                                            backgroundColor: Colors.blueAccent,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Image(
                                                width: ScreenWidth * .06,
                                                height: ScreenHeight * .03,
                                                image: AssetImage(
                                                    'assets/images/icon_contact.png'),
                                              ),
                                              Text(
                                                'Update Info',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: ScreenWidth * .035,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Add more items as needed

                        ],
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
                  onPressed: () {
                    Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ChatBot()),
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
                                      HomePage()),
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
