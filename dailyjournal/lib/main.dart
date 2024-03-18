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

class EntriesPage extends StatefulWidget {
  @override
  _EntriesPageState createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? entriesJson = prefs.getStringList('entries');
    if (entriesJson != null) {
      setState(() {
        entries = entriesJson
            .map((e) => json.decode(e) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries.map((e) => json.encode(e)).toList();
    await prefs.setStringList('entries', entriesJson);
  }

  void deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
      _saveEntries();
    });
    Navigator.pop(context);
  }

  void saveEditedEntry(Map<String, dynamic> entry, int index) {
    setState(() {
      entries[index] = entry;
      _saveEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entries'),
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return ListTile(
            title: Text(entry['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Date: ${entry['date']}'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EntryDetailScreen(
                    entry: entry,
                    index: index,
                    onSave: saveEditedEntry,
                    onDelete: () => deleteEntry(index),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEntry = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEntryScreen()),
          );
          if (newEntry != null) {
            setState(() {
              entries.add(newEntry);
              _saveEntries();
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddEntryScreen extends StatefulWidget {
  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  String? mood;
  String? entryTitle;
  String? entryText;
  Uint8List? imageBytes;

  Future<void> _getImage(ImageSource source) async {
    final pickedImage = await ImagePicker().getImage(source: source);
    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        imageBytes = bytes;
      });
    }
  }
}
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Entry'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              onChanged: (value) {
                setState(() {
                  entryTitle = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: mood,
              onChanged: (value) {
                setState(() {
                  mood = value ?? '';
                });
              },
              items: <String>['Happy', 'Sad', 'Angry', 'Excited']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Mood',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  entryText = value;
                });
              },
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Write about your day...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                  child: Text('Upload from Camera Roll'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (entryTitle != null && entryText != null && mood != null) {
                  final newEntry = {
                    'title': entryTitle,
                    'text': entryText,
                    'mood': mood,
                    'date': DateTime.now().toString(),
                    'image': imageBytes,
                  };
                  Navigator.pop(context, newEntry);
                } else {
                  // Show error or prompt to fill all fields
                }
              },
              child: Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class EntryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> entry;
  final int index;
  final Function(Map<String, dynamic> entry, int index) onSave;
  final VoidCallback onDelete;

  EntryDetailScreen(
      {required this.entry,
      required this.index,
      required this.onSave,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entry Detail'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                entry['title'],
                style: TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Text(
                'Date: ${entry['date']}',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Hero(
                tag: 'image_${entry['date']}', // Unique tag for each image
                child: entry['image'] != null
                    ? Image.memory(
                        entry['image'],
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : SizedBox.shrink(),
              ),
              SizedBox(height: 16.0),
              Text(
                entry['text'],
                style: TextStyle(fontSize: 36.0, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEntryScreen(
                      entry: entry,
                      index: index,
                      onSave: onSave,
                    ),
                  ),
                );
              },
              child: Text('Edit Entry'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete Entry'),
                      content:
                          Text('Are you sure you want to delete this entry?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: onDelete,
                          child: Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Delete Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
class EditEntryScreen extends StatefulWidget {
  final Map<String, dynamic> entry;
  final int index;
  final Function(Map<String, dynamic> entry, int index) onSave;

  EditEntryScreen(
      {required this.entry, required this.index, required this.onSave});

  @override
  _EditEntryScreenState createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  String? mood;
  String? entryTitle;
  String? entryText;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    entryTitle = widget.entry['title'];
    entryText = widget.entry['text'];
    mood = widget.entry['mood'];
    imageBytes = widget.entry['image'];
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedImage = await ImagePicker().getImage(source: source);
    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Entry'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              initialValue: entryTitle,
              onChanged: (value) {
                setState(() {
                  entryTitle = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: mood,
              onChanged: (value) {
                setState(() {
                  mood = value ?? '';
                });
              },
              items: <String>['Happy', 'Sad', 'Angry', 'Excited']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Mood',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              initialValue: entryText,
              onChanged: (value) {
                setState(() {
                  entryText = value;
                });
              },
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Write about your day...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _getImage(ImageSource.gallery),
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final editedEntry = {
                  'title': entryTitle,
                  'text': entryText,
                  'mood': mood,
                  'date': DateTime.now().toString(),
                  'image': imageBytes,
                };
                widget.onSave(editedEntry, widget.index);
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
