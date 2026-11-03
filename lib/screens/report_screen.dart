import 'package:flutter/material.dart';
import '../logic/calculator.dart';
import '../services/file_manager.dart';

class ReportScreen extends StatefulWidget {
  final String name, meter, address;
  final int activityId;
  final double totalWatts;
  final Map<String, dynamic> images;
  final bool isPreviousViolation;
  final List<Map<String, dynamic>> appliances;

  const ReportScreen({
    super.key,
    required this.name,
    required this.meter,
    required this.address,
    required this.activityId,
    required this.totalWatts,
    required this.images,
    required this.isPreviousViolation,
    required this.appliances,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final TextEditingController _slabController;
  final _dispersionController = TextEditingController(text: "1");
  final _daysController = TextEditingController(text: "360");
  final _paidQuantityController = TextEditingController(text: "0");
  Map<String, dynamic>? _results;

  @override
  void initState() {
    super.initState();
    _slabController = TextEditingController(
      text: TheftCalculator.activityData[widget.activityId]!['slab'].toString(),
    );
    _calculate();
  }

  @override
  void dispose() {
    _slabController.dispose();
    _dispersionController.dispose();
    _daysController.dispose();
    _paidQuantityController.dispose();
    super.dispose();
  }

  void _calculate() {
    final days = int.tryParse(_daysController.text);
    final dispersionFactor = double.tryParse(_dispersionController.text);
    final slabPrice = double.tryParse(_slabController.text);
    final paidQuantity = double.tryParse(_paidQuantityController.text);
    if (days == null ||
        days < 0 ||
        dispersionFactor == null ||
        dispersionFactor < 0 ||
        slabPrice == null ||
        slabPrice < 0 ||
        paidQuantity == null ||
        paidQuantity < 0) {
      setState(() => _results = null);
      return;
    }

    final results = TheftCalculator.calculate(
      activityId: widget.activityId,
      loadWatts: widget.totalWatts,
      hours: TheftCalculator.activityData[widget.activityId]!['hours'] as int,
      days: days,
      dispersionFactor: dispersionFactor,
      slabPrice: slabPrice,
      paidQuantity: paidQuantity,
      isPreviousViolation: widget.isPreviousViolation,
    );
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
          title: const Text("الحساب النهائي"),
          backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputRow("معامل التشتت", _dispersionController),
            _buildInputRow("سعر الكيلو وات ساعة", _slabController),
            _buildInputRow("المدة بالأيام", _daysController),
            _buildInputRow("كمية مسددة تخصم (ك.و.س)", _paidQuantityController),
            const Divider(color: Colors.white54, height: 40),
            if (_results == null)
              const Text(
                "أدخل قيمًا رقمية صحيحة وغير سالبة لإظهار الحساب",
                style: TextStyle(color: Colors.orangeAccent),
              )
            else ...[
              ...widget.appliances.map(
                (appliance) => _buildResultRow(
                  appliance['name'] as String,
                  "${appliance['watts']} وات",
                ),
              ),
              _buildResultRow("إجمالي الأحمال", "${widget.totalWatts} وات"),
              _buildResultRow(
                "كمية التيار",
                "${_results!['totalQuantity'].toStringAsFixed(2)} ك.و.س",
              ),
              _buildResultRow(
                "صافي الكمية بعد خصم المسدد",
                "${_results!['netQuantity'].toStringAsFixed(2)} ك.و.س",
              ),
              _buildResultRow(
                "قيمة التيار للأحمال",
                "${_results!['theftValue'].toStringAsFixed(2)} ج.م",
              ),
              _buildResultRow(
                "الغرامة",
                "${_results!['penalty'].toStringAsFixed(2)} ج.م",
              ),
              if (widget.isPreviousViolation)
                _buildResultRow(
                  "غرامة تكرار المخالفة",
                  "${_results!['doublePenalty'].toStringAsFixed(2)} ج.م",
                  color: Colors.redAccent,
                ),
              _buildResultRow(
                "دمغة الاستهلاك",
                "${_results!['consumptionStamp'].toStringAsFixed(2)} ج.م",
              ),
              _buildResultRow(
                "دمغة الصناعي",
                "${_results!['industrialStamp'].toStringAsFixed(2)} ج.م",
              ),
              _buildResultRow(
                "الإذاعة",
                "${_results!['radioFee'].toStringAsFixed(2)} ج.م",
              ),
              const Divider(color: Colors.white54),
              _buildResultRow(
                "الإجمالي المطلوب",
                "${_results!['totalRequired'].toStringAsFixed(0)} ج.م",
                isBold: true,
                color: Colors.cyanAccent,
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _results == null ? null : _save,
              icon: const Icon(Icons.save, color: Colors.black),
              label: const Text("حفظ وإصدار التقرير",
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  minimumSize: const Size(double.infinity, 55)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(
              child:
                  Text(label, style: const TextStyle(color: Colors.white70))),
          SizedBox(
              width: 100,
              child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.black26,
                      contentPadding: EdgeInsets.all(8)),
                  onChanged: (_) => _calculate())),
        ]));
  }

  Widget _buildResultRow(String label, String value,
      {bool isBold = false, Color color = Colors.white}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 18 : 14)),
        ]));
  }

  Future<void> _save() async {
    try {
      final msg = await TheftFileManager.saveTheftCase(
        thiefName: widget.name,
        meterNumber: widget.meter,
        address: widget.address,
        results: _results!,
        appliances: widget.appliances,
        idFrontImage: widget.images['idFront'],
        idBackImage: widget.images['idBack'],
        videoFile: widget.images['video'],
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: const Color(0xFF203A43),
          title: const Text("تم حفظ المحضر بنجاح",
              style: TextStyle(color: Colors.cyanAccent)),
          content: Text(msg, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  Navigator.pop(context);
                },
                child: const Text("حسناً"))
          ],
        ),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF203A43),
          title: const Text(
            "تعذر حفظ المحضر",
            style: TextStyle(color: Colors.redAccent),
          ),
          content: SelectableText(
            error.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("حسناً"),
            ),
          ],
        ),
      );
    }
  }
}
