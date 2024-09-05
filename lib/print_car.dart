import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'car.dart';

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
                0: const pw.FlexColumnWidth(),
                1: const pw.FlexColumnWidth(),
                2: const pw.FlexColumnWidth(),
                3: const pw.FlexColumnWidth(),
                4: const pw.FlexColumnWidth(),
                5: const pw.FlexColumnWidth(),
                6: const pw.FlexColumnWidth(),
                7: const pw.FlexColumnWidth(),
                8: const pw.FlexColumnWidth(),
                9: const pw.FlexColumnWidth(),
                10: const pw.FlexColumnWidth(),
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
