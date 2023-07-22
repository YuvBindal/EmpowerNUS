import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

bool showDelete = false;

class angelContact extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? city;
  final String? state;
  final String? country;

  angelContact({required this.firstName, required this.lastName, required this.city, required this.state, required this.country, Key? key})
      : super(key: key);

  @override
  State<angelContact> createState() => _angelContactState();
}

class _angelContactState extends State<angelContact> {
  late String? firstName;
  late String? lastName;
  late String? city;
  late String? state;
  late String? country;

  @override
  void initState() {
    super.initState();
    firstName = widget.firstName;
    lastName = widget.lastName;
    city = widget.city;
    state = widget.state;
    country = widget.country;
  }

  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, ScreenWidth * .02, 0, ScreenWidth * .02),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

              Container(
                width: ScreenWidth * .1,
                height: ScreenHeight * .1,
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Would you like to delete this contact?',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          content: Text(
                            'Your current contact: ${firstName} ${lastName}',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                //perform a searching algorithm : O(n)
                                String targetName = '${firstName} ${lastName}';
                                int index = angels.indexWhere((angel) => '${angel.firstName} ${angel.lastName}' == targetName);
                                if (index != -1) {
                                  setState(() {
                                    angels.removeAt(index); // Remove the element from the 'angels' list
                                    angelContacts.removeAt(index); // Remove the element from the 'angelContacts' list
                                  });
                                }



                                // Perform an action when the button in the popup is clicked
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Delete',
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
                  },
                  icon: Image(
                    image: AssetImage('assets/images/icon_checkbox.png'),
                    color: Colors.red,
                  ),
                ),
              ),


            //MAKE CHECKBOX APPEAR AND DISAPPEAR
            Center(
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
                          '${firstName} ${lastName}',
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
                              image: AssetImage('assets/images/icon_location.png'),
                            ),
                            Text(
                              '${city}/${state}/${country}',
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
                              borderRadius: BorderRadius.circular(ScreenWidth * .02),
                            ),
                            backgroundColor: Colors.red,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image(
                                width: ScreenWidth * .05,
                                height: ScreenHeight * .02,
                                image: AssetImage('assets/images/icon_fav.png'),
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
                              borderRadius: BorderRadius.circular(ScreenWidth * .02),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image(
                                width: ScreenWidth * .06,
                                height: ScreenHeight * .03,
                                image: AssetImage('assets/images/icon_contact.png'),
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
          ],
        ),
      ),
    );
  }
}
