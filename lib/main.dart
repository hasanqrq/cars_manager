import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'car_form.dart';
import 'cars_table.dart';
import 'database_helper.dart';
import 'dart:convert';
import 'dart:io';
import 'car.dart';
import 'package:file_picker/file_picker.dart';
import 'firebase_options.dart';
import 'favorite.dart'; // Import the Favorite screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cars Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState(); // Made public
}

class WelcomeScreenState extends State<WelcomeScreen> {
  // Made public
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Cars Manager',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xff973131),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Image.asset(
                'assets/images/LogoTrans.png',
                height: 300,
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CarForm()),
                );
              },
              child: const Text(
                'Go to Car Form',
                style: TextStyle(
                  color: Color(0xffE0A75E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CarsTable()),
                );
              },
              child: const Text(
                'Go to Car Table',
                style: TextStyle(
                  color: Color(0xffE0A75E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FavoriteScreen(
                          favorites: [])), // Navigate to the Favorite screen
                );
              },
              child: const Text(
                'Go to Favorites',
                style: TextStyle(
                  color: Color(0xffE0A75E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _exportDatabase(),
              child: const Text(
                'Export Database',
                style: TextStyle(
                  color: Color(0xffE0A75E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _importDatabase(),
              child: const Text(
                'Import Database',
                style: TextStyle(
                  color: Color(0xffE0A75E),
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            const Text(
              "Designed By Eng.Hasan Q",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffE0A75E),
                  fontSize: 10),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _exportDatabase() async {
    try {
      final cars = await DatabaseHelper().getCars();
      final jsonData = cars.map((car) => car.toMap()).toList();
      final jsonString = jsonEncode(jsonData);

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (!mounted) return; // Check if widget is still mounted

      if (selectedDirectory != null) {
        final fileName =
            await _askFileName(context, "Enter a file name for the export");
        if (fileName != null && fileName.isNotEmpty) {
          final file = File('$selectedDirectory/$fileName.json');
          await file.writeAsString(jsonString);
          if (!mounted) return; // Check if widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Database exported to ${file.path}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export database: $e')),
      );
    }
  }

  Future<void> _importDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (!mounted) return; // Check if widget is still mounted

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final List<dynamic> jsonData = jsonDecode(jsonString);

        for (var carMap in jsonData) {
          final car = Car.fromMap(carMap);
          await DatabaseHelper().insertCar(car);
        }

        if (!mounted) return; // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database imported from ${file.path}')),
        );
      }
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import database: $e')),
      );
    }
  }

  Future<String?> _askFileName(BuildContext context, String title) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter file name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('SAVE'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }
}
