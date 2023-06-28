import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ChatMessage.dart';
import 'main.dart';
class angelForm extends StatefulWidget {
  const angelForm({super.key});

  @override
  State<angelForm> createState() => _angelFormState();
}

class _angelFormState extends State<angelForm> {
  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;
    late OpenAI? chatGPT;
    TextEditingController _controller = TextEditingController();

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
      _controller.dispose();
      super.dispose();
    }

    void generateMessage() async {
      _controller.clear();

      final request = CompleteText(
        model: kTextDavinci3,
        prompt:
        'Generate a short emergency message for the user to send a contact in case of emergencies or danger',
      );

      final response = await chatGPT?.onCompletion(request: request);
      _controller.text = response!.choices[0].text;
    }



    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: ScreenWidth * 1,
          height: ScreenHeight * .1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      letterSpacing: .8,
                  ),

                ),
              ),
              Text(
                'New Contact',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  letterSpacing: .8,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                    'Confirm',
                    style: GoogleFonts.montserrat(
                    letterSpacing: .8,
                    )
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
                  ),
                  ),
                  Container(
                    width: ScreenWidth,
                    height: ScreenHeight * .08,
                    child: TextField(
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
                    controller: _controller,
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
                      generateMessage();
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
                onPressed: () {},
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
