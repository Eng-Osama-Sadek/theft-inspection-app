import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theft_inspection_v2/screens/add_case_screen.dart';
import 'package:theft_inspection_v2/screens/home_screen.dart';

void main() {
  testWidgets('adds an appliance using its name and wattage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AddCaseScreen()),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'اسم الحمل (مثال: سخان كهرباء)'),
      'سخان كهرباء',
    );
    await tester.enterText(find.widgetWithText(TextField, 'الوات'), '2000');
    await tester.tap(find.byTooltip('إضافة حمل'));
    await tester.pump();

    expect(find.text('سخان كهرباء'), findsOneWidget);
    expect(find.text('2000.0 وات'), findsOneWidget);
  });

  testWidgets('home screen fits a narrow display and opens date filtering', (
    WidgetTester tester,
  ) async {
    const pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      pathProviderChannel,
      (call) async => Directory.systemTemp.path,
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null),
    );
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('إضافة حالة سرقة جديدة'), findsOneWidget);
    expect(find.text('اضغط هنا للاطلاع ومعاينة المحاضر المسجلة'), findsNothing);
    expect(find.byIcon(Icons.star), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.textContaining('من:'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
