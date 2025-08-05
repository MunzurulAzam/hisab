import 'package:hisab/core/db/hive/transaction_model/transaction.dart';

class TransactionState {
  final List<Transaction> transactions;
  
  TransactionState(this.transactions);
  
  TransactionState copyWith({List<Transaction>? transactions}) {
    return TransactionState(transactions ?? this.transactions);
  }
}