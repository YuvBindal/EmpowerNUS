import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;



class ReportFrame extends StatefulWidget {
  final Future<String> frameUrl;
  const ReportFrame({Key? key, required this.frameUrl}) : super(key: key);

  @override
  State<ReportFrame> createState() => _ReportFrameState();
}

class _ReportFrameState extends State<ReportFrame> {
  String pathPDF = "";


  Future<File> createFileFromPdfUrl(String url) async {
    final filename = 'flutterSlides.pdf';
    var request = await http.get(Uri.parse(url));
    var bytes = await request.bodyBytes;
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  void launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Could not launch $url');
    }
  }
  @override
  void initState()  {
    super.initState();
    _loadPdfFromUrl();
  }

  Future<void> _loadPdfFromUrl() async {
    try {
      File pdfFile = await createFileFromPdfUrl(await widget.frameUrl);
      setState(() {
        pathPDF = pdfFile.path;
      });
    } catch (e) {
      print('Error while loading PDF: $e');
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

                  if (pathPDF != "") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFViewerScreen(pdfUrl: pathPDF),
                        ),
                    );

                  }










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

  Future<void> _downloadPDF(BuildContext context) async {
    final String fileName = pdfUrl.split('/').last;

    try {
      final Directory? externalDirectory = await getExternalStorageDirectory();
      final String downloadDirectory = '${externalDirectory?.path}';
      final String pdfFilePath = '$downloadDirectory/$fileName';

      final File sourceFile = File(pdfUrl); // Use the downloaded file
      final File targetFile = File(pdfFilePath);

      await sourceFile.copy(targetFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Downloaded: $pdfFilePath')),
      );
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('PDF Viewer'),
            TextButton(
              onPressed: () {
                print(pdfUrl);
                //download function goes here
                _downloadPDF(context);
              },
              child: Text('Download PDF'),
            ),
          ],
        ),
      ),
      body: PDFView(
        filePath: pdfUrl,
      ),
    );
  }
}