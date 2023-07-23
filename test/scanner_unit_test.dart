import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:camerascan/main.dart';

// Create a mock class for CameraController
class MockCameraController extends Mock implements CameraController {}

void main() {
  /*
  testWidgets('Scanner Page should initialize camera correctly', (WidgetTester tester) async {
    // Create a mock CameraController
    final mockCameraController = MockCameraController();

    // Stub the methods used in the initState to avoid exceptions
    when(mockCameraController.initialize()).thenAnswer((_) => Future<void>.value());

    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: Scanner()));

    // Access the _ScannerState by finding the Scanner widget
    final scannerState = tester.state<ScannerState>(find.byType(Scanner));

    // Ensure that the isCameraInitialized variable is initially set to false
    expect(scannerState.isCameraInitialized, false);

    // Call the initializeCamera function
    await scannerState.initializeCamera();

    // Expect that isCameraInitialized is set to true after calling initializeCamera
    expect(scannerState.isCameraInitialized, true);
  });
  */

}
