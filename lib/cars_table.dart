import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'car.dart';
import 'package:intl/intl.dart';

class CarsTable extends StatefulWidget {
  const CarsTable({super.key});

  @override
  CarsTableState createState() => CarsTableState();
}

class CarsTableState extends State<CarsTable> {
  List<Car>? _cars;
  String searchQuery = ""; // Variable to hold the search query

  @override
  void initState() {
    super.initState();
    _refreshCars();
  }

  void _refreshCars() async {
    final cars = await DatabaseHelper().getCars();
    debugPrint('Fetched cars: ${cars.length}'); // Debugging line

    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _cars = cars;
    });
  }

  void _deleteCar(String id) async {
    await DatabaseHelper().deleteCar(id);

    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _cars = _cars?.where((car) => car.id != id).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
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
        return car.contractNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            car.shieldNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            car.manufacturer
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            car.tradeNickname.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stored Cars',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText:
                    'Search by Type, Shield Number, Trade Nickname, or Contract Number',
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
                              DataColumn(label: Text('Contract Number')),
                              DataColumn(label: Text('Vehicle Number ')),
                              DataColumn(label: Text('Shield Number ')),
                              DataColumn(label: Text('Manufacturer')),
                              DataColumn(label: Text('Trade Nickname')),
                              DataColumn(label: Text('Colour')),
                              DataColumn(label: Text('Year of manufacture')),
                              DataColumn(label: Text('Engine Capacity')),
                              DataColumn(label: Text('Notes')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _filterCars(_cars!).map((car) {
                              final String formattedDate = DateFormat.y().format(
                                  car.yearOfmanufacture); // Format date to show only the year
                              return DataRow(
                                cells: [
                                  DataCell(Text(car.contractNumber)),
                                  DataCell(Text(car.vehicleNumber.toString())),
                                  DataCell(Text(car.shieldNumber)),
                                  DataCell(Text(car.manufacturer)),
                                  DataCell(Text(car.tradeNickname)),
                                  DataCell(Text(car.colour)),
                                  DataCell(Text(
                                      formattedDate)), // Display only the year
                                  DataCell(Text(car.engineCapacity.toString())),
                                  DataCell(Text(car.notes)),
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
