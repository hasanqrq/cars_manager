import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'car.dart';
import 'car_form.dart';
import 'favorite.dart'; // Import favorite screen
import 'search_cars.dart'; // Import the search function
import 'print_car.dart'; // Import the print function
import 'package:intl/intl.dart';

class CarsTable extends StatefulWidget {
  const CarsTable({super.key});

  @override
  CarsTableState createState() => CarsTableState();
}

class CarsTableState extends State<CarsTable> {
  List<Car>? _cars;
  List<Car> _favorites = [];
  String searchQuery = "";

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

  void _printCar(Car car) async {
    await generateAndPrintArabicPdf([car]);
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

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoriteScreen(favorites: _favorites),
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
            icon: const Icon(Icons.favorite),
            onPressed: _navigateToFavorites, // Navigate to favorites screen
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
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
                                      DataCell(Text(formattedDate)),
                                      DataCell(
                                          Text(car.engineCapacity.toString())),
                                      DataCell(Text(car.costPrice.toString())),
                                      DataCell(Text(car.sellPrice.toString())),
                                      DataCell(Text(car.notes)),
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
