import 'package:flutter/material.dart';
import 'views/dashboard_view.dart';

void main() {
  runApp(const TheftInspectionApp());
}

class TheftInspectionApp extends StatelessWidget {
  const TheftInspectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'منظومة سرقات التيار الكهربائي',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Roboto', // يمكنك استبدالها بخط عربي لاحقاً
      ),
      home: const DashboardView(),
    );
  }
}