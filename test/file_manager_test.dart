import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theft_inspection_v2/logic/calculator.dart';
import 'package:theft_inspection_v2/services/file_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saved cases can be loaded for search and date filtering', () async {
    final root = await Directory.systemTemp.createTemp('theft_cases_test_');
    const pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      pathProviderChannel,
      (call) async => root.path,
    );
    addTearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null);
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    final results = TheftCalculator.calculate(
      activityId: 1,
      loadWatts: 1500,
      hours: 8,
      days: 30,
      dispersionFactor: 1,
      slabPrice: 2.74,
    );
    final frontImage = File('${root.path}/front.jpg')
      ..writeAsBytesSync([1, 2, 3]);
    final backImage = File('${root.path}/back.jpg')
      ..writeAsBytesSync([4, 5, 6]);
    final video = File('${root.path}/video.mp4')..writeAsBytesSync([7, 8, 9]);
    await TheftFileManager.saveTheftCase(
      thiefName: 'اسم تجريبي',
      meterNumber: '123/45',
      address: 'عنوان تجريبي',
      results: results,
      appliances: [
        {'name': 'سخان', 'watts': 1500.0},
      ],
      idFrontImage: frontImage,
      idBackImage: backImage,
      videoFile: video,
    );

    final cases = await TheftFileManager.loadTheftCases();

    expect(cases, hasLength(1));
    expect(cases.single.name, 'اسم تجريبي');
    expect(cases.single.meterNumber, '123/45');
    expect(cases.single.totalRequired, results['totalRequired']);
    expect(
      await File('${cases.single.directoryPath}/report.xlsx').exists(),
      isTrue,
    );
    expect(
      await File('${cases.single.directoryPath}/id_front.jpg').readAsBytes(),
      [1, 2, 3],
    );
    expect(
      await File('${cases.single.directoryPath}/id_back.jpg').readAsBytes(),
      [4, 5, 6],
    );
    expect(
      await File('${cases.single.directoryPath}/theft_video.mp4').readAsBytes(),
      [7, 8, 9],
    );
  });

  test('metadata cases are listed even if a report file is missing', () async {
    final root = await Directory.systemTemp.createTemp('theft_cases_test_');
    const pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      pathProviderChannel,
      (call) async => root.path,
    );
    addTearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null);
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    final caseDirectory =
        Directory('${root.path}/Seraqat_Reports/incomplete_case');
    await caseDirectory.create(recursive: true);
    await File('${caseDirectory.path}/case.json').writeAsString(
      '{"name":"محضر تجريبي","meterNumber":"987","date":"2026-10-23T10:00:00.000","totalRequired":250}',
    );

    final cases = await TheftFileManager.loadTheftCases();

    expect(cases, hasLength(1));
    expect(cases.single.name, 'محضر تجريبي');
    expect(cases.single.totalRequired, 250);
  });
}
