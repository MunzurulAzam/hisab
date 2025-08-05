import 'dart:io';

import 'package:hisab/core/db/hive/person_model/person.dart';
import 'package:hisab/core/db/hive/transaction_model/transaction.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<void> generateAndShare(
    Transaction transaction,
    Person person,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Len Den Receipt', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          pw.Text('Date: ${transaction.formattedDate}'),
          pw.Text('Person: ${person.name}'),
          pw.Text('Amount: ₹${transaction.amount.toStringAsFixed(2)}'),
          pw.Text('Type: ${transaction.isPayment ? "Received" : "Paid"}'),
          pw.Divider(),
          pw.Text('Signature: _______________', style: pw.TextStyle(fontSize: 18)),
        ],
      ),
    ));

    // Get the temporary directory
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt_${transaction.id}.pdf");
    
    // Save the PDF file
    await file.writeAsBytes(await pdf.save());

    // Create an XFile from the saved file path
    final xFile = XFile(file.path);

    // Use the shareXFiles method with the XFile object
    await Share.shareXFiles(
      [xFile],
      text: 'Len Den Receipt for ${person.name}',
      subject: 'Payment Receipt',
    );
  }
}