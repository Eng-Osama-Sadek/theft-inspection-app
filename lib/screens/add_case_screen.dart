import 'package:flutter/material.dart';
import '../logic/calculator.dart';
import 'camera_screen.dart';
import 'report_screen.dart';

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});
  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _nameController = TextEditingController();
  final _meterController = TextEditingController();
  final _addressController = TextEditingController();
  final _applianceNameController = TextEditingController();
  int _selectedActivity = 1;
  final List<Map<String, dynamic>> _appliances = [];
  final _wattController = TextEditingController();
  bool _isPreviousViolation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _meterController.dispose();
    _addressController.dispose();
    _applianceNameController.dispose();
    _wattController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
          title: const Text("إضافة حالة سرقة جديدة"),
          backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_nameController, "اسم المخالف"),
            _buildTextField(_meterController, "رقم البطاقة/العداد"),
            _buildTextField(_addressController, "العنوان"),
            DropdownButtonFormField<int>(
              initialValue: _selectedActivity,
              dropdownColor: const Color(0xFF203A43),
              style: const TextStyle(color: Colors.white),
              items: TheftCalculator.activityData.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key, child: Text(e.value['name'])))
                  .toList(),
              onChanged: (v) => setState(() => _selectedActivity = v!),
              decoration: const InputDecoration(
                  labelText: "النشاط", filled: true, fillColor: Colors.black26),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _applianceNameController,
                    "اسم الحمل (مثال: سخان كهرباء)",
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: _buildTextField(
                    _wattController,
                    "الوات",
                    isNumber: true,
                  ),
                ),
                IconButton(
                  tooltip: "إضافة حمل",
                  onPressed: _addAppliance,
                  icon: const Icon(Icons.add_circle, color: Colors.cyanAccent),
                ),
              ],
            ),
            ..._appliances.asMap().entries.map(
                  (entry) => ListTile(
                    title: Text(
                      entry.value['name'] as String,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${entry.value['watts']} وات",
                      style: const TextStyle(color: Colors.cyanAccent),
                    ),
                    trailing: IconButton(
                      tooltip: "حذف الحمل",
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: () =>
                          setState(() => _appliances.removeAt(entry.key)),
                    ),
                  ),
                ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "سبق تحرير محضر عن المخالفة",
                style: TextStyle(color: Colors.white),
              ),
              value: _isPreviousViolation,
              activeThumbColor: Colors.cyanAccent,
              onChanged: (value) =>
                  setState(() => _isPreviousViolation = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                if (_appliances.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("أضف حملًا واحدًا على الأقل")),
                  );
                  return;
                }
                double totalWatts = _appliances.fold(
                  0.0,
                  (sum, item) => sum + (item['watts'] as double),
                );
                final result = await Navigator.push(context,
                    MaterialPageRoute(builder: (c) => const CameraScreen()));
                if (!context.mounted || result == null) return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => ReportScreen(
                              name: _nameController.text,
                              meter: _meterController.text,
                              address: _addressController.text,
                              activityId: _selectedActivity,
                              totalWatts: totalWatts,
                              images: result,
                              appliances:
                                  List<Map<String, dynamic>>.from(_appliances),
                              isPreviousViolation: _isPreviousViolation,
                            )));
              },
              icon: const Icon(Icons.camera_alt, color: Colors.black),
              label: const Text("تصوير الواقعة والانتقال للحساب",
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  void _addAppliance() {
    final name = _applianceNameController.text.trim();
    final watts = double.tryParse(_wattController.text.trim());
    if (name.isEmpty || watts == null || watts <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أدخل اسم الحمل وقدرته بالوات")),
      );
      return;
    }

    setState(() {
      _appliances.add({'name': name, 'watts': watts});
      _applianceNameController.clear();
      _wattController.clear();
    });
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textDirection: isNumber ? TextDirection.ltr : TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none)),
      ),
    );
  }
}
