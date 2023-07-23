/*
The unit tests here will aim to test the functionality of home page features.
This will be done by assessing the values of flag/tracking variables of the state of features.
Ex. If panic button is launched, _panicModeOn variable should have been set to True.
 */
import 'dart:async';

import 'package:camerascan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camerascan/homePage.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_async/fake_async.dart';
void main() {

}

/*
class MockTimer extends Fake implements Timer {}

void main() {
  //passes
  testWidgets('HomePage should initialize without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Expect the app to load without errors.
    expect(find.byType(HomePage), findsOneWidget);
  });


  //passes
  testWidgets('Drawer shows correct items', (WidgetTester tester) async {
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
    expect(find.text('Angel List'), findsOneWidget);
    expect(find.text('Permissions'), findsOneWidget);
    expect(find.text('Manage Account'), findsOneWidget);

    // Add more assertions for other drawer items.
  });

  testWidgets('Tapping on the circular image toggles panic mode', (WidgetTester tester) async {
    // Wrap the test code with fakeAsync
    await fakeAsync((fake) async {
      // Create a GlobalKey
      final homePageKey = GlobalKey<HomePageState>();

      await tester.pumpWidget(MaterialApp(home: HomePage(key: homePageKey)));

      // Get the HomePageState from the GlobalKey
      final homePageState = homePageKey.currentState;

      // Initially, panic mode should be off
      expect(homePageState!.panicModeOn, isFalse);

      // Find the circular image and tap on it to activate panic mode
      final circularImage = find.byType(ClipOval);
      await tester.tap(circularImage);
      await tester.pump();

      // Check the value of panicModeOn
      expect(homePageState!.panicModeOn, isTrue);

      // Find the circular image and tap on it again to deactivate panic mode
      await tester.tap(circularImage);
      await tester.pump();

      // Expect a dialog to appear
      final alertDialogFinder = find.byType(AlertDialog);
      expect(alertDialogFinder, findsOneWidget);

      // Tap the "Deactivate" text button in the dialog
      final deactivateButtonFinder = find.text('Deactivate');
      expect(deactivateButtonFinder, findsOneWidget);
      await tester.tap(deactivateButtonFinder);
      await tester.pump();

      // Panic mode should be off again
      expect(homePageState!.panicModeOn, isFalse);

      // Advance the timer by 1 second to trigger the periodic timer
      fake.elapse(const Duration(seconds: 1));
      await tester.pump();

      // Now the panic mode should be on again due to the periodic timer
      expect(homePageState!.panicModeOn, isTrue);
    });
  });







}
*/


