import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String personId;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final bool isPayment; // true = received, false = given

  // @HiveField(5)
  // final String description;
  
  Transaction({
    required this.id,
    required this.personId,
    required this.amount,
    required this.date,
    required this.isPayment,
    // this.description = '',
  });
  
  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
}