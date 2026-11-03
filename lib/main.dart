import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() => runApp(const TheftApp());

class TheftApp extends StatelessWidget {
  const TheftApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منظومة سرقات الكهرباء',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0F2027),
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme).apply(bodyColor: Colors.white),
      ),
      home: const HomeScreen(),
    );
  }
}