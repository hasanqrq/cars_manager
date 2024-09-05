import 'package:flutter/material.dart';
import 'car.dart';
import 'car_form.dart';
import 'print_car.dart'; // Import the print function
import 'package:intl/intl.dart';

class FavoriteScreen extends StatefulWidget {
  final List<Car> favorites;

  const FavoriteScreen({Key? key, required this.favorites}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final List<Car> _selectedCars =
      []; // List to store selected cars for printing

  void _printSelectedCars() async {
    if (_selectedCars.isNotEmpty) {
      await generateAndPrintArabicPdf(_selectedCars);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No cars selected to print.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleCarSelection(Car car) {
    setState(() {
      if (_selectedCars.contains(car)) {
        _selectedCars.remove(car);
      } else {
        _selectedCars.add(car);
      }
    });
  }

  void _editCar(BuildContext context, Car car) async {
    final updatedCar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarForm(car: car),
      ),
    );

    if (updatedCar != null) {
      setState(() {}); // Refresh state after editing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Car updated successfully!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _removeFromFavorites(Car car) {
    setState(() {
      widget.favorites.remove(car);
      _selectedCars.remove(car); // Remove from selected if already selected
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Cars',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xff973131),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printSelectedCars, // Print selected cars
          ),
        ],
      ),
      body: widget.favorites.isEmpty
          ? const Center(child: Text('No favorite cars found.'))
          : ListView.builder(
              itemCount: widget.favorites.length,
              itemBuilder: (context, index) {
                final car = widget.favorites[index];
                final String formattedDate =
                    DateFormat.y().format(car.yearOfmanufacture);

                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: _selectedCars.contains(car),
                      onChanged: (bool? value) {
                        _toggleCarSelection(car);
                      },
                    ),
                    title: Text(car.contractNumber),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vehicle Number: ${car.vehicleNumber}'),
                        Text('Shield Number: ${car.shieldNumber}'),
                        Text('Manufacturer: ${car.manufacturer}'),
                        Text('Trade Nickname: ${car.tradeNickname}'),
                        Text('Colour: ${car.colour}'),
                        Text('Year of Manufacture: $formattedDate'),
                        Text('Engine Capacity: ${car.engineCapacity}'),
                        Text('Cost Price: ${car.costPrice}'),
                        Text('Sell Price: ${car.sellPrice}'),
                        Text('Notes: ${car.notes}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _editCar(context, car);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.print, color: Colors.green),
                          onPressed: () {
                            generateAndPrintArabicPdf([car]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            _removeFromFavorites(car);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
