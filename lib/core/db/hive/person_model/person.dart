
import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 0)
class Person {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  Person({required this.id, required this.name});


  Person copyWith({
    String? id,
    String? name,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
