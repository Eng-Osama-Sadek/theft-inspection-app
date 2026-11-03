class TheftCalculator {
  static const Map<int, Map<String, dynamic>> activityData = {
    1: {'name': 'سكنى', 'slab': 2.74, 'hours': 8},
    2: {'name': 'تجارى', 'slab': 2.79, 'hours': 12},
    3: {'name': 'خدمى', 'slab': 2.74, 'hours': 12},
    4: {'name': 'زراعى', 'slab': 2.65, 'hours': 12},
    5: {'name': 'تجارى_كودى', 'slab': 2.74, 'hours': 12},
    6: {'name': 'منزلى_كودى', 'slab': 2.74, 'hours': 8},
  };

  static const double consumptionStampRate = 0.03;
  static const double industrialStampRate = 0.0006;
  static const double radioFeeRate = 0.001;

  static Map<String, dynamic> calculate({
    required int activityId,
    required double loadWatts,
    required int hours,
    required int days,
    required double dispersionFactor,
    required double slabPrice,
    double? paidQuantity,
    bool isPreviousViolation = false,
  }) {
    double totalQuantity = (loadWatts * hours * days * dispersionFactor) / 1000;
    double netQuantity = totalQuantity - (paidQuantity ?? 0);

    double theftValue = netQuantity * slabPrice;
    double penalty = theftValue;
    double doublePenalty = isPreviousViolation ? penalty : 0;

    final consumptionStamp = [2, 3, 5].contains(activityId)
        ? totalQuantity * consumptionStampRate
        : 0.0;
    final industrialStamp =
        activityId == 3 ? totalQuantity * industrialStampRate : 0.0;
    final radioFee = [1, 6].contains(activityId)
        ? 0.5
        : [2, 3, 5].contains(activityId)
            ? totalQuantity * radioFeeRate
            : 0.0;
    final stampDuty = consumptionStamp + industrialStamp;
    final totalRequired =
        (theftValue + penalty + doublePenalty + stampDuty + radioFee)
            .ceilToDouble();

    return {
      'activityId': activityId,
      'loadWatts': loadWatts,
      'hours': hours,
      'days': days,
      'dispersionFactor': dispersionFactor,
      'slabPrice': slabPrice,
      'paidQuantity': paidQuantity ?? 0,
      'isPreviousViolation': isPreviousViolation,
      'totalQuantity': totalQuantity,
      'netQuantity': netQuantity,
      'theftValue': theftValue,
      'penalty': penalty,
      'doublePenalty': doublePenalty,
      'consumptionStamp': consumptionStamp,
      'industrialStamp': industrialStamp,
      'stampDuty': stampDuty,
      'radioFee': radioFee,
      'totalRequired': totalRequired,
    };
  }
}
