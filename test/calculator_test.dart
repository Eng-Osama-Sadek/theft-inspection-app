import 'package:flutter_test/flutter_test.dart';
import 'package:theft_inspection_v2/logic/calculator.dart';

void main() {
  group('TheftCalculator workbook formulas', () {
    test('calculates first residential violation with fixed radio fee', () {
      final result = TheftCalculator.calculate(
        activityId: 1,
        loadWatts: 1000,
        hours: 8,
        days: 1,
        dispersionFactor: 1,
        slabPrice: 2.74,
      );

      expect(result['totalQuantity'], 8);
      expect(result['netQuantity'], 8);
      expect(result['theftValue'], closeTo(21.92, 0.0001));
      expect(result['consumptionStamp'], 0);
      expect(result['industrialStamp'], 0);
      expect(result['radioFee'], 0.5);
      expect(result['totalRequired'], 45);
    });

    test('subtracts paid quantity and applies commercial workbook fees', () {
      final result = TheftCalculator.calculate(
        activityId: 2,
        loadWatts: 1000,
        hours: 12,
        days: 10,
        dispersionFactor: 1,
        slabPrice: 2.79,
        paidQuantity: 20,
      );

      expect(result['totalQuantity'], 120);
      expect(result['netQuantity'], 100);
      expect(result['theftValue'], 279);
      expect(result['consumptionStamp'], closeTo(3.6, 0.0001));
      expect(result['industrialStamp'], 0);
      expect(result['radioFee'], closeTo(0.12, 0.0001));
      expect(result['totalRequired'], 562);
    });

    test('applies industrial stamp and repeat-violation fine', () {
      final result = TheftCalculator.calculate(
        activityId: 3,
        loadWatts: 1000,
        hours: 12,
        days: 1,
        dispersionFactor: 1,
        slabPrice: 2.74,
        isPreviousViolation: true,
      );

      expect(result['theftValue'], closeTo(32.88, 0.0001));
      expect(result['doublePenalty'], closeTo(32.88, 0.0001));
      expect(result['consumptionStamp'], closeTo(0.36, 0.0001));
      expect(result['industrialStamp'], closeTo(0.0072, 0.0001));
      expect(result['radioFee'], closeTo(0.012, 0.0001));
      expect(result['totalRequired'], 100);
    });

    test('agricultural activity has no workbook fees', () {
      final result = TheftCalculator.calculate(
        activityId: 4,
        loadWatts: 1000,
        hours: 12,
        days: 1,
        dispersionFactor: 1,
        slabPrice: 2.65,
      );

      expect(result['stampDuty'], 0);
      expect(result['radioFee'], 0);
      expect(result['totalRequired'], 64);
    });
  });
}
