import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:flutter_driver/driver_extension.dart';


void main() {

  enableFlutterDriverExtension();

  group('Permission Integration Test', () {
    FlutterDriver? driver;

    setUpAll(() async {
      // Connect to the Flutter driver before running the tests.
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        // Close the connection to the driver after the tests have completed.
        driver?.close();
      }
    });

    test('Open System Settings', () async {
      // Find the IconButton with the custom AssetImage icon.
      final icon = find.byType('IconButton');

      // Wait for the IconButton to appear.
      await driver?.waitFor(icon);

      // Check if the IconButton has the desired ImageIcon.
      bool hasCustomIcon = false;
      final timeout = Duration(seconds: 5);
      final timeoutTimestamp = DateTime.now().add(timeout);
      while (DateTime.now().isBefore(timeoutTimestamp)) {
        final widget = await driver?.waitFor(icon, timeout: Duration(seconds: 1)) as StatefulElement;
        final iconWidget = widget.state.widget as IconButton;
        if (iconWidget.icon is ImageIcon) {
          final imageIcon = iconWidget.icon as ImageIcon;
          if (imageIcon.image == AssetImage('assets/images/Icon_TabBar.png')) {
            hasCustomIcon = true;
            break;
          }
        }
      }

      // Expect to find the IconButton with the custom AssetImage icon.
      expect(hasCustomIcon, isTrue);

      // Tap the IconButton to open the drawer.
      await driver?.tap(icon);

      // Wait for the drawer to open.
      await driver?.waitFor(find.text('Permissions'));

      // Tap the "Permissions" item to navigate to the permissionPage.
      await driver?.tap(find.text('Permissions'));

      // Wait for the permissionPage to load.
      await driver?.waitFor(find.text('Permissions Status'));

      // You can continue with the rest of your test as needed.

      // Find and tap the "Toggle App Permissions" button.
      final toggleButtonFinder = find.text('Toggle App Permissions');
      await driver?.tap(toggleButtonFinder);

      // Wait for the system settings screen to appear.
      await driver?.waitFor(find.text('System Settings'));

      // Check if the system settings screen is opened.
      final systemSettingsWidget = find.text('System Settings');
      expect(driver?.waitFor(systemSettingsWidget, timeout: Duration(seconds: 5)), isNotNull);
    });
  });
}
