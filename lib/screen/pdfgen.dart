import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';



Future<int> generatePdf(Map<String,String> data, String ename, String edate) async {
  final pdf = pw.Document();
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat();
  final String formatted = formatter.format(now);
// build your pdf view here
//   print(dataTime);
//   print(ename+edate);

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    // height: 50,
                    padding: const pw.EdgeInsets.only(bottom: 15),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'List of Attendees: ${ename.toUpperCase()}',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 36,

                      ),
                    ),
                  ),

                  pw.Container(
                    decoration: const pw.BoxDecoration(

                      borderRadius:
                      pw.BorderRadius.all(pw.Radius.circular(2)),
                      color: PdfColors.black,
                    ),
                    padding: const pw.EdgeInsets.only(
                        left: 20, top: 10, bottom: 10, right: 20),
                    alignment: pw.Alignment.centerLeft,
                    height: 40,
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                      child: pw.GridView(
                        crossAxisCount: 1,
                        children: [
                          // pw.Text('Invoice #'),
                          // pw.Text(invoiceNumber),
                          // pw.Text('Date:'),
                          pw.Text("Report Generated on "+formatted),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    child: pw.Text(
                      'Event Date: ${edate}',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,

                      ),
                    ),
                  )
                ],
              ),
            ),
            //
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  // pw.Widget _buildFooter(pw.Context context) {
  //   return pw.Row(
  //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //     crossAxisAlignment: pw.CrossAxisAlignment.end,
  //     children: [
  //       pw.Container(
  //         height: 20,
  //         width: 100,
  //         child: pw.BarcodeWidget(
  //           barcode: pw.Barcode.pdf417(),
  //           data: 'Date: $edate, Event: $ename',
  //           drawText: false,
  //         ),
  //       ),
  //       // pw.Text(
  //       //   'Page ${context.pageNumber}/${context.pagesCount}',
  //       //   style: const pw.TextStyle(
  //       //     fontSize: 12,
  //       //     color: PdfColors.white,
  //       //   ),
  //       // ),
  //     ],
  //   );
  // }

  pdf.addPage(

    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          children: [
            _buildHeader(context),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.center,
              context: context,
              data: <List<String>>[
                <String>['ID Number','Time' ],
                ...data.entries.map((e) => [e.key, e.value]),
              ],
            ),
            pw.SizedBox(height: 20),
            // _buildFooter(context),
          ],
        ); // Center
      },
      // header: _buildHeader,
      // footer: _buildFooter,
      // build: (pw.Context context) => pw.Center(
      //   child: pw.Text(data.toString()),
      // ),
    ),
  );
//save pdf
//     final output = await getExternalStorageDirectory();
    final path = "/storage/emulated/0/Download/"+ename.toUpperCase()+"_"+edate+"_Report.pdf";
    // print(path);
    final file = await io.File(path).writeAsBytes(await pdf.save());
    final _result = await OpenFile.open(path);
    return 1;
}

