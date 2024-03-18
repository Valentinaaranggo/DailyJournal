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


class JournalScreen extends StatefulWidget {
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    StartJournalingScreen(),
    QuotesScreen(),
    EntriesPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DailyJournal'),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Start Journaling',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Entries',
          ),
        ],
      ),
    );
  }
}

class StartJournalingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 500),
                pageBuilder: (, , ) => EntriesPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Text('Start Journaling'),
        ),
      ),
    );
  }
}

class QuotesScreen extends StatelessWidget {
  final List<String> quotes = [
    '"It takes courage to grow up and become who you really are." — E.E. Cummings',
    '"Nothing is impossible. The word itself says I am possible!" — Audrey Hepburn',
    '"To bring about change, you must not be afraid to take the first step. We will fail when we fail to try." — Rosa Parks',
  ];
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Motivational'),
      ),
      body: PageView.builder(
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                quotes[index],
                style: TextStyle(fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
