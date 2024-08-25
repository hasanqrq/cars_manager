import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'cars_table.dart';
import 'car.dart';

class CarForm extends StatefulWidget {
  const CarForm({super.key});

  @override
  CarFormState createState() => CarFormState();
}

class CarFormState extends State<CarForm> {
  final _formKey = GlobalKey<FormState>();

  final _contractNumberController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _shieldNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _tradeNicknameController = TextEditingController();
  final _colourController = TextEditingController();
  final _yearOfmanufactureController = TextEditingController();
  final _engineCapacityController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _contractNumberController.dispose();
    _vehicleNumberController.dispose();
    _shieldNumberController.dispose();
    _manufacturerController.dispose();
    _tradeNicknameController.dispose();
    _colourController.dispose();
    _yearOfmanufactureController.dispose();
    _engineCapacityController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  void _saveCar() async {
    if (_formKey.currentState!.validate()) {
      final car = Car(
          id: FirebaseFirestore.instance.collection('cars').doc().id,
          contractNumber: _contractNumberController.text,
          vehicleNumber: int.parse(_vehicleNumberController.text),
          shieldNumber: _shieldNumberController.text,
          manufacturer: _manufacturerController.text,
          tradeNickname: _tradeNicknameController.text,
          colour: _colourController.text,
          yearOfmanufacture: DateTime(int.parse(
              _yearOfmanufactureController.text)), // Using only the year
          engineCapacity: double.parse(_engineCapacityController.text),
          notes: _notesController.text);
      await DatabaseHelper().insertCar(car);

      if (!mounted) return; // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Car saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      _clearFields();
    }
  }

  void _clearFields() {
    setState(() {
      _contractNumberController.clear();
      _vehicleNumberController.clear();
      _shieldNumberController.clear();
      _manufacturerController.clear();
      _tradeNicknameController.clear();
      _colourController.clear();
      _yearOfmanufactureController.clear();
      _engineCapacityController.clear();
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cars Manager',
          style: TextStyle(
            color: Color(0xff973131),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _contractNumberController,
                decoration: const InputDecoration(labelText: 'Contract Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the Contract Number' : null,
              ),
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(labelText: 'Vehicle Number '),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter the Vehicle Number ' : null,
              ),
              TextFormField(
                controller: _shieldNumberController,
                decoration: const InputDecoration(labelText: 'Shield Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the Shield Number' : null,
              ),
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: 'Manufacturer'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the car Manufacturer' : null,
              ),
              TextFormField(
                controller: _tradeNicknameController,
                decoration: const InputDecoration(labelText: 'Trade Nickname'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the car Trade Nickname' : null,
              ),
              TextFormField(
                controller: _colourController,
                decoration: const InputDecoration(labelText: 'Colour'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the car colour' : null,
              ),
              TextFormField(
                controller: _yearOfmanufactureController,
                decoration: const InputDecoration(
                    labelText: 'Year of manufacture'), // Updated label
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter the Year of Manufacture';
                  } else if (int.tryParse(value) == null || value.length != 4) {
                    return 'Enter a valid year';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _engineCapacityController,
                decoration:
                    const InputDecoration(labelText: 'Engine Capacity (L)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the engine capacity' : null,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the car Notes' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCar,
                child: const Text(
                  'Save Car',
                  style: TextStyle(
                    color: Color(0xffE0A75E),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _clearFields,
                child: const Text(
                  'Clear Data',
                  style: TextStyle(
                    color: Color(0xffE0A75E),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CarsTable()),
                  );
                },
                child: const Text(
                  'Go to Cars Table',
                  style: TextStyle(
                    color: Color(0xffE0A75E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
