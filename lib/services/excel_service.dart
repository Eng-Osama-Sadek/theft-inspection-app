import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelService {
  static Future<void> saveInspectionToExcelAndDevice(dynamic inspection) async {
    try {
      Directory? baseFolder;
      
      if (Platform.isAndroid) {
        baseFolder = Directory('/storage/emulated/0/Download/منظومة_فحص_السرقات');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        baseFolder = Directory('${directory.path}/منظومة_فحص_السرقات');
      }

      if (!await baseFolder.exists()) {
        await baseFolder.create(recursive: true);
      }

      // 🛑 تم إزالة أسطر النسخ القديمة المتكررة من هنا لمنع الازدواجية 🛑

      // إنشاء وتحديث شيت الإكسيل المركزي فقط
      final excelPath = '${baseFolder.path}/سجل_مخالفات_سرقات_2026.xlsx';
      final File excelFile = File(excelPath);
      
      Excel excel;
      if (await excelFile.exists()) {
        var bytes = await excelFile.readAsBytes();
        excel = Excel.decodeBytes(bytes);
      } else {
        excel = Excel.createExcel();
      }

      Sheet sheet = excel['سجل المخالفات'];
      
      if (sheet.maxRows == 0) {
        sheet.appendRow([
          TextCellValue('تاريخ الواقعة'),
          TextCellValue('اسم المخالف'),
          TextCellValue('نوع النشاط'),
          TextCellValue('عداد؟'),
          TextCellValue('رقم العداد'),
          TextCellValue('الوصف'),
          TextCellValue('الأحمال (وات)'),
          TextCellValue('الغرامة (ج.م)'),
        ]);
      }

      sheet.appendRow([
        TextCellValue(inspection.date.toString().split('.')[0]),
        TextCellValue(inspection.offenderName),
        TextCellValue(inspection.activityType),
        TextCellValue(inspection.hasMeter ? 'نعم' : 'لا'),
        TextCellValue(inspection.meterNumber.isEmpty ? 'بدون' : inspection.meterNumber),
        TextCellValue(inspection.theftDescription),
        DoubleCellValue(inspection.totalWatts),
        DoubleCellValue(inspection.totalFine),
      ]);

      var fileBytes = excel.save();
      if (fileBytes != null) {
        await excelFile.writeAsBytes(fileBytes);
      }
      
    } catch (e) {
      print("خطأ الحفظ الفعلي: $e");
      throw Exception('فشل في حفظ البيانات: $e');
    }
  }
}