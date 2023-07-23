import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ChatMessage.dart';
import 'main.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'angelContact.dart';


String message = '';
CollectionReference angelsCollection =
FirebaseFirestore.instance.collection('angels');

class VerifyIDForm extends StatefulWidget {
  angelDetails AngelDetails = angelDetails("", "", "", "", "", "", "", "", "", "");
  VerifyIDForm({required this.AngelDetails, Key? key}) : super(key: key);

  @override
  State<VerifyIDForm> createState() => _VerifyIDFormState();
}

class _VerifyIDFormState extends State<VerifyIDForm> {
  String? filePath;
  String? _imageUrl;
  late angelDetails AngelDetails;

  bool isFilePickerActive = false;

  late CameraController controller;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  bool _isFrontCamera = false;
  bool _picStorage = false;


  @override
  void initState() {
    super.initState();
    initializeCamera();
    AngelDetails = widget.AngelDetails;
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /* API ENDPOINT DATA RETRIEVAL*/
  void fetchMessage() async {
    final url = Uri.http('10.0.2.2:5000', '/images');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        message = jsonData['load_status'].toString();
      });
    //after verifications push angelDetails to angels list, store to firebase. reset angelDetails


    if (message == 'The faces are similar') {
        setState(() {
          angels.add(AngelDetails);
          angelContacts.add(angelContact(firstName: AngelDetails.firstName, lastName: AngelDetails.lastName, city: AngelDetails.city, state: AngelDetails.state, country: AngelDetails.country));
        });
        //push this to firebase
        Map<String, dynamic> angelData = {
          'firstName': AngelDetails.firstName,
          'lastName': AngelDetails.lastName,
          'userID': AngelDetails.userID,
          'phoneNumber': AngelDetails.phoneNumber,
          'email': AngelDetails.email,
          'street': AngelDetails.street,
          'city': AngelDetails.city,
          'state': AngelDetails.state,
          'country': AngelDetails.country,
          'emergencyMessage': AngelDetails.emergencyMessage,
        };
        await angelsCollection.add(angelData);

        //reroute back to the angel contact page
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  angelList()),
        );



        //increase angel Index after fetching data



    }




      print(message);
      print(message.runtimeType);
      print(jsonData);
      print(jsonData.runtimeType);

    } else {
      throw Exception('Failed to retrieve message from the API');
    }
  }




  void initializeCamera() async {
    final cameras = await availableCameras();
    final camera = _isFrontCamera ? cameras.last : cameras.first;
    controller = CameraController(
      camera,
      ResolutionPreset.high,
    );

    controller.addListener(() {
      if (controller.value.isInitialized) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    });

    try {
      await controller.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }
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

    await Future.delayed(Duration(milliseconds: 500)); //add a little effect

    try {
      final XFile picture = await controller.takePicture();
      print('Picture saved at: ${picture.path}');
      uploadFaceImagetoFirebase(
          picture.path); // Call the method to upload the image
    } catch (e) {
      print('Error taking picture: $e');
    } finally {
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<void> uploadFaceImagetoFirebase(String imagePath) async {
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

      final url = Uri.http('10.0.2.2:5000', '/images');
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'Face_Link': downloadURL}));
      print('Response status: ${response.statusCode}');



      print('Image uploaded. Download URL: $downloadURL');
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }

  Future<void> uploadImageToFirebase(String imagePath) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final destination = 'images/$fileName.png';

      final firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref(destination);
      final firebase_storage.UploadTask uploadTask = ref.putFile(File(imagePath));

      final firebase_storage.TaskSnapshot taskSnapshot =
      await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('verifyID', downloadURL);
      String? imageUrl = prefs.getString('verifyID');
      if (imageUrl != null) {
        setState(() {
          _imageUrl = imageUrl;
        });
      }
      //setting up image url to api
      final url = Uri.http('10.0.2.2:5000', '/images');
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'ID_Link': _imageUrl}));
      print('Response status: ${response.statusCode}');





      print('Image uploaded. Download URL: $downloadURL');
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }

  Future<String?> selectFile() async {
    if (isFilePickerActive) {
      // File picker is already active, so return null or handle it as needed
      return null;
    }

    isFilePickerActive = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        filePath = result.files.single.path;
        if (filePath != null && filePath!.isNotEmpty) {
          uploadImageToFirebase(filePath!);
          return filePath;
        }
      }
      // User canceled the file picker or no valid file path found
      return null;
    } finally {
      isFilePickerActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    ImageProvider imageProvider;
    if (_imageUrl != null) {
      imageProvider = NetworkImage(_imageUrl!);
    } else {
      imageProvider = AssetImage('');
    }

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: screenWidth * 1,
          height: screenHeight * .1,
          child: Center(
            child: Text(
              'Verify ID',
              style: GoogleFonts.montserrat(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                letterSpacing: .8,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: screenHeight * .05),
            Center(
              child: Container(
                width: screenWidth * .9,
                height: screenHeight * .35,
                decoration: BoxDecoration(
                  image: _imageUrl != null
                      ? DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // ID Loading Code
                selectFile();
              },
              child: Text('Upload ID'),
            ),
            if (_imageUrl != null)

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Please remember to remove accessories such as hats, glasses, etc',
                         style: GoogleFonts.montserrat(),
                      ),
                    ),
                    SizedBox(height: screenHeight * .05),
                    Container(
                      // camera goes here
                      width: screenWidth * .7,
                      height: screenHeight * .4,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.red, width: _isTakingPicture ? 5.0 : 0.0),
                      ),
                      child: _isCameraInitialized
                          ? AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: CameraPreview(controller),
                      )
                          : Center(child: CircularProgressIndicator()),
                    ),
                    TextButton(
                      onPressed:  () async {
                        takePicture();
                        await Future.delayed(Duration(milliseconds: 8000)); //wait for 10 seconds (temporary fix should add a real time communicatoon mehtod)
                        fetchMessage();




                      },
                      child: Text(
                        'Scan Face',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: screenWidth * .03,
                        ),
                      ),
                    ),

                    /*
                    *
                    *
                    *
                    *  if (message == 'The faces are similar')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0, 0, screenWidth * .02, 0),
                            child: Icon(
                              Icons.check,
                              color: Colors.green,
                              size: screenWidth * .05,
                            ),
                          ),
                          Text(
                            'Verified, redirecting...',
                            style: GoogleFonts.montserrat(
                              fontSize: screenWidth * .05,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: screenHeight * .1),

                        ],

                      ),
                      * */



                  ],
                ),





          ],
        ),
      ),
      persistentFooterButtons: [
        Container(
          height: screenHeight * .07,
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
                  iconSize: screenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Network.png'),
                    color: null,
                  ),
                  iconSize: screenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Home.png'),
                    color: null,
                  ),
                  iconSize: screenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Read.png'),
                    color: null,
                  ),
                  iconSize: screenWidth * .1,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {},
                  icon: ImageIcon(
                    AssetImage('assets/images/Icon_Map.png'),
                    color: null,
                  ),
                  iconSize: screenWidth * .1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
int angelIndex = 0;
class angelDetails {
  String? firstName;
  String? lastName;
  String? userID;
  String? phoneNumber;
  String? email;
  String? street;
  String? city;
  String? state;
  String? country;
  String? emergencyMessage;
  angelDetails(this.firstName, this.lastName,
      this.userID,this.phoneNumber,this.email,this.street,
      this.city, this.state,this.country, this.emergencyMessage);
}


class angelForm extends StatefulWidget {
  const angelForm({super.key});

  @override
  State<angelForm> createState() => _angelFormState();
}

class _angelFormState extends State<angelForm> {
  late OpenAI? chatGPT;
  TextEditingController _controller = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _userID = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _street = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _state = TextEditingController();
  TextEditingController _country = TextEditingController();

  angelDetails AngelDetails = angelDetails('', '', '', '', '', '', '', '', '', '');

  //for testing purposes
  void printAngel() {
    print(AngelDetails.firstName);
    print(AngelDetails.lastName);
    print(AngelDetails.userID);
    print(AngelDetails.phoneNumber);
    print(AngelDetails.email);
    print(AngelDetails.street);
    print(AngelDetails.city);
    print(AngelDetails.state);
    print(AngelDetails.country);
    print(AngelDetails.emergencyMessage);
  }

  @override
  void initState() {
    chatGPT = OpenAI.instance.build(
        token: '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',
        baseOption: HttpSetup(receiveTimeout: Duration(seconds: 60000)));
    _firstName.text = AngelDetails.firstName ?? '';
    _lastName.text = AngelDetails.lastName ?? '';
    _userID.text = AngelDetails.userID ?? '';
    _phone.text = AngelDetails.phoneNumber ?? '';
    _email.text = AngelDetails.email ?? '';
    _street.text = AngelDetails.street ?? '';
    _city.text = AngelDetails.city ?? '';
    _state.text = AngelDetails.state ?? '';
    _country.text = AngelDetails.country ?? '';
    _controller.text = AngelDetails.emergencyMessage ?? '';
    super.initState();

  }
  //prevent memory leaks
  @override
  void dispose() {
    chatGPT?.close();
    _controller.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _userID.dispose();
    _phone.dispose();
    _email.dispose();
    _street.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();

    super.dispose();
  }

  void generateMessage() async {
    final request = CompleteText(
      model: kTextDavinci3,
      prompt:
      'Generate a short emergency message for the user to send a contact in case of emergencies or danger',
    );

    final response = await chatGPT?.onCompletion(request: request);
    setState(() {
      _controller.text += response?.choices[0].text ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;



    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: ScreenWidth * 1,
          height: ScreenHeight * .1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(
                  'New Contact',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    letterSpacing: .8,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget> [

            Container(
              width: ScreenWidth,
              height: ScreenHeight * .2,
              child: Transform.scale(
                scale: 1.5,
                child: Image(
                  image: AssetImage('assets/images/Icon_Avatar.png'),
                ) ,
              ),
            ),
            Container(
              width: ScreenWidth * .5,
              height: ScreenHeight * .05,
              child: TextButton(
                onPressed: () {},
                child: Text(
                    'Add Photo',
                    style: GoogleFonts.montserrat(
                      letterSpacing: .8,
                      color: Colors.blue,
                    ),
                ),
              ),
            ),
            Container(
              width: ScreenWidth,
              height: ScreenHeight * .24,
              child: Column(
                children: <Widget>[
                  Container(
                    width: ScreenWidth,
                    height: ScreenHeight * .08,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'First name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ScreenWidth * .01),
                        ),
                    ),
                      controller: _firstName,
                  ),
                  ),
                  Container(
                    width: ScreenWidth,
                    height: ScreenHeight * .08,
                    child: TextField(
                      controller: _lastName,
                      decoration: InputDecoration(
                        hintText: 'Last name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ScreenWidth * .01),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: ScreenWidth,
                    height: ScreenHeight * .08,
                    child: TextField(
                      controller: _userID,

                      decoration: InputDecoration(
                        hintText: 'EmpowerNUS #userID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ScreenWidth * .01),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenHeight * .05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: EdgeInsets.all(ScreenWidth*.01),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: ScreenWidth * .8,
                  height: ScreenHeight * .08,
                  child: TextField(
                    controller: _phone,
                    decoration: InputDecoration(
                      hintText: 'Add Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenHeight * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: EdgeInsets.all(ScreenWidth*.01),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: ScreenWidth * .8,
                  height: ScreenHeight * .08,
                  child: TextField(
                    controller: _email,

                    decoration: InputDecoration(
                      hintText: 'Add Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenHeight * .02),
            Text(
                'Add Location',
              style: GoogleFonts.montserrat(
                fontSize: ScreenWidth * .05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height:ScreenHeight * .01),

            Container(
              width: ScreenWidth * .8,
              child: TextField(
                controller: _street,
                decoration: InputDecoration(
                  hintText: 'Add Street/Flat No.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ScreenWidth * .01),
                  ),
                ),
              ),
            ),
            SizedBox(height:ScreenHeight * .01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: ScreenWidth * .3,
                  child: TextField(
                    controller: _city,
                    decoration: InputDecoration(
                      hintText: 'Add City',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: ScreenWidth * .3,
                  child: TextField(
                    controller: _state,
                    decoration: InputDecoration(
                      hintText: 'Add State',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: ScreenWidth * .3,
                  child: TextField(
                    controller: _country,
                    decoration: InputDecoration(
                      hintText: 'Add Country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenHeight * .02),
            Text(
              'Add Emergency Message',
              style: GoogleFonts.montserrat(
                fontSize: ScreenWidth * .05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height:ScreenHeight * .01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: ScreenWidth * .8,
                  child: TextField(
                    
                    style: TextStyle(color: Colors.black),
                    controller: _controller, // Add this line to connect the controller
                    decoration: InputDecoration(
                      hintText: 'Help, I am in danger!',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ScreenWidth * .01),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: ScreenWidth *.1,
                  child: IconButton(
                    onPressed: () {
                      printAngel();
                    },
                    icon: Image(
                      image: AssetImage('assets/images/icon_reload.png'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenHeight * .02),
            Container(
              decoration: BoxDecoration(
                color: Colors.green[300],

                borderRadius: BorderRadius.circular(ScreenWidth * .02),
              ),
              child: TextButton(
                onPressed: () {
                  AngelDetails.firstName = _firstName.text;
                  AngelDetails.lastName = _lastName.text;
                  AngelDetails.userID = _userID.text;
                  AngelDetails.phoneNumber = _phone.text;
                  AngelDetails.email = _email.text;
                  AngelDetails.street = _street.text;
                  AngelDetails.city = _city.text;
                  AngelDetails.state = _state.text;
                  AngelDetails.country = _country.text;
                  AngelDetails.emergencyMessage = _controller.text;
                  printAngel();
                  //after verifications push angelDetails to angels list, store to firebase. reset angelDetails
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (BuildContext context) =>
                      VerifyIDForm(AngelDetails: AngelDetails)),
                  );
                },
                child: Text(
                    'Verify Contact ID',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      letterSpacing: .8,
                    )
                ),
              ),
            ),
            SizedBox(height: ScreenHeight * .02),

          ],

        ),
      ),

      //.93
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

