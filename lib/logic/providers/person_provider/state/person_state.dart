import 'package:hisab/core/db/hive/person_model/person.dart';

class PersonState {
  final List<Person> persons;
  final String searchQuery;
  
  PersonState(this.persons , [this.searchQuery = '']);
  
  PersonState copyWith({
    List<Person>? persons,
     String? searchQuery,
     }) {
    return PersonState(
      persons ?? this.persons,
       searchQuery ?? this.searchQuery
       );
  }
}
