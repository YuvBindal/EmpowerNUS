/*
The unit tests here will aim to test the functionality of home page features.
This will be done by assessing the values of flag/tracking variables of the state of features.
Ex. If panic button is launched, _panicModeOn variable should have been set to True.
 */
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camerascan/homePage.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  testWidgets('HomePage should initialize without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Expect the app to load without errors.
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('Drawer shows correct items', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Open the drawer
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Verify the drawer items
    //expect(find.text('Deploy Report'), findsOneWidget); need to add these in
    expect(find.text('Angel List'), findsOneWidget);
    expect(find.text('Permissions'), findsOneWidget);
    //expect(find.text('Log out'), findsOneWidget); need to add these in
    //expect(find.text('Manage Account'), findsOneWidget);
  });


  testWidgets('Tapping on the circular image toggles panic mode', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    // Initially, panic mode should be off
    expect(find.text('Panic Mode: '), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);

    await fakeAsync((async) async {
      // Find the circular image and tap on it.
      final circularImage = find.byType(ClipOval);
      await tester.tap(circularImage);
      await tester.pump();

      // After tapping, panic mode should be on
      expect(find.text('Panic Mode: '), findsOneWidget);
      expect(find.text('On'), findsOneWidget);
    });
  });

}

