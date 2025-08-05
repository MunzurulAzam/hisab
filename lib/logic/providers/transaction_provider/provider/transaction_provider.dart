import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisab/core/db/hive/transaction_model/transaction.dart';
import 'package:hisab/logic/providers/transaction_provider/state/transaction_state.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(TransactionState(Hive.box<Transaction>('transactions').values.toList()));

  // Add new transaction
  void addTransaction(String personId, double amount, bool isPayment) {
    final transaction = Transaction(
      id: Uuid().v4(),
      personId: personId,
      amount: amount.abs(), // Ensure amount is always positive
      date: DateTime.now(),
      isPayment: isPayment,
      // description: '', // Optional
    );
    
    _saveTransaction(transaction);
  }

  // Save transaction to Hive and update state
  void _saveTransaction(Transaction transaction) {
    Hive.box<Transaction>('transactions').put(transaction.id, transaction);
    state = state.copyWith(transactions: [...state.transactions, transaction]);
  }

  // Get transactions for specific person
  List<Transaction> getTransactionsForPerson(String personId) {
    return state.transactions
        .where((t) => t.personId == personId)
        .toList()
        .reversed // Show latest first
        .toList();
  }

  // Delete transaction
  void deleteTransaction(String transactionId) {
    Hive.box<Transaction>('transactions').delete(transactionId);
    state = state.copyWith(
      transactions: state.transactions.where((t) => t.id != transactionId).toList()
    );
  }

  // Update transaction
  void updateTransaction(Transaction updatedTransaction) {
    Hive.box<Transaction>('transactions').put(updatedTransaction.id, updatedTransaction);
    state = state.copyWith(
      transactions: state.transactions.map((t) => 
        t.id == updatedTransaction.id ? updatedTransaction : t
      ).toList()
    );
  }
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier();
});

// Enhanced Balance Calculator
final balanceProvider = Provider.family<double, String>((ref, personId) {
  final transactions = ref.watch(transactionProvider.select((state) => state.transactions));
  
  return transactions
      .where((t) => t.personId == personId)
      .fold(0.0, (sum, t) {
        // Calculate net balance
        final amount = t.isPayment ? t.amount : -t.amount;
        return sum + amount;
      });
});

// Additional Provider for Transaction Summary
final transactionSummaryProvider = Provider.family<Map<String, dynamic>, String>((ref, personId) {
  final transactions = ref.watch(transactionProvider.select((state) => state.transactions));
  final personTransactions = transactions.where((t) => t.personId == personId);

  final totalReceived = personTransactions
      .where((t) => t.isPayment)
      .fold(0.0, (sum, t) => sum + t.amount);

  final totalPaid = personTransactions
      .where((t) => !t.isPayment)
      .fold(0.0, (sum, t) => sum + t.amount);

  final netBalance = totalReceived - totalPaid;

  return {
    'totalReceived': totalReceived,
    'totalPaid': totalPaid,
    'netBalance': netBalance,
    'transactionCount': personTransactions.length,
  };
});