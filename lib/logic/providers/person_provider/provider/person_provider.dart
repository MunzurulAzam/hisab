import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hisab/core/db/hive/person_model/person.dart';
import 'package:hisab/core/db/hive/transaction_model/transaction.dart';
import 'package:hisab/logic/providers/person_provider/state/person_state.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class PersonNotifier extends StateNotifier<PersonState> {
  PersonNotifier() : super(PersonState(Hive.box<Person>('persons').values.toList()));

  void addPerson(String name) {
    final person = Person(id: Uuid().v4(), name: name);
    Hive.box<Person>('persons').put(person.id, person);
    state = state.copyWith(persons: [...state.persons, person]);
  }

  void updatePerson(String id, String newName) {
    final personIndex = state.persons.indexWhere((person) => person.id == id);
    if (personIndex != -1) {
      final updatedPerson = state.persons[personIndex].copyWith(name: newName);
      Hive.box<Person>('persons').put(id, updatedPerson);
      final updatedPersons = List<Person>.from(state.persons);
      updatedPersons[personIndex] = updatedPerson;
      state = state.copyWith(persons: updatedPersons);
    }
  }

  void deletePerson(String id) {
    // First delete all transactions associated with this person
    // (Assuming you have a transactions box)
    final transactionsBox = Hive.box<Transaction>('transactions');
    final transactionsToDelete = transactionsBox.values
        .where((transaction) => transaction.personId == id)
        .toList();
    
    for (final transaction in transactionsToDelete) {
      transactionsBox.delete(transaction.id);
    }
    
    // Then delete the person
    Hive.box<Person>('persons').delete(id);
    state = state.copyWith(
      persons: state.persons.where((person) => person.id != id).toList()
    );
  }

  void searchPerson(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        persons: Hive.box<Person>('persons').values.toList(),
        searchQuery: ''
      );
    } else {
      final filtered = Hive.box<Person>('persons').values
          .where((person) => person.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      state = state.copyWith(
        persons: filtered,
        searchQuery: query
      );
    }
  }
}

final personProvider = StateNotifierProvider<PersonNotifier, PersonState>((ref) {
  return PersonNotifier();
});