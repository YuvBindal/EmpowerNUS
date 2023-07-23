import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
class ReportFrame extends StatefulWidget {
  final Future<String> frameUrl;
  const ReportFrame({Key? key, required this.frameUrl}) : super(key: key);

  @override
  State<ReportFrame> createState() => _ReportFrameState();
}

class _ReportFrameState extends State<ReportFrame> {
  void launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $url');
    }
  }

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
                onTap: () async {
                  String frameUrl = await widget.frameUrl;
                  final Uri _url = Uri.parse(frameUrl);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(pdfUrl: frameUrl),
                    ),
                  );



                  //open loaded police report
                  print('image being clicked');
                  print(frameUrl);
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

class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;

  const PDFViewerScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: pdfUrl,
      ),
    );
  }
}