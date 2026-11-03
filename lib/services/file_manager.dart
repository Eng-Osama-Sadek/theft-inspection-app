import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import '../logic/calculator.dart';

class TheftCaseRecord {
  const TheftCaseRecord({
    required this.name,
    required this.meterNumber,
    required this.date,
    required this.directoryPath,
    this.totalRequired,
  });

  final String name;
  final String meterNumber;
  final DateTime date;
  final String directoryPath;
  final double? totalRequired;
}

class TheftFileManager {
  static const _reportsDirectoryName = 'Seraqat_Reports';
  static const _downloadsChannel =
      MethodChannel('com.example.theft_inspection_v2/downloads');

  static Future<Directory> _reportsDirectory() async {
    final baseDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if (baseDir == null) {
      throw FileSystemException('تعذر الوصول إلى مجلد التخزين');
    }
    return Directory('${baseDir.path}/$_reportsDirectoryName');
  }

  static Future<List<TheftCaseRecord>> loadTheftCases() async {
    if (kIsWeb) {
      return [];
    }
    final reportsDir = await _reportsDirectory();
    if (!await reportsDir.exists()) {
      return [];
    }

    final cases = <TheftCaseRecord>[];
    await for (final entity in reportsDir.list()) {
      if (entity is! Directory) {
        continue;
      }
      if (await File('${entity.path}/case.pending').exists()) {
        continue;
      }

      final metadataFile = File('${entity.path}/case.json');
      if (await metadataFile.exists()) {
        final metadata = jsonDecode(await metadataFile.readAsString())
            as Map<String, dynamic>;
        final date = DateTime.tryParse(metadata['date'] as String? ?? '');
        if (date == null) {
          throw FormatException('تاريخ محضر غير صالح: ${metadataFile.path}');
        }
        cases.add(
          TheftCaseRecord(
            name: metadata['name'] as String? ?? '',
            meterNumber: metadata['meterNumber'] as String? ?? '',
            date: date,
            directoryPath: metadata['outputLocation'] as String? ?? entity.path,
            totalRequired: (metadata['totalRequired'] as num?)?.toDouble(),
          ),
        );
        continue;
      }

      final reportFile = File('${entity.path}/report.xlsx');
      if (!await reportFile.exists()) {
        continue;
      }

      final legacyMatch = RegExp(r'^(.*)_([^_]+)_(\d{13})$')
          .firstMatch(entity.uri.pathSegments.last);
      final date = legacyMatch == null
          ? await entity.stat().then((stat) => stat.modified)
          : DateTime.fromMillisecondsSinceEpoch(
              int.parse(legacyMatch.group(3)!),
            );
      cases.add(
        TheftCaseRecord(
          name: legacyMatch?.group(1) ?? entity.uri.pathSegments.last,
          meterNumber: legacyMatch?.group(2) ?? '',
          date: date,
          directoryPath: entity.path,
        ),
      );
    }

    cases.sort((a, b) => b.date.compareTo(a.date));
    return cases;
  }

  static Future<String> saveTheftCase({
    required String thiefName,
    required String meterNumber,
    required String address,
    required Map<String, dynamic> results,
    required List<Map<String, dynamic>> appliances,
    File? idFrontImage,
    File? idBackImage,
    File? videoFile,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'حفظ الملفات والتقارير غير مدعوم على نسخة المتصفح. استخدم تطبيق Android.',
      );
    }
    String safeName =
        thiefName.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '').trim();
    if (safeName.isEmpty) safeName = "سارق_مجهول";
    final safeMeterNumber =
        meterNumber.replaceAll(RegExp(r'[^\w\u0600-\u06FF-]'), '_');
    final savedAt = DateTime.now();
    final folderName =
        "${safeName}_${safeMeterNumber}_${savedAt.millisecondsSinceEpoch}";
    final reportsDir = await _reportsDirectory();
    final caseDir = Directory("${reportsDir.path}/$folderName");
    await caseDir.create(recursive: true);
    final pendingMarker = File('${caseDir.path}/case.pending');
    await pendingMarker.create();

    final mediaFiles = <Map<String, String>>[];
    if (idFrontImage != null) {
      final destination = await idFrontImage.copy(
        "${caseDir.path}/id_front.jpg",
      );
      mediaFiles.add({
        'name': 'id_front.jpg',
        'mimeType': 'image/jpeg',
        'path': destination.path,
      });
    }
    if (idBackImage != null) {
      final destination = await idBackImage.copy("${caseDir.path}/id_back.jpg");
      mediaFiles.add({
        'name': 'id_back.jpg',
        'mimeType': 'image/jpeg',
        'path': destination.path,
      });
    }
    if (videoFile != null) {
      final destination =
          await videoFile.copy("${caseDir.path}/theft_video.mp4");
      mediaFiles.add({
        'name': 'theft_video.mp4',
        'mimeType': 'video/mp4',
        'path': destination.path,
      });
    }

    final excel = Excel.createExcel();
    final sheet = excel['تقرير سرقة'];
    sheet.cell(CellIndex.indexByString("A1")).value =
        TextCellValue("منظومة فحص سرقات التيار الكهربائي");
    sheet.cell(CellIndex.indexByString("A3")).value = TextCellValue("الاسم:");
    sheet.cell(CellIndex.indexByString("B3")).value = TextCellValue(thiefName);
    sheet.cell(CellIndex.indexByString("A4")).value =
        TextCellValue("رقم العداد:");
    sheet.cell(CellIndex.indexByString("B4")).value =
        TextCellValue(meterNumber);
    sheet.cell(CellIndex.indexByString("A5")).value = TextCellValue("العنوان:");
    sheet.cell(CellIndex.indexByString("B5")).value = TextCellValue(address);
    sheet.cell(CellIndex.indexByString("A7")).value = TextCellValue("الأحمال");
    sheet.cell(CellIndex.indexByString("B7")).value =
        TextCellValue("القدرة (وات)");
    for (var i = 0; i < appliances.length; i++) {
      final row = i + 8;
      sheet.cell(CellIndex.indexByString("A$row")).value =
          TextCellValue(appliances[i]['name'] as String);
      sheet.cell(CellIndex.indexByString("B$row")).value =
          DoubleCellValue(appliances[i]['watts'] as double);
    }

    final summaryStartRow = appliances.length + 9;
    final summary = <String, Object>{
      "النشاط": TheftCalculator.activityData[results['activityId']]!['name']
          as String,
      "إجمالي الأحمال (وات)": results['loadWatts'] as double,
      "ساعات التشغيل": results['hours'] as int,
      "المدة (يوم)": results['days'] as int,
      "معامل التشتت": results['dispersionFactor'] as double,
      "سعر الكيلو وات ساعة": results['slabPrice'] as double,
      "الكمية المسددة المخصومة": results['paidQuantity'] as double,
      "كمية التيار": results['totalQuantity'] as double,
      "صافي الكمية المسروقة": results['netQuantity'] as double,
      "قيمة التيار": results['theftValue'] as double,
      "الغرامة": results['penalty'] as double,
      "غرامة التكرار": results['doublePenalty'] as double,
      "دمغة الاستهلاك": results['consumptionStamp'] as double,
      "دمغة الصناعي": results['industrialStamp'] as double,
      "الإذاعة": results['radioFee'] as double,
      "الإجمالي المطلوب": results['totalRequired'] as double,
    };
    var row = summaryStartRow;
    for (final entry in summary.entries) {
      sheet.cell(CellIndex.indexByString("A$row")).value =
          TextCellValue(entry.key);
      final value = entry.value;
      sheet.cell(CellIndex.indexByString("B$row")).value = value is String
          ? TextCellValue(value)
          : value is int
              ? IntCellValue(value)
              : DoubleCellValue(value as double);
      row++;
    }

    final fileBytes = excel.save();
    if (fileBytes == null) {
      throw StateError('تعذر إنشاء ملف تقرير Excel');
    }
    final reportFile = File("${caseDir.path}/report.xlsx");
    await reportFile.writeAsBytes(fileBytes);

    String outputLocation = caseDir.path;
    if (Platform.isAndroid) {
      var treeUri = await _downloadsChannel.invokeMethod<String>(
        'getDownloadsFolder',
      );
      treeUri ??= await _downloadsChannel.invokeMethod<String>(
        'selectDownloadsFolder',
      );
      if (treeUri == null) {
        throw FileSystemException(
          'لم يتم اختيار مجلد Download؛ لم يكتمل تصدير المحضر.',
        );
      }

      mediaFiles.add({
        'name': 'report.xlsx',
        'mimeType':
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'path': reportFile.path,
      });
      outputLocation = await _downloadsChannel.invokeMethod<String>(
            'writeCaseFiles',
            {
              'treeUri': treeUri,
              'folderName': folderName,
              'files': mediaFiles,
            },
          ) ??
          (throw StateError('لم يتم إرجاع موقع حفظ المحضر'));
    }

    await File("${caseDir.path}/case.json").writeAsString(
      jsonEncode({
        'name': thiefName,
        'meterNumber': meterNumber,
        'date': savedAt.toIso8601String(),
        'totalRequired': results['totalRequired'] as double,
        'outputLocation': outputLocation,
      }),
    );
    await pendingMarker.delete();
    return "تم الحفظ في: $outputLocation";
  }
}
