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
    await generateAndPrintArabicPdf(_cars ?? []);
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

Future<void> generateAndPrintArabicPdf(List<Car> cars) async {
  final pw.Document pdf = pw.Document();

  var arabicFont =
      pw.Font.ttf(await rootBundle.load("assets/fonts/Cairo-Regular.ttf"));

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      theme: pw.ThemeData.withFont(
        base: arabicFont,
      ),
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Container(
            width: double.infinity,
            height: double.infinity,
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
              cellAlignment: pw.Alignment.center,
              columnWidths: {
                0: pw.FlexColumnWidth(),
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
