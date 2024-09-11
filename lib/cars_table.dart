import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'car.dart';
import 'car_form.dart';
import 'favorite.dart'; // Import favorite screen
import 'search_cars.dart'; // Import the search function
import 'print_car.dart'; // Import the print function
import 'sold_available_cars.dart'; // Import the Sold/Available Cars Screen
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
    debugPrint('Fetched cars: ${cars.length}');

    if (!mounted) return;

    setState(() {
      _cars = cars;
    });
  }

  void _deleteCar(String id) async {
    await DatabaseHelper().deleteCar(id);

    if (!mounted) return;

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

  void _editCar(Car car) async {
    final updatedCar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarForm(car: car),
      ),
    );

    if (updatedCar != null) {
      _refreshCars();
    }
  }

  void _printTable() async {
    // Generate and print the PDF
    await generateAndPrintArabicPdf(_cars ?? []);
  }

<<<<<<< HEAD
  List<Car> _filterCars(List<Car> cars) {
    // Filter the list of cars based on the search query
    if (searchQuery.isEmpty) {
      return cars;
    } else {
      return cars.where((car) {
        return car.contractNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            car.vehicleNumber
                .toString()
                .contains(searchQuery) || // Added vehicleNumber search
            car.shieldNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            car.manufacturer
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            car.tradeNickname.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
=======
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
    final newStatus = !car.isSold; // Toggle sold status
    await DatabaseHelper().markCarAsSold(car.id, newStatus);

    setState(() {
      car.isSold = newStatus; // Update UI to reflect the new status
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Car marked as ${newStatus ? 'Sold' : 'Available'}!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoriteScreen(favorites: _favorites),
      ),
    );
>>>>>>> c5f6304 (solid)
  }

  // New function to navigate to Sold and Available cars screen
  void _navigateToSoldAvailableCarsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SoldAvailableCarsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stored Cars',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xff973131),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printTable, // Add print button to app bar
          ),
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed:
                _navigateToSoldAvailableCarsScreen, // Navigate to sold/available screen
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Reduced padding
            child: TextField(
              decoration: const InputDecoration(
                labelText:
                    'Search by Vehicle Number, Contract Number, Shield Number, Trade Nickname, or Manufacturer',
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
                    : Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _verticalScrollController,
                          scrollDirection: Axis.vertical,
                          child: Scrollbar(
                            controller: _horizontalScrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing:
                                    8.0, // Reduced spacing between columns
                                dataRowHeight:
                                    25.0, // Reduced row height for smaller cells
                                headingRowHeight:
                                    30.0, // Smaller heading row height
                                columns: const [
                                  DataColumn(label: Text('Contract Number')),
                                  DataColumn(label: Text('Vehicle Number')),
                                  DataColumn(label: Text('Shield Number')),
                                  DataColumn(label: Text('Manufacturer')),
                                  DataColumn(label: Text('Trade Nickname')),
                                  DataColumn(label: Text('Colour')),
                                  DataColumn(
                                      label: Text('Year of Manufacture')),
                                  DataColumn(label: Text('Engine Capacity')),
                                  DataColumn(label: Text('Cost Price')),
                                  DataColumn(label: Text('Sell Price')),
                                  DataColumn(label: Text('Notes')),
                                  DataColumn(label: Text('Sold Status')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows:
                                    filterCars(_cars!, searchQuery).map((car) {
                                  final String formattedDate = DateFormat.y()
                                      .format(car.yearOfmanufacture);
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(car.contractNumber)),
                                      DataCell(
                                          Text(car.vehicleNumber.toString())),
                                      DataCell(Text(car.shieldNumber)),
                                      DataCell(Text(car.manufacturer)),
                                      DataCell(Text(car.tradeNickname)),
                                      DataCell(Text(car.colour)),
                                      DataCell(Text(
                                          formattedDate)), // Display only the year
                                      DataCell(
                                          Text(car.engineCapacity.toString())),
                                      DataCell(Text(car.costPrice
                                          .toString())), // New field
                                      DataCell(Text(car.sellPrice
                                          .toString())), // New field
                                      DataCell(Text(car.notes)),
                                      DataCell(
                                        Text(
                                          car.isSold ? 'Sold' : 'Available',
                                          style: TextStyle(
                                            color: car.isSold
                                                ? Colors.red
                                                : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () {
                                                _editCar(car);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                _deleteCar(car.id);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.print,
                                                  color: Colors.green),
                                              onPressed: () {
                                                _printCar(car);
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
                                                _toggleFavorite(car);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                car.isSold
                                                    ? Icons.check_box
                                                    : Icons
                                                        .check_box_outline_blank,
                                                color: Colors.orange,
                                              ),
                                              onPressed: () {
                                                _toggleSold(car);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
