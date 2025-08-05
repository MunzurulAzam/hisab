import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisab/core/db/hive/person_model/person.dart';
import 'package:hisab/core/db/hive/transaction_model/transaction.dart';
import 'package:hisab/logic/providers/person_provider/provider/person_provider.dart';
import 'package:hisab/logic/providers/transaction_provider/provider/transaction_provider.dart';
import 'package:hisab/presentations/screens/history/arg/arguments.dart';

class HistoryScreen extends ConsumerWidget {
  final HistoryScreenArguments arg;
  
   const HistoryScreen({super.key, required this.arg});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(personProvider).persons.firstWhere((p) => p.id == arg.personId);
    final transactions = ref.watch(transactionProvider).transactions
        .where((t) => t.personId == arg.personId)
        .toList()
        .reversed
        .toList();
    
    return Scaffold(
      appBar: AppBar(title: Text('${person.name} - History')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final t = transactions[index];
          return ListTile(
            title: Text('₹${t.amount.toStringAsFixed(2)}'),
            subtitle: Text(t.formattedDate),
            trailing: IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: () => _generatePdf(context, t, person),
            ),
            leading: Icon(t.isPayment ? Icons.arrow_downward : Icons.arrow_upward,
                         color: t.isPayment ? Colors.green : Colors.red),
          );
        },
      ),
    );
  }
  
  void _generatePdf(BuildContext context, Transaction transaction, Person person) async {
    // PDF generation logic
  }
}