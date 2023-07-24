import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camerascan/education.dart';
import 'package:camerascan/homePage.dart';
import 'package:camerascan/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:camerascan/main.dart';
import 'package:mockito/mockito.dart';
import 'package:camerascan/permissons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camerascan/angelForm.dart';
// Create a mock class for CameraController
class MockCameraController extends Mock implements CameraController {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}



void main() {
  /*on better network connection
  setUpAll(() async {
    await Firebase.initializeApp(); // Initialize Firebase before running tests
  });

   */

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

  //Widget Integration Testing
  testWidgets('Test changing category to Assault and ER page quiz feature', (WidgetTester tester) async {
    // Create a GlobalKey for the education_Page widget.
    final GlobalKey<education_PageState> educationPageKey = GlobalKey();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: education_Page(key: educationPageKey), // Pass the GlobalKey to the widget.
    ));

    // Access the state of the education_Page widget using the GlobalKey.
    final educationPageState = educationPageKey.currentState;

    // Verify that the initial selected category is 'All'.
    expect(educationPageState!.selectedCategory, 'All');

    // Tap the dropdown button to select 'Abuse' category.
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle(); // Wait for the dropdown menu to appear.

    // Tap the 'Abuse' category option.
    await tester.tap(find.text('Assault'));
    await tester.pumpAndSettle(); // Wait for the list to update.

    // Verify that the selected category is now 'Assault'.
    expect(educationPageState.selectedCategory, 'Assault');

    //Navigating to the quiz page
    await tester.tap(find.byIcon(Icons.quiz_rounded));
    await tester.pumpAndSettle(); // Wait for the quiz page to load.

    // Verify that we are on the quiz page.
    expect(find.text('Assault'), findsOneWidget);
    await tester.pumpAndSettle();

    for (int i =1; i<=5;i++) {
      await tester.tap(find.byType(RadioListTile<String>).first);
      await tester.pumpAndSettle(); // Wait for the selection to take effect.
    }

    expect(find.text('Quiz Finished'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  //widget integration test for logout
  testWidgets('Testing Logout Functionality', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Wait for all animations and async operations to complete.
    await tester.pumpAndSettle();

    // Find the icon in the drawer and tap on it.
    final icon = find.byWidgetPredicate((widget) {
      // Check if the widget is an IconButton with a custom AssetImage icon.
      if (widget is IconButton && widget.icon is ImageIcon) {
        final imageIcon = widget.icon as ImageIcon;
        return imageIcon.image == AssetImage('assets/images/Icon_TabBar.png');
      }
      return false;
    });

    expect(icon, findsOneWidget);
    await tester.tap(icon);
    await tester.pumpAndSettle();

    // Add more test assertions for the expected behavior of the drawer.

    // For example, you can check if the drawer items are displayed correctly.
    await tester.tap(find.text('Log out'));

    /*on better network connection
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

     */

  });
  /*
  * The chain of tests below ensure the application pages initialise without errors.
  * */
  //widget integration test for scanner page

  testWidgets('Testing Scanner Page Navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Wait for all animations and async operations to complete.
    await tester.pumpAndSettle();

    // Find the icon in the drawer and tap on it.
    final icon = find.byWidgetPredicate((widget) {
      // Check if the widget is an IconButton with a custom AssetImage icon.
      if (widget is IconButton && widget.icon is ImageIcon) {
        final imageIcon = widget.icon as ImageIcon;
        return imageIcon.image == AssetImage('assets/images/Icon_Camera.png');
      }
      return false;
    });

    expect(icon, findsOneWidget);
    await tester.tap(icon);
    //navigates to scanner page

  });

  testWidgets('Testing Accounts Page Navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Wait for all animations and async operations to complete.
    await tester.pumpAndSettle();

    // Find the icon in the drawer and tap on it.
    final icon = find.byWidgetPredicate((widget) {
      // Check if the widget is an IconButton with a custom AssetImage icon.
      if (widget is IconButton && widget.icon is ImageIcon) {
        final imageIcon = widget.icon as ImageIcon;
        return imageIcon.image == AssetImage('assets/images/Icon_Avatar.png');
      }
      return false;
    });

    expect(icon, findsOneWidget);
    await tester.tap(icon);
    //if test case passes, page is loaded without errors

  });

  //widget integration testing for chatbot
  testWidgets('Testing Chatbot Page Navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Wait for all animations and async operations to complete.
    await tester.pumpAndSettle();

    // Find the icon in the drawer and tap on it.
    final icon = find.byWidgetPredicate((widget) {
      // Check if the widget is an IconButton with a custom AssetImage icon.
      if (widget is IconButton && widget.icon is ImageIcon) {
        final imageIcon = widget.icon as ImageIcon;
        return imageIcon.image == AssetImage('assets/images/Icon_Chat.png');
      }
      return false;
    });

    expect(icon, findsOneWidget);
    await tester.tap(icon);
    //if test case passes, page is loaded without errors

  });
  //widget integration testing for chatlistpage
  testWidgets('Testing Chatbot Page Navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Wait for all animations and async operations to complete.
    await tester.pumpAndSettle();

    // Find the icon in the drawer and tap on it.
    final icon = find.byWidgetPredicate((widget) {
      // Check if the widget is an IconButton with a custom AssetImage icon.
      if (widget is IconButton && widget.icon is ImageIcon) {
        final imageIcon = widget.icon as ImageIcon;
        return imageIcon.image == AssetImage('assets/images/Icon_Network.png');
      }
      return false;
    });

    expect(icon, findsOneWidget);
    await tester.tap(icon);
    //if test case passes, page is loaded without errors

  });

  //widget integration testing for education page
  testWidgets('Testing Chatbot Page Navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Wait for all animations and async operations to complete.
    await tester.pumpAndSettle();

    // Find the icon in the drawer and tap on it.
    final icon = find.byWidgetPredicate((widget) {
      // Check if the widget is an IconButton with a custom AssetImage icon.
      if (widget is IconButton && widget.icon is ImageIcon) {
        final imageIcon = widget.icon as ImageIcon;
        return imageIcon.image == AssetImage('assets/images/Icon_Read.png');
      }
      return false;
    });

    expect(icon, findsOneWidget);
    await tester.tap(icon);
    //if test case passes, page is loaded without errors

  });


  testWidgets('Clicking on "Add Contact" button and requesting an Angel Contact',
          (WidgetTester tester) async {
        // Create a mock navigator observer.
        final mockObserver = MockNavigatorObserver();

        // Create a GlobalKey for the angelList widget.
        final angelListKey = GlobalKey<angelListState>();

        // Build our app with the MaterialApp and the angelList widget.
        await tester.pumpWidget(
          MaterialApp(
            home: angelList(key: angelListKey),
            navigatorObservers: [mockObserver],
          ),
        );

        // Find the "Add Contact" button using the GlobalKey.
        final addButton = find.byKey(Key('addContactButton'));

        // Tap on the "Add Contact" button.
        await tester.tap(addButton);

        // Wait for the navigation to complete.
        await tester.pumpAndSettle();


      });


  /*
  tearDownAll(() async {
    await Firebase.app().delete();
  });

   */





}

Finder findText(String text) => find.text(text);

