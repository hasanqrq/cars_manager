import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'car.dart';
import 'package:intl/intl.dart';

class CarsTable extends StatefulWidget {
  const CarsTable({Key? key}) : super(key: key);

  @override
  _CarsTableState createState() => _CarsTableState();
}

class _CarsTableState extends State<CarsTable> {
  List<Car>? _cars;
  String searchQuery = ""; // Variable to hold the search query

  @override
  void initState() {
    super.initState();
    _refreshCars();
  }

  void _refreshCars() async {
    final cars = await DatabaseHelper().getCars();
    setState(() {
      _cars = cars;
    });
  }

  void _deleteCar(String id) async {
    await DatabaseHelper().deleteCar(id);
    setState(() {
      _cars = _cars?.where((car) => car.id != id).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Car deleted successfully!'),
        duration: Duration(seconds: 3),
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
            child: _cars == null
                ? const Center(child: CircularProgressIndicator())
                : _cars!.isEmpty
                    ? const Center(child: Text('No cars found.'))
                    : SingleChildScrollView(
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
                            rows: _filterCars(_cars!).map((car) {
                              final String formattedDate = DateFormat.y().format(
                                  car.productionDate); // Format date to show only the year
                              return DataRow(
                                cells: [
                                  DataCell(Text(car.typeOfCar)),
                                  DataCell(Text(car.numberOfCar.toString())),
                                  DataCell(Text(car.chassisNumber)),
                                  DataCell(Text(car.make)),
                                  DataCell(Text(car.model)),
                                  DataCell(Text(car.color)),
                                  DataCell(Text(
                                      formattedDate)), // Display only the year
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
                      ),
          ),
        ],
      ),
    );
  }
}
