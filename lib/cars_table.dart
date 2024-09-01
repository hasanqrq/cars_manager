import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'car.dart';
import 'car_form.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

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

  void _editCar(Car car) async {
    // Navigate to the car form with the current car data for editing
    final updatedCar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CarForm(car: car), // Assuming CarForm is updated to handle editing
      ),
    );

    if (updatedCar != null) {
      // If the car is updated, refresh the table
      _refreshCars();
    }
  }

  void _printTable() async {
    // Generate and print the PDF
    await generateAndPrintArabicPdf(_cars ?? []);
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
                                  DataColumn(
                                      label: Text('Cost Price')), // New column
                                  DataColumn(
                                      label: Text('Sell Price')), // New column
                                  DataColumn(label: Text('Notes')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: _filterCars(_cars!).map((car) {
                                  final String formattedDate = DateFormat.y()
                                      .format(car
                                          .yearOfmanufacture); // Format date to show only the year
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

// Function to generate and print a PDF with Arabic text
// Future<void> generateAndPrintArabicPdf(List<Car> cars) async {
//   final pw.Document pdf = pw.Document();

//   var arabicFont =
//       pw.Font.ttf(await rootBundle.load("assets/fonts/Cairo-Regular.ttf"));

//   pdf.addPage(pw.Page(
//     theme: pw.ThemeData.withFont(
//       base: arabicFont,
//     ),
//     build: (pw.Context context) {
//       return pw.Table.fromTextArray(
//         headers: [
//           'Contract Number',
//           'Vehicle Number',
//           'Shield Number',
//           'Manufacturer',
//           'Trade Nickname',
//           'Colour',
//           'Year of Manufacture',
//           'Engine Capacity',
//           'Cost Price',
//           'Sell Price',
//           'Notes'
//         ],
//         data: cars.map((car) {
//           return [
//             _getDirectionality(car.contractNumber, arabicFont),
//             _getDirectionality(car.vehicleNumber.toString(), arabicFont),
//             _getDirectionality(car.shieldNumber, arabicFont),
//             _getDirectionality(car.manufacturer, arabicFont),
//             _getDirectionality(car.tradeNickname, arabicFont),
//             _getDirectionality(car.colour, arabicFont),
//             _getDirectionality(
//                 DateFormat.y().format(car.yearOfmanufacture), arabicFont),
//             _getDirectionality(car.engineCapacity.toString(), arabicFont),
//             _getDirectionality(car.costPrice.toString(), arabicFont),
//             _getDirectionality(car.sellPrice.toString(), arabicFont),
//             _getDirectionality(car.notes, arabicFont),
//           ];
//         }).toList(),
//         cellStyle: pw.TextStyle(font: arabicFont),
//         headerStyle:
//             pw.TextStyle(font: arabicFont, fontWeight: pw.FontWeight.bold),
//         headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
//       );
//     },
//   ));

//   await Printing.layoutPdf(
//     onLayout: (PdfPageFormat format) async => pdf.save(),
//   );
// }

// pw.Widget _getDirectionality(String text, pw.Font font) {
//   final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
//   return pw.Directionality(
//     textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
//     child: pw.Text(text, style: pw.TextStyle(font: font)),
//   );
// }
Future<void> generateAndPrintArabicPdf(List<Car> cars) async {
  final pw.Document pdf = pw.Document();

  // Load the Arabic font
  var arabicFont =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Cairo-Regular.ttf"));

  pdf.addPage(
    pw.Page(
      pageFormat:
          PdfPageFormat.a4.landscape, // Set the page format to A4 landscape
      theme: pw.ThemeData.withFont(
        base: arabicFont,
      ),
      build: (pw.Context context) {
        return pw.Center(
          // Center the table within the page
          child: pw.Container(
            width: double.infinity, // Make the table take full width
            height: double.infinity, // Make the table take full height
            child: pw.Table.fromTextArray(
              headers: [
                'Contract Number',
                'Vehicle Number',
                'Shield Number',
                'Manufacturer',
                'Trade Nickname',
                'Colour',
                'Year of Manufacture',
                'Engine Capacity',
                'Cost Price',
                'Sell Price',
                'Notes'
              ],
              data: cars.map((car) {
                return [
                  _getDirectionality(car.contractNumber, arabicFont),
                  _getDirectionality(car.vehicleNumber.toString(), arabicFont),
                  _getDirectionality(car.shieldNumber, arabicFont),
                  _getDirectionality(car.manufacturer, arabicFont),
                  _getDirectionality(car.tradeNickname, arabicFont),
                  _getDirectionality(car.colour, arabicFont),
                  _getDirectionality(
                      DateFormat.y().format(car.yearOfmanufacture), arabicFont),
                  _getDirectionality(car.engineCapacity.toString(), arabicFont),
                  _getDirectionality(car.costPrice.toString(), arabicFont),
                  _getDirectionality(car.sellPrice.toString(), arabicFont),
                  _getDirectionality(car.notes, arabicFont),
                ];
              }).toList(),
              cellStyle: pw.TextStyle(font: arabicFont),
              headerStyle: pw.TextStyle(
                  font: arabicFont, fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment:
                  pw.Alignment.center, // Center the text in each cell
              columnWidths: {
                0: pw
                    .FlexColumnWidth(), // Adjust the width of columns as needed
                1: pw.FlexColumnWidth(),
                2: pw.FlexColumnWidth(),
                3: pw.FlexColumnWidth(),
                4: pw.FlexColumnWidth(),
                5: pw.FlexColumnWidth(),
                6: pw.FlexColumnWidth(),
                7: pw.FlexColumnWidth(),
                8: pw.FlexColumnWidth(),
                9: pw.FlexColumnWidth(),
                10: pw.FlexColumnWidth(),
              },
            ),
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

pw.Widget _getDirectionality(String text, pw.Font font) {
  final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  return pw.Directionality(
    textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
    child: pw.Text(text, style: pw.TextStyle(font: font)),
  );
}
