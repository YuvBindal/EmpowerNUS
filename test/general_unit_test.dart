import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camerascan/homePage.dart';
import 'package:camerascan/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:camerascan/main.dart';
import 'package:mockito/mockito.dart';
import 'package:camerascan/permissons.dart';
import 'package:permission_handler/permission_handler.dart';

// Create a mock class for CameraController
class MockCameraController extends Mock implements CameraController {}



void main() {

  testWidgets('Test if clicking Deploy Report routes to Home Page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: ReportPage(), // Set the initial route to ReportPage.
      routes: {
        '/home': (context) => HomePage(), // Define the route for HomePage.
      },
    ));

    // Find the "Deploy Report" button using the ElevatedButton widget's text.
    final deployReportButton = find.text('Deploy Report');

    // Tap the "Deploy Report" button.
    await tester.tap(deployReportButton);

    // Wait for animations to complete.
    await tester.pumpAndSettle();

    // Check if the route is changed to the Home Page.
    expect(find.byType(HomePage), findsOneWidget);
  });


}
