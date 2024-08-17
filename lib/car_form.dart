import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'cars_table.dart';
import 'package:cars_manager/car.dart';

class CarForm extends StatefulWidget {
  const CarForm({Key? key}) : super(key: key);

  @override
  CarFormState createState() => CarFormState();
}

class CarFormState extends State<CarForm> {
  final _formKey = GlobalKey<FormState>();

  final _typeOfCarController = TextEditingController();
  final _numberOfCarController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _productionDateController = TextEditingController();
  final _engineCapacityController = TextEditingController();

  @override
  void dispose() {
    _typeOfCarController.dispose();
    _numberOfCarController.dispose();
    _chassisNumberController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _productionDateController.dispose();
    _engineCapacityController.dispose();
    super.dispose();
  }

  void _saveCar() async {
    if (_formKey.currentState!.validate()) {
      final car = Car(
        id: FirebaseFirestore.instance.collection('cars').doc().id,
        typeOfCar: _typeOfCarController.text,
        numberOfCar: int.parse(_numberOfCarController.text),
        chassisNumber: _chassisNumberController.text,
        make: _makeController.text,
        model: _modelController.text,
        color: _colorController.text,
        productionDate: DateTime.parse(_productionDateController.text),
        engineCapacity: double.parse(_engineCapacityController.text),
      );
      await DatabaseHelper().insertCar(car);

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
      _typeOfCarController.clear();
      _numberOfCarController.clear();
      _chassisNumberController.clear();
      _makeController.clear();
      _modelController.clear();
      _colorController.clear();
      _productionDateController.clear();
      _engineCapacityController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cars Manager',
          style: TextStyle(
            color: Colors.blueAccent,
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
                controller: _typeOfCarController,
                decoration: const InputDecoration(labelText: 'Type of Car'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the car type' : null,
              ),
              TextFormField(
                controller: _numberOfCarController,
                decoration: const InputDecoration(labelText: 'Number of Car'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter the car number' : null,
              ),
              TextFormField(
                controller: _chassisNumberController,
                decoration: const InputDecoration(labelText: 'Chassis Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the chassis number' : null,
              ),
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(labelText: 'Make'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the car make' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the car model' : null,
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the car color' : null,
              ),
              TextFormField(
                controller: _productionDateController,
                decoration: const InputDecoration(
                    labelText: 'Production Date (YYYY-MM-DD)'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter the production date' : null,
                keyboardType: TextInputType.datetime,
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCar,
                child: const Text('Save Car'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _clearFields,
                child: const Text('Clear Data'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CarsTable()),
                  );
                },
                child: const Text('Go to Cars Table'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
