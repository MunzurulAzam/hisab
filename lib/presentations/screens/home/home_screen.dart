import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hisab/core/config/routes/app_routes.dart';
import 'package:hisab/core/db/hive/person_model/person.dart';
import 'package:hisab/logic/providers/person_provider/provider/person_provider.dart';
import 'package:hisab/logic/providers/transaction_provider/provider/transaction_provider.dart';
import 'package:hisab/presentations/screens/history/arg/arguments.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(personProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hisab'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () => _showSearchDialog(context, ref))],
      ),
      body: state.persons.isEmpty
          ? const Center(child: Text('No contacts added'))
          : ListView.builder(
              itemCount: state.persons.length,
              itemBuilder: (context, index) {
                final person = state.persons[index];
                final balance = ref.watch(balanceProvider(person.id));

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(person.name, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text('Balance: ৳${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.history),
                          onPressed: () =>
                              GoRouter.of(context).pushNamed(RouteName.historyScreen, extra: HistoryScreenArguments(personId: person.id)),
                        ),
                        IconButton(icon: const Icon(Icons.payment), onPressed: () => _showTransactionDialog(context, ref, person.id)),
                      ],
                    ),
                    onTap: () => _showPersonOptions(context, ref, person),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddPersonDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  void _showAddPersonDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Person'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name', hintText: 'Enter person name', border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref.read(personProvider.notifier).addPerson(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, WidgetRef ref, String personId) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPayment = true; // true = Received, false = Paid

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Transaction'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Amount Input
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Amount', prefixText: '৳', border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Enter valid positive amount';
                          }
                          return null;
                        },
                      ),
                      // const SizedBox(height: 16),

                      // // Description Input (Optional)
                      // TextFormField(
                      //   controller: descriptionController,
                      //   decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                      //   maxLines: 2,
                      // ),
                      const SizedBox(height: 16),

                      // Transaction Type Selector
                      const Text('Transaction Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Received'), icon: Icon(Icons.arrow_downward)),
                          ButtonSegment(value: false, label: Text('Paid'), icon: Icon(Icons.arrow_upward)),
                        ],
                        selected: {isPayment},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() => isPayment = newSelection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Add the transaction
                      ref.read(transactionProvider.notifier).addTransaction(personId, double.parse(amountController.text), isPayment);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${isPayment ? 'Received' : 'Paid'} ৳${amountController.text} successfully',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: isPayment ? Colors.green : Colors.red,
                        ),
                      );

                      // Close the dialog
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: isPayment ? Colors.green : Colors.red),
                  child: Text(isPayment ? 'Add Received' : 'Add Paid'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPersonOptions(BuildContext context, WidgetRef ref, Person person) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Name'),
            onTap: () {
              Navigator.pop(context);
              _showEditPersonDialog(context, ref, person);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, ref, person.id);
            },
          ),
        ],
      ),
    );
  }

  void _showEditPersonDialog(BuildContext context, WidgetRef ref, Person person) {
    final nameController = TextEditingController(text: person.name);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Person'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref.read(personProvider.notifier).updatePerson(person.id, nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, String personId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Person'),
        content: const Text('Are you sure you want to delete this person and all their transactions?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(personProvider.notifier).deletePerson(personId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController();
    final state = ref.watch(personProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Person'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(labelText: 'Search by name', border: OutlineInputBorder()),
          autofocus: true,
          onChanged: (value) {
            ref.read(personProvider.notifier).searchPerson(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              searchController.clear();
              ref.read(personProvider.notifier).searchPerson('');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
