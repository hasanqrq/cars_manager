import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'car_form.dart';
import 'cars_table.dart';
import 'database_helper.dart';
import 'car.dart';
import 'firebase_options.dart';
import 'dart:convert'; // For encoding/decoding JSON
import 'dart:html' as html; // Import for web file saving and reading
import 'favorite.dart';
import 'sold_available_cars.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
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
                      builder: (context) => const SoldAvailableCarsScreen()),
                );
              },
              child: const Text(
                'Go to Available & Sold Cars',
                style: TextStyle(
                  color: Color(0xffE0A75E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _exportDatabaseForWeb(),
              child: const Text(
                'Export Database',
                style: TextStyle(
                  color: Color(0xffE0A75E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _importDatabaseForWeb(),
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

  // Export Database Function for Web
  Future<void> _exportDatabaseForWeb() async {
    try {
      // Get the list of cars from the database
      final cars = await DatabaseHelper().getCars();

      // Convert car data to JSON string
      final jsonData = cars.map((car) => car.toMap()).toList();
      final jsonString = jsonEncode(jsonData);

      // Create a Blob from the JSON string
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);

      // Create a link element and trigger the download
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "cars_database.json")
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database exported successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export database: $e')),
      );
    }
  }

  // Import Database Function for Web
  Future<void> _importDatabaseForWeb() async {
    try {
      // Create file input and listen for file selection
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = '.json'; // Accept JSON files
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final file = uploadInput.files!.first;
        final reader = html.FileReader();

        reader.readAsText(file);
        reader.onLoadEnd.listen((event) async {
          final jsonString = reader.result as String;
          final List<dynamic> jsonData = jsonDecode(jsonString);

          // Insert each car into the database
          for (var carMap in jsonData) {
            final car = Car.fromMap(carMap);
            await DatabaseHelper().insertCar(car);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Database imported successfully!')),
          );
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import database: $e')),
      );
    }
  }
}
