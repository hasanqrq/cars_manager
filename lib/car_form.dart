import 'package:cars_manager/cars_table.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'car.dart';
import 'database_helper.dart';

class CarForm extends StatefulWidget {
  final Car? car; // Add this parameter to accept a Car object

  const CarForm({super.key, this.car});

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
  final _costPriceController = TextEditingController(); // New field
  final _sellPriceController = TextEditingController(); // New field

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      // If a car is passed, pre-fill the form fields
      _contractNumberController.text = widget.car!.contractNumber;
      _vehicleNumberController.text = widget.car!.vehicleNumber.toString();
      _shieldNumberController.text = widget.car!.shieldNumber;
      _manufacturerController.text = widget.car!.manufacturer;
      _tradeNicknameController.text = widget.car!.tradeNickname;
      _colourController.text = widget.car!.colour;
      _yearOfmanufactureController.text =
          widget.car!.yearOfmanufacture.year.toString();
      _engineCapacityController.text = widget.car!.engineCapacity.toString();
      _notesController.text = widget.car!.notes;
      _costPriceController.text = widget.car!.costPrice.toString();
      _sellPriceController.text = widget.car!.sellPrice.toString();
    }
  }

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
    _costPriceController.dispose();
    _sellPriceController.dispose();

    super.dispose();
  }

  void _saveCar() async {
    if (_formKey.currentState!.validate()) {
      final car = Car(
        id: widget.car?.id ??
            FirebaseFirestore.instance
                .collection('cars')
                .doc()
                .id, // Use existing ID if editing
        contractNumber: _contractNumberController.text,
        vehicleNumber: int.parse(_vehicleNumberController.text),
        shieldNumber: _shieldNumberController.text,
        manufacturer: _manufacturerController.text,
        tradeNickname: _tradeNicknameController.text,
        colour: _colourController.text,
        yearOfmanufacture: DateTime(int.parse(
            _yearOfmanufactureController.text)), // Using only the year
        engineCapacity: double.parse(_engineCapacityController.text),
        notes: _notesController.text,
        costPrice: double.parse(_costPriceController.text), // New field
        sellPrice: double.parse(_sellPriceController.text), // New field
      );
      await DatabaseHelper().insertCar(car);

      if (!mounted) return; // Check if widget is still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Car saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, car); // Return the car object to refresh the table
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
      _costPriceController.clear();
      _sellPriceController.clear();
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
                decoration: const InputDecoration(labelText: 'Vehicle Number'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter the Vehicle Number' : null,
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
                decoration:
                    const InputDecoration(labelText: 'Year of manufacture'),
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
              TextFormField(
                controller: _costPriceController,
                decoration: const InputDecoration(labelText: 'Cost Price'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the cost price' : null,
              ),
              TextFormField(
                controller: _sellPriceController,
                decoration: const InputDecoration(labelText: 'Sell Price'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the sell price' : null,
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
                  'Go to Car Table',
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
