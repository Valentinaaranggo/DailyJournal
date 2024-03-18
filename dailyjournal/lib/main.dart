import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(JournalApp());
}

class JournalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journal App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          backgroundColor: Color.fromARGB(255, 108, 132, 110),
          cardColor: const Color.fromARGB(255, 61, 101, 65),
          accentColor: Colors.greenAccent,
        ),
        appBarTheme: AppBarTheme(
          color: const Color.fromARGB(255, 32, 63, 34),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) => const Color.fromARGB(255, 41, 65, 42),
            ),
            foregroundColor: MaterialStateProperty.resolveWith(
              (states) => Colors.white,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith(
              (states) => Colors.white,
            ),
          ),
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white),
        ),
      ),
      home: JournalScreen(),
    );
  }
}
