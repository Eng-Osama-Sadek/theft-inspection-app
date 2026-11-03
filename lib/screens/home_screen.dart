import 'package:flutter/material.dart';
import '../services/file_manager.dart';
import 'add_case_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<TheftCaseRecord> _cases = [];
  String _searchQuery = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final cases = await TheftFileManager.loadTheftCases();
      if (!mounted) return;
      setState(() {
        _cases = cases;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  List<TheftCaseRecord> get _filteredCases {
    final query = _searchQuery.trim().toLowerCase();
    return _cases.where((record) {
      final date =
          DateTime(record.date.year, record.date.month, record.date.day);
      final matchesQuery = query.isEmpty ||
          record.name.toLowerCase().contains(query) ||
          record.meterNumber.toLowerCase().contains(query);
      final matchesFrom =
          _fromDate == null || !date.isBefore(_dateOnly(_fromDate!));
      final matchesTo = _toDate == null || !date.isAfter(_dateOnly(_toDate!));
      return matchesQuery && matchesFrom && matchesTo;
    }).toList();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _selectDate({required bool isStartDate}) async {
    final now = DateTime.now();
    final minimumDate = DateTime(2000);
    final firstDate =
        !isStartDate && _fromDate != null ? _dateOnly(_fromDate!) : minimumDate;
    final lastDate = isStartDate
        ? (_toDate != null && _toDate!.isBefore(now) ? _toDate! : now)
        : now;
    final currentDate = isStartDate ? _fromDate : _toDate;
    final initialDate = currentDate != null &&
            !currentDate.isBefore(firstDate) &&
            !currentDate.isAfter(lastDate)
        ? currentDate
        : (isStartDate && _toDate != null ? _toDate! : lastDate);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isStartDate ? 'اختر تاريخ البداية' : 'اختر تاريخ النهاية',
    );
    if (!mounted || selectedDate == null) return;
    setState(() {
      if (isStartDate) {
        _fromDate = selectedDate;
      } else {
        _toDate = selectedDate;
      }
    });
  }

  Future<void> _openAddCase() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCaseScreen()),
    );
    if (mounted) {
      await _loadCases();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleCases = _filteredCases;
    final totalFines = _cases.fold<double>(
      0,
      (sum, record) => sum + (record.totalRequired ?? 0),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final titleSize =
                            constraints.maxWidth < 360 ? 17.0 : 20.0;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(Icons.bolt,
                                  color: Colors.cyanAccent, size: 26),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'منظومة فحص سرقات التيار الكهربائي',
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleSize,
                                  height: 1.25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'تحديث المحاضر',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 36, minHeight: 36),
                              onPressed: _loadCases,
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.cyanAccent,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'اكتب الاسم أو رقم البطاقة/العداد للبحث',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5)),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.cyanAccent),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'مسح البحث',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: const Icon(Icons.close,
                                    color: Colors.white70),
                              ),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 380;
                        final cardWidth = stacked
                            ? constraints.maxWidth
                            : (constraints.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _buildStatCard(
                                'إجمالي المحاضر المحفوظة',
                                '${_cases.length}',
                                Colors.cyanAccent,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _buildStatCard(
                                'إجمالي الغرامات المحفوظة',
                                '${totalFines.toStringAsFixed(0)} ج.م',
                                Colors.orangeAccent,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            'من',
                            _fromDate,
                            onTap: () => _selectDate(isStartDate: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDateField(
                            'إلى',
                            _toDate,
                            onTap: () => _selectDate(isStartDate: false),
                          ),
                        ),
                        if (_fromDate != null || _toDate != null)
                          IconButton(
                            tooltip: 'مسح الفترة',
                            onPressed: () => setState(() {
                              _fromDate = null;
                              _toDate = null;
                            }),
                            icon: const Icon(Icons.filter_alt_off,
                                color: Colors.cyanAccent),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _searchQuery.isEmpty &&
                              _fromDate == null &&
                              _toDate == null
                          ? 'المحاضر المسجلة'
                          : 'نتائج البحث (${visibleCases.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                              color: Colors.cyanAccent),
                        ),
                      )
                    else if (_loadError != null)
                      _buildMessage(
                        'تعذر تحميل المحاضر: $_loadError',
                        isError: true,
                      )
                    else if (visibleCases.isEmpty)
                      _buildMessage(
                        _cases.isEmpty
                            ? 'لا توجد محاضر محفوظة حتى الآن'
                            : 'لا توجد محاضر تطابق البحث أو الفترة المحددة',
                      )
                    else
                      ...visibleCases.map(_buildCaseCard),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openAddCase,
                    icon: const Icon(Icons.add, color: Colors.black, size: 22),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'إضافة حالة سرقة جديدة',
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date, {
    required VoidCallback onTap,
  }) {
    final value = date == null
        ? 'اختر تاريخًا'
        : '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Material(
      color: Colors.black.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.calendar_month,
                  color: Colors.cyanAccent, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$label: $value',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseCard(TheftCaseRecord record) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _showCaseDetails(record),
        leading: const Icon(Icons.description, color: Colors.cyanAccent),
        title: Text(
          record.name.isEmpty ? 'محضر بدون اسم' : record.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          [
            if (record.meterNumber.isNotEmpty)
              'رقم العداد: ${record.meterNumber}',
            _formatDate(record.date),
          ].join(' • '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: record.totalRequired == null
            ? null
            : ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 82),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${record.totalRequired!.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMessage(String message, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError ? Colors.redAccent : Colors.white70,
        ),
      ),
    );
  }

  void _showCaseDetails(TheftCaseRecord record) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: Text(record.name, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.meterNumber.isNotEmpty)
              Text('رقم العداد: ${record.meterNumber}'),
            Text('التاريخ: ${_formatDate(record.date)}'),
            Text(
              record.totalRequired == null
                  ? 'قيمة الغرامة: غير متاحة لهذا المحضر القديم'
                  : 'قيمة الغرامة: ${record.totalRequired!.toStringAsFixed(0)} ج.م',
            ),
            const SizedBox(height: 8),
            const Text('ملف المحضر والتقرير موجودان داخل مجلد الحالة.'),
            SelectableText(record.directoryPath),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
