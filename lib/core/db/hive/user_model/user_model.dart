import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
class User {
  @HiveField(0)
  final String phoneNumber;
  
  @HiveField(1)
  final String password;

  User({required this.phoneNumber, required this.password});
}
