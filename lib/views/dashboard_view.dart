import 'package:flutter/material.dart';
import 'new_inspection_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('منظومة فحص سرقات التيار - أسيوط جنوب'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // شريط البحث الذكي
            TextField(
              decoration: const InputDecoration(
                labelText: 'بحث بالاسم أو رقم البطاقة الشخصية...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // لوحة العرض السريع (كروت إحصائية)
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.amber.shade100,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [Text('إجمالي الغرامات المحصلة'), Text('00,000 ج.م', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.red.shade100,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [Text('المحاضر المفتوحة'), Text('12 حالة فحص', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Expanded(
              child: Center(child: Text('قائمة المعاينات المسجلة تظهر هنا')),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NewInspectionView()));
        },
        label: const Text('إضافة فحص حالة سرقة جديدة'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}