import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'car.dart';

class CarsTable extends StatefulWidget {
  const CarsTable({Key? key}) : super(key: key);

  @override
  _CarsTableState createState() => _CarsTableState();
}

class _CarsTableState extends State<CarsTable> {
  late Future<List<Car>> _carsFuture;
  String searchQuery = ""; // Variable to hold the search query

  @override
  void initState() {
    super.initState();
    _refreshCars();
  }

  void _refreshCars() {
    setState(() {
      _carsFuture = DatabaseHelper().getCars();
    });
  }

  void _deleteCar(String id) async {
    await DatabaseHelper().deleteCar(id);
    _refreshCars(); // Refresh the car list after deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Car deleted successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  List<Car> _filterCars(List<Car> cars) {
    // Filter the list of cars based on the search query
    if (searchQuery.isEmpty) {
      return cars;
    } else {
      return cars.where((car) {
        return car.typeOfCar
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            car.chassisNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            car.make.toLowerCase().contains(searchQuery.toLowerCase()) ||
            car.model.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Cars'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Type, Chassis Number, Make, or Model',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Car>>(
              future: _carsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No cars found.'));
                } else {
                  final cars = _filterCars(snapshot.data!);
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Number')),
                          DataColumn(label: Text('Chassis Number')),
                          DataColumn(label: Text('Make')),
                          DataColumn(label: Text('Model')),
                          DataColumn(label: Text('Color')),
                          DataColumn(label: Text('Production Date')),
                          DataColumn(label: Text('Engine Capacity')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: cars.map((car) {
                          return DataRow(
                            cells: [
                              DataCell(Text(car.typeOfCar)),
                              DataCell(Text(car.numberOfCar.toString())),
                              DataCell(Text(car.chassisNumber)),
                              DataCell(Text(car.make)),
                              DataCell(Text(car.model)),
                              DataCell(Text(car.color)),
                              DataCell(
                                  Text(car.productionDate.toIso8601String())),
                              DataCell(Text(car.engineCapacity.toString())),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteCar(car.id);
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
