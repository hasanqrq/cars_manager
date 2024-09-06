import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'car.dart';
import 'car_form.dart';
import 'package:intl/intl.dart';

class CarsTable extends StatefulWidget {
  const CarsTable({super.key});

  @override
  CarsTableState createState() => CarsTableState();
}

class CarsTableState extends State<CarsTable> {
  List<Car>? _cars;
  String searchQuery = "";
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

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
    // Implement your print function here.
  }

  List<Car> _filterCars(List<Car> cars) {
    if (searchQuery.isEmpty) {
      return cars;
    } else {
      return cars.where((car) {
        return car.contractNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            car.vehicleNumber.toString().contains(searchQuery) ||
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
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xff973131),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printTable,
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
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _filterCars(_cars!).map((car) {
                                  final String formattedDate = DateFormat.y()
                                      .format(car.yearOfmanufacture);
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(
                                        car.contractNumber,
                                        style: const TextStyle(
                                            fontSize:
                                                10.0), // Smaller font size
                                      )),
                                      DataCell(Text(
                                        car.vehicleNumber.toString(),
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
                                      DataCell(Text(
                                        car.shieldNumber,
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
                                      DataCell(Text(
                                        car.manufacturer,
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
                                      DataCell(Text(
                                        car.tradeNickname,
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
                                      DataCell(Text(
                                        car.colour,
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
                                      DataCell(Text(
                                        formattedDate,
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
                                      DataCell(Text(
                                        car.engineCapacity.toString(),
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
                                      DataCell(Text(
                                        car.costPrice.toString(),
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
                                      DataCell(Text(
                                        car.sellPrice.toString(),
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
                                      DataCell(Text(
                                        car.notes,
                                        style: const TextStyle(fontSize: 10.0),
                                      )),
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
