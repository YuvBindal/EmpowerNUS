import 'package:flutter/material.dart';

class ReportFrame extends StatefulWidget {
  const ReportFrame({super.key});

  @override
  State<ReportFrame> createState() => _ReportFrameState();
}

class _ReportFrameState extends State<ReportFrame> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, screenWidth*.02, 0),
          child: Container(
            width: screenWidth *.3,
            height: screenHeight*.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * .02),
              color: Colors.black,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {

                  //open loaded police report
                  print('image being clicked');
                },
                child: Center(
                  child: Image(
                    image: AssetImage('assets/images/Icon_report.png'), //assetimage gets loaded
                    width: .2,
                    height: .1,

                  ),
                ),


              ),
            ),

          ),
        );
  }
}
