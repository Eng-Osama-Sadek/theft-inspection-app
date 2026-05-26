class InspectionModel {
  final String offenderName;
  final String activityType;
  final bool hasMeter;
  final String meterNumber;
  final String theftDescription;
  final double totalWatts;
  final double totalFine;
  final String idFrontPath;
  final String idBackPath;
  final String videoPath;
  final DateTime date;

  InspectionModel({
    required this.offenderName,
    required this.activityType,
    required this.hasMeter,
    required this.meterNumber,
    required this.theftDescription,
    required this.totalWatts,
    required this.totalFine,
    required this.idFrontPath,
    required this.idBackPath,
    required this.videoPath,
    required this.date,
  });

  // تحويل البيانات لخريطة لسهولة التعامل
  Map<String, dynamic> toMap() {
    return {
      'offenderName': offenderName,
      'activityType': activityType,
      'hasMeter': hasMeter ? 'نعم' : 'لا',
      'meterNumber': meterNumber.isEmpty ? 'لا يوجد' : meterNumber,
      'theftDescription': theftDescription,
      'totalWatts': totalWatts,
      'totalFine': totalFine,
      'idFrontPath': idFrontPath,
      'idBackPath': idBackPath,
      'videoPath': videoPath,
      'date': date.toString(),
    };
  }
}