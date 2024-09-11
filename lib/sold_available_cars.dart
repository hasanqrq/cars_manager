import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'car.dart';
import 'package:intl/intl.dart';

class SoldAvailableCarsScreen extends StatefulWidget {
  const SoldAvailableCarsScreen({super.key});

  @override
  _SoldAvailableCarsScreenState createState() =>
      _SoldAvailableCarsScreenState();
}

class _SoldAvailableCarsScreenState extends State<SoldAvailableCarsScreen> {
  List<Car> _soldCars = [];
  List<Car> _availableCars = [];
  List<Car> _favorites = []; // List to manage favorites

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    final cars = await DatabaseHelper().getCars();
    setState(() {
      _soldCars = cars.where((car) => car.isSold).toList();
      _availableCars = cars.where((car) => !car.isSold).toList();
    });
  }

  void _deleteCar(String id) async {
    await DatabaseHelper().deleteCar(id);
    _loadCars(); // Refresh the cars after deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Car deleted successfully!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _editCar(Car car) async {
    // This function can be connected to the car form editing screen
  }

  void _printCar(Car car) async {
    // Function to print the car details
  }

  void _toggleFavorite(Car car) {
    setState(() {
      if (_favorites.contains(car)) {
        _favorites.remove(car);
      } else {
        _favorites.add(car);
      }
    });
  }

  void _toggleSold(Car car) async {
    final newStatus = !car.isSold; // Toggle the sold status
    await DatabaseHelper().markCarAsSold(car.id, newStatus);
    _loadCars(); // Refresh the cars after toggling the sold status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Car marked as ${newStatus ? 'Sold' : 'Available'}!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sold and Available Cars'),
      ),
      body: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Available Cars'),
                      Tab(text: 'Sold Cars'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCarTable(_availableCars, false),
                        _buildCarTable(_soldCars, true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build a table of cars with action buttons
  Widget _buildCarTable(List<Car> cars, bool isSold) {
    if (cars.isEmpty) {
      return Center(
        child: Text(isSold ? 'No sold cars.' : 'No available cars.'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Contract Number')),
          DataColumn(label: Text('Vehicle Number')),
          DataColumn(label: Text('Shield Number')),
          DataColumn(label: Text('Manufacturer')),
          DataColumn(label: Text('Trade Nickname')),
          DataColumn(label: Text('Colour')),
          DataColumn(label: Text('Year of Manufacture')),
          DataColumn(label: Text('Engine Capacity')),
          DataColumn(label: Text('Cost Price')),
          DataColumn(label: Text('Sell Price')),
          DataColumn(label: Text('Notes')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: cars.map((car) {
          final String formattedDate =
              DateFormat.y().format(car.yearOfmanufacture);
          return DataRow(
            cells: [
              DataCell(Text(car.contractNumber)),
              DataCell(Text(car.vehicleNumber.toString())),
              DataCell(Text(car.shieldNumber)),
              DataCell(Text(car.manufacturer)),
              DataCell(Text(car.tradeNickname)),
              DataCell(Text(car.colour)),
              DataCell(Text(formattedDate)),
              DataCell(Text(car.engineCapacity.toString())),
              DataCell(Text(car.costPrice.toString())),
              DataCell(Text(car.sellPrice.toString())),
              DataCell(Text(car.notes)),
              DataCell(
                Text(
                  isSold ? 'Sold' : 'Available',
                  style: TextStyle(
                    color: isSold ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _editCar(car); // Edit the car details
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteCar(car.id); // Delete the car
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.print, color: Colors.green),
                      onPressed: () {
                        _printCar(car); // Print the car details
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _favorites.contains(car)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.pink,
                      ),
                      onPressed: () {
                        _toggleFavorite(car); // Toggle favorite
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        car.isSold
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        _toggleSold(car); // Mark the car as sold/available
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
